import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 모드 선택 컨트롤러
/// 모드 선택 시 기존 역할 확인 → 권한 안내 페이지로 이동
class ModeSelectController extends BaseController {
  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _userDs = UserRemoteDatasource();

  /// 대상자 모드 선택
  void selectSubjectMode() => _selectMode('subject');

  /// 보호자 모드 선택
  void selectGuardianMode() => _selectMode('guardian');

  /// 모드 선택 → 기존 역할 확인 → 권한 안내 페이지 이동
  Future<void> _selectMode(String mode) async {
    isLoading = true;
    try {
      final deviceId = await _tokenDs.getOrCreateDeviceId();

      // 서버에 기존 등록 여부만 조회 (데이터 수정 없음)
      final check = await _userDs.checkDevice(deviceId);
      final exists = check['exists'] as bool? ?? false;
      final existingRole = check['role'] as String?;

      if (exists && existingRole != null && existingRole != mode) {
        // 기존 역할과 다른 모드 선택 → 경고 다이얼로그
        isLoading = false;
        final hasInviteCode = check['has_invite_code'] as bool? ?? false;
        final roleLabel = existingRole == 'subject'
            ? 'onboarding_role_subject'.tr
            : hasInviteCode
                ? 'onboarding_role_guardian_subject'.tr
                : 'onboarding_role_guardian'.tr;
        final newRoleLabel = mode == 'subject'
            ? 'onboarding_role_subject'.tr
            : 'onboarding_role_guardian'.tr;

        // G+S는 양쪽 데이터 모두 삭제됨을 안내
        final messageKey = hasInviteCode
            ? 'onboarding_already_registered_message_gs'
            : 'onboarding_already_registered_message';

        final choice = await Get.dialog<String>(
          barrierDismissible: false,
          AlertDialog(
            title: Text('onboarding_already_registered_title'.tr),
            content: Text(
              messageKey.trParams({
                'roleLabel': roleLabel,
                'newRoleLabel': newRoleLabel,
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: 'cancel'),
                child: Text('common_cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'change'),
                child: Text('common_continue'.tr),
              ),
            ],
          ),
        );

        if (choice != 'change') return;

        // 변경 선택 → 기존 계정 삭제 후 새 모드로 진행
        isLoading = true;
        // 기존 계정 삭제를 위해 임시 register로 토큰 획득 후 삭제
        final regResponse = await _userDs.register(
          role: mode,
          deviceId: deviceId,
          fcmToken: '',
          platform: 'android',
        );
        final oldToken = regResponse['device_token'] as String?;
        if (oldToken != null) {
          try {
            await _userDs.deleteMe(oldToken);
          } catch (_) {
            // 204 파싱 오류 무시
          }
        }
        await _tokenDs.clear();
        await _nicknameDs.clearAll();
        await HeartbeatLockDatasource().clearAll();
        isLoading = false;
      }

      // 신규 또는 동일 역할 또는 변경 완료 → 권한 안내 페이지 이동
      // G+S 재설치: 보호자 선택이지만 invite_code 존재 → 대상자 권한도 필요
      final needsSubjectPermission = mode == 'guardian'
          && exists
          && (check['has_invite_code'] as bool? ?? false);
      Get.toNamed(AppRoutes.permission, arguments: {
        'mode': mode,
        'isAlsoSubject': needsSubjectPermission,
      });
    } catch (e) {
      // 서버 오류 시에도 진행 가능하도록
      Get.toNamed(AppRoutes.permission, arguments: {'mode': mode});
    } finally {
      isLoading = false;
    }
  }
}
