import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 초기화 및 관리 서비스
class AdService extends GetxService {
  static AdService get to => Get.find<AdService>();

  Future<AdService> init() async {
    await MobileAds.instance.initialize();
    return this;
  }
}
