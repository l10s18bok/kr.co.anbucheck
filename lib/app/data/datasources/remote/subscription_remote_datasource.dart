import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 구독(인앱 결제) 영수증 검증 / 복원 원격 저장소.
///
/// 서버 합의:
/// - 입력 `receipt`:
///   · iOS  = `PurchaseDetails.purchaseID` (transactionId)
///   · Android = `verificationData.serverVerificationData` (purchaseToken)
/// - 응답: `{ plan, expires_at, is_active }`
/// - restore 응답에는 추가로 `restored: true` 포함
///
/// 클라이언트는 응답이 도착하기 전까지 entitlement(광고 제거·만료 배너 제거 등)를
/// 노출하지 않는다 — 서버 검증 통과가 유일한 권위.
class SubscriptionRemoteDatasource {
  final Map<String, String> _auth;

  SubscriptionRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  /// POST /api/v1/subscription/verify
  Future<Map<String, dynamic>> verifyReceipt({
    required String platform,
    required String productId,
    required String receipt,
  }) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.subscriptionVerify,
      {
        'platform': platform,
        'product_id': productId,
        'receipt': receipt,
      },
      headers: _auth,
    );
    if (!result.isOk) {
      throw Exception('구독 검증 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// POST /api/v1/subscription/restore
  Future<Map<String, dynamic>> restoreSubscription({
    required String platform,
    required String productId,
    required String receipt,
  }) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.subscriptionRestore,
      {
        'platform': platform,
        'product_id': productId,
        'receipt': receipt,
      },
      headers: _auth,
    );
    if (!result.isOk) {
      throw Exception('구독 복원 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }
}
