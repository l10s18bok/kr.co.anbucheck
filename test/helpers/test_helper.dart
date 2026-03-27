import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// GetX 테스트용 바인딩 초기화
void setupTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
}

/// 테스트 후 GetX 정리
void tearDownGetX() {
  Get.reset();
}
