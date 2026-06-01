import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/services/subscription_service.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subscription_remote_datasource.dart';

/// 안부 프리미엄 — 보호자 연 $9.99 자동 갱신 구독 (`anbu_yearly`).
const String kAnbuYearlyProductId = 'anbu_yearly';

/// 구독 검증 결과 — UI 리프레시 트리거 콜백에 전달.
class IapVerifyResult {
  final String plan; // 'yearly' | 'expired' | ...
  final String? expiresAt; // ISO8601
  final bool isActive;
  final bool restored;

  const IapVerifyResult({
    required this.plan,
    required this.expiresAt,
    required this.isActive,
    this.restored = false,
  });
}

/// 인앱 결제 서비스.
///
/// PRD 7-6 결제 플로우 규칙:
/// - 서버 검증 완료 전까지 entitlement 노출 금지 (클라 단독 판단 금지)
/// - 결제 중 앱 강제 종료 대비 — purchaseStream은 앱 재시작 시 pending 트랜잭션 재발행
/// - 실패 시 completePurchase 호출 금지 → 재시도 가능하도록 유지
///
/// 사용:
/// 1. Splash `_initServices`에서 `Get.putAsync(() => IapService().init())`
/// 2. UI에서 `Get.find<IapService>().buy()` / `restore()` 호출
/// 3. 검증 성공 시 `onVerified` 콜백으로 UI 측 `subscriptionPlan` 등 리프레시
class IapService extends GetxService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final _tokenDs = TokenLocalDatasource();

  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// 스토어 가용성 (Play/App Store 연결 가능 여부). false면 [구독하기] 버튼 숨김.
  final isAvailable = false.obs;

  /// 상품 정보 (제목·로컬 가격 표시용). null이면 상품 조회 실패.
  final productDetails = Rxn<ProductDetails>();

  /// buy/restore 처리 중 — UI 버튼 disable + 로딩 표시용.
  final isProcessing = false.obs;

  /// 마지막 검증 결과. UI에서 Obx로 구독 가능.
  final lastResult = Rxn<IapVerifyResult>();

  /// 마지막 에러 메시지 (i18n 키 형태). UI에서 에러 톤 스낵바로 표시.
  final lastError = ''.obs;

  /// 마지막 정보 메시지 (i18n 키 형태). UI에서 정보 톤 스낵바로 표시.
  /// 에러가 아닌 정상 결과 안내 — 복원 대상 없음 / 복원 성공 / 구독 시작 성공.
  final lastInfo = ''.obs;

  /// 동일 purchaseID 검증 중복 차단 (restore 시 같은 purchase가 여러 번 emit되는
  /// 케이스 dedup. 서버 verify가 멱등이지만 클라 단계에서 깔끔하게 거름).
  final Set<String> _inFlight = {};

  /// 사용자가 [구독 복원] 탭 후 purchaseStream에서 어떤 emit도 받지 못했는지
  /// 추적. 5초 안전망에서 true로 남아있으면 "복원할 구독이 없습니다" 안내.
  /// `_handleVerify(restore: true)` 진입 시 false로 전환되어 안전망 안내 차단.
  bool _pendingRestore = false;

  /// 검증 성공 시 호출되는 콜백. UI 측 컨트롤러가 등록하여 카드/배너 갱신.
  void Function(IapVerifyResult)? onVerified;

  Future<IapService> init() async {
    try {
      // StoreKit/Play Billing hang 대비 — try/catch는 throw만 잡고 hang을 못 막는다.
      isAvailable.value = await _iap.isAvailable().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );
      '[IAP] isAvailable: ${isAvailable.value}'.printLog();

      if (isAvailable.value) {
        // 상품 조회 — 미등록 상태에서는 notFoundIDs에 담겨 오므로 productDetails는 null로 둠
        final response =
            await _iap.queryProductDetails({kAnbuYearlyProductId});
        if (response.error != null) {
          '[IAP] 상품 조회 에러: ${response.error}'.printLog();
        }
        if (response.notFoundIDs.isNotEmpty) {
          '[IAP] notFoundIDs: ${response.notFoundIDs}'.printLog();
        }
        if (response.productDetails.isNotEmpty) {
          productDetails.value = response.productDetails.first;
          '[IAP] 상품 조회 성공: ${productDetails.value!.title} ${productDetails.value!.price}'
              .printLog();
        }

        // purchaseStream 구독 — pending 트랜잭션이 앱 재시작 직후 재발행되므로
        // UI 진입 전에도 받을 수 있도록 Splash 단계에서 등록한다.
        _sub = _iap.purchaseStream.listen(
          _onPurchaseUpdated,
          onError: (e) => '[IAP] purchaseStream 에러: $e'.printLog(),
          onDone: () => '[IAP] purchaseStream done'.printLog(),
        );
      }
    } catch (e) {
      '[IAP] init 예외: $e'.printLog();
    }
    return this;
  }

  /// 신규 구독 결제 시작. 결과는 purchaseStream으로 비동기 수신.
  Future<bool> buy() async {
    if (!isAvailable.value) {
      lastError.value = 'subscription_store_unavailable';
      return false;
    }
    final details = productDetails.value;
    if (details == null) {
      lastError.value = 'subscription_product_unavailable';
      return false;
    }

    try {
      isProcessing.value = true;
      lastError.value = '';
      final param = PurchaseParam(productDetails: details);
      // 구독은 non-consumable (또는 auto-renewing) — buyNonConsumable 사용
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      '[IAP] buyNonConsumable 시작: $started'.printLog();
      if (!started) {
        isProcessing.value = false;
        lastError.value = 'subscription_purchase_failed';
      }
      // started == true여도 결과는 purchaseStream으로 도착 — isProcessing은 그곳에서 해제
      return started;
    } catch (e) {
      '[IAP] buy 예외: $e'.printLog();
      isProcessing.value = false;
      lastError.value = 'subscription_purchase_failed';
      return false;
    }
  }

  /// 기존 구독 복원. 결과는 purchaseStream으로 PurchaseStatus.restored로 도착.
  /// 복원할 영수증이 없는 경우(신규 사용자가 호기심에 탭 등) Apple/Google이
  /// 빈 응답을 보내거나 아예 응답이 없을 수 있어 5초 안전망으로 안내한다.
  Future<void> restore() async {
    if (!isAvailable.value) {
      lastError.value = 'subscription_store_unavailable';
      return;
    }
    try {
      isProcessing.value = true;
      lastError.value = '';
      lastInfo.value = '';
      _pendingRestore = true;
      await _iap.restorePurchases();
      '[IAP] restorePurchases 호출 완료 — purchaseStream 대기'.printLog();
      // 5초 안전망:
      //   - 그 사이 _handleVerify(restore: true)가 실행되면 _pendingRestore=false →
      //     정보 메시지를 띄우지 않고 처리 종료
      //   - emit이 전혀 없거나 빈 리스트만 받으면 _pendingRestore=true 유지 →
      //     "복원할 구독이 없습니다" 안내
      Future.delayed(const Duration(seconds: 5), () {
        if (isProcessing.value) {
          isProcessing.value = false;
        }
        if (_pendingRestore) {
          _pendingRestore = false;
          lastInfo.value = 'subscription_restore_nothing';
        }
      });
    } catch (e) {
      '[IAP] restore 예외: $e'.printLog();
      isProcessing.value = false;
      _pendingRestore = false;
      lastError.value = 'subscription_restore_failed';
    }
  }

  // ── purchaseStream 분기 ──

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> list) async {
    for (final pd in list) {
      try {
        switch (pd.status) {
          case PurchaseStatus.pending:
            '[IAP] pending — 사용자 결제 진행 중'.printLog();
            break;

          case PurchaseStatus.purchased:
            await _handleVerify(pd, restore: false);
            break;

          case PurchaseStatus.restored:
            await _handleVerify(pd, restore: true);
            break;

          case PurchaseStatus.error:
            '[IAP] error: ${pd.error?.message}'.printLog();
            lastError.value = 'subscription_purchase_failed';
            isProcessing.value = false;
            // 실패 시 completePurchase 호출 금지 — 재시도 가능하도록 유지
            break;

          case PurchaseStatus.canceled:
            '[IAP] canceled'.printLog();
            isProcessing.value = false;
            // 사용자 취소는 에러 다이얼로그 표시하지 않음
            if (pd.pendingCompletePurchase) {
              await _iap.completePurchase(pd);
            }
            break;
        }
      } catch (e) {
        '[IAP] _onPurchaseUpdated 처리 예외: $e'.printLog();
        isProcessing.value = false;
      }
    }
  }

  Future<void> _handleVerify(
    PurchaseDetails pd, {
    required bool restore,
  }) async {
    final purchaseId = pd.purchaseID;
    if (purchaseId == null || purchaseId.isEmpty) {
      '[IAP] purchaseID null/empty — verify skip'.printLog();
      isProcessing.value = false;
      return;
    }

    if (_inFlight.contains(purchaseId)) {
      '[IAP] 중복 verify 차단: $purchaseId'.printLog();
      return;
    }
    _inFlight.add(purchaseId);

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) {
      '[IAP] deviceToken 없음 — verify skip'.printLog();
      _inFlight.remove(purchaseId);
      isProcessing.value = false;
      return;
    }

    // 서버 합의된 receipt 추출:
    //   iOS  = PurchaseDetails.purchaseID (transactionId)
    //   Android = verificationData.serverVerificationData (purchaseToken)
    final receipt = Platform.isIOS
        ? purchaseId
        : pd.verificationData.serverVerificationData;
    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      final ds = SubscriptionRemoteDatasource(deviceToken);
      final res = restore
          ? await ds.restoreSubscription(
              platform: platform,
              productId: pd.productID,
              receipt: receipt,
            )
          : await ds.verifyReceipt(
              platform: platform,
              productId: pd.productID,
              receipt: receipt,
            );

      final plan = res['plan'] as String? ?? '';
      final expiresAt = res['expires_at'] as String?;
      final isActive = res['is_active'] as bool? ?? false;
      final restored = res['restored'] as bool? ?? restore;

      final result = IapVerifyResult(
        plan: plan,
        expiresAt: expiresAt,
        isActive: isActive,
        restored: restored,
      );
      lastResult.value = result;
      // 단일 소스 SubscriptionService.set으로 일원화 — set(true)가 즉시 전 보호자
      // 화면 잠금 해제 트리거(대시보드/알림 ever 재조회). 미등록 시 영속만 폴백.
      if (Get.isRegistered<SubscriptionService>()) {
        await Get.find<SubscriptionService>().set(isActive);
      } else {
        await _tokenDs.saveSubscriptionActive(isActive);
      }

      // 유료 전환 → 최초 설치 때 예약해 둔 "무료체험 종료" 1회 로컬 알림 취소
      // (구독했는데 90일째 "체험 종료" 알림이 뜨는 오발송 방지).
      if (isActive) {
        try {
          await LocalAlarmService.cancelTrialEnded();
        } catch (_) {}
      }

      // 복원 emit을 받았으니 5초 안전망의 "복원할 구독 없음" 안내 차단
      _pendingRestore = false;

      // 사용자 안내 (정보 톤). 성공 시각적 변화(카드 yearly 전환)에 더해
      // 명시적 텍스트 안내로 완결성 확보.
      if (isActive) {
        lastInfo.value = restore
            ? 'subscription_restore_success'
            : 'subscription_purchase_success';
      }

      '[IAP] verify 성공 — plan=$plan active=$isActive restored=$restored'
          .printLog();

      // 서버 검증 성공 후에만 트랜잭션 종료
      if (pd.pendingCompletePurchase) {
        await _iap.completePurchase(pd);
        '[IAP] completePurchase 완료'.printLog();
      }

      // UI 측 콜백으로 구독 카드/배너 갱신
      try {
        onVerified?.call(result);
      } catch (e) {
        '[IAP] onVerified 콜백 예외: $e'.printLog();
      }
    } catch (e) {
      '[IAP] verify 실패: $e'.printLog();
      lastError.value = restore
          ? 'subscription_restore_failed'
          : 'subscription_verify_failed';
      // 검증 실패 — completePurchase 호출 금지 (다음 재시도 가능)
    } finally {
      _inFlight.remove(purchaseId);
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
