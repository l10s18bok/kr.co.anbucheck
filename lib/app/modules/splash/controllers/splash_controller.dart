import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/version_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// Splash 컨트롤러
/// 흐름: Splash → 버전 체크 → 기등록 확인 → 홈 or 모드 선택
class SplashController extends BaseController {
  final _tokenDs = TokenLocalDatasource();
  final _versionDs = VersionRemoteDatasource();

  /// 앱 현재 버전 (pubspec.yaml과 일치하도록 유지)
  static const String _appVersion = '1.0.0';

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // 1. 버전 체크 (실패해도 계속 진행)
    final forceUpdate = await _checkVersion();
    if (forceUpdate) return; // 강제 업데이트 다이얼로그에서 처리

    // 2. 기등록 여부 확인 → 해당 홈으로 이동
    final deviceToken = await _tokenDs.getDeviceToken();
    final userRole = await _tokenDs.getUserRole();

    if (deviceToken != null && userRole != null) {
      if (userRole == 'subject') {
        Get.offNamed(AppRoutes.subjectHome);
      } else {
        Get.offNamed(AppRoutes.guardianDashboard);
      }
    } else {
      Get.offNamed(AppRoutes.modeSelect);
    }
  }

  /// 버전 체크 — 강제 업데이트 필요 시 true 반환
  Future<bool> _checkVersion() async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final data = await _versionDs.checkVersion(platform, _appVersion);
    if (data == null) return false;

    final forceUpdate = data['force_update'] as bool? ?? false;
    final latestVersion = data['latest_version'] as String? ?? _appVersion;
    final storeUrl = data['store_url'] as String? ?? '';

    if (forceUpdate) {
      await _showForceUpdateDialog(latestVersion, storeUrl);
      return true;
    }

    // 선택적 업데이트 안내 (건너뛰기 가능)
    if (latestVersion != _appVersion) {
      _showOptionalUpdateSnackbar(latestVersion);
    }
    return false;
  }

  Future<void> _showForceUpdateDialog(String version, String storeUrl) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('업데이트 필요'),
        content: Text('새 버전($version)으로 업데이트해야 앱을 사용할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: url_launcher로 스토어 이동
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showOptionalUpdateSnackbar(String version) {
    Get.snackbar(
      '업데이트 안내',
      '새 버전($version)이 있습니다.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('나중에'),
      ),
    );
  }
}
