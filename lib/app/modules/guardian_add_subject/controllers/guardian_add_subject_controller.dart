import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';

/// 보호자 대상자 추가 컨트롤러
/// PRD 7.7: 고유 코드 입력 → 서버 연결 → 별칭 저장(로컬)
class GuardianAddSubjectController extends BaseController {
  final codeController = TextEditingController();
  final aliasController = TextEditingController();

  final _isCodeValid = false.obs;
  final _isAliasValid = false.obs;
  bool get isFormValid => _isCodeValid.value && _isAliasValid.value;

  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

  void onCodeChanged(String value) {
    // XXX-XXXX 형식 (7자리 + 하이픈)
    _isCodeValid.value = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{4}$').hasMatch(value.trim().toUpperCase());
  }

  void onAliasChanged(String value) {
    _isAliasValid.value = value.trim().isNotEmpty;
  }

  /// 대상자 연결 — 서버 API + 별칭 로컬 저장
  Future<void> connectSubject() async {
    if (!isFormValid) return;
    // 재진입 가드: [연결하기] 더블탭 시 link API가 두 번 발사되어
    // 두 번째 호출이 409로 실패하면서 사용자에게 혼동 주는 이슈 방지
    if (isLoading) return;

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) {
      Get.snackbar('common_error'.tr, 'add_subject_error_login'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading = true;
    try {
      final inviteCode = codeController.text.trim().toUpperCase();
      await _subjectDs.linkSubject(deviceToken, inviteCode);

      // 별칭은 서버에 전송하지 않고 로컬에만 저장
      final alias = aliasController.text.trim();
      if (alias.isNotEmpty) {
        await _nicknameDs.save(inviteCode, alias);
      }

      Get.back(result: true);
      Get.snackbar('common_complete'.tr, 'add_subject_success'.tr, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      final msg = e.toString().contains('404')
          ? 'add_subject_error_invalid_code'.tr
          : e.toString().contains('409')
              ? 'add_subject_error_already_connected'.tr
              : 'add_subject_error_failed'.tr;
      Get.snackbar('common_error'.tr, msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    aliasController.dispose();
    super.onClose();
  }
}
