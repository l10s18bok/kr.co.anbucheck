import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 초기화 및 관리 서비스
///
/// UMP(User Messaging Platform) 동의 흐름을 포함한다.
/// EEA/UK/스위스 사용자에게는 IAB Europe TCF 동의 폼이 표시되며,
/// 동의 거부 시 광고를 로드하지 않는다.
class AdService extends GetxService {
  static AdService get to => Get.find<AdService>();

  Future<AdService> init() async {
    await _gatherConsent();
    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
    }
    return this;
  }

  /// UMP 동의 정보 갱신 + 필요 시 동의 폼 표시.
  /// EEA/UK/스위스 외 지역은 폼 없이 즉시 완료됨.
  Future<void> _gatherConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        // 동의 정보 갱신 성공 — 필요 시 폼 표시 후 완료
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? formError) {
          if (formError != null && kDebugMode) {
            debugPrint('[AdService] UMP form error: ${formError.message}');
          }
          if (!completer.isCompleted) completer.complete();
        });
      },
      (FormError error) {
        // 네트워크 오류 등 — 실패해도 계속 진행(광고 게이트는 canRequestAds가 최종 판단)
        if (kDebugMode) debugPrint('[AdService] UMP update error: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  /// EEA 사용자에게 Privacy Options 진입점이 필요한지 여부.
  Future<bool> isPrivacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// 광고 동의 설정 변경 폼 표시 (EEA 사용자가 동의를 철회·변경할 수 있도록).
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? formError) {
      if (formError != null && kDebugMode) {
        debugPrint('[AdService] Privacy options error: ${formError.message}');
      }
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }
}
