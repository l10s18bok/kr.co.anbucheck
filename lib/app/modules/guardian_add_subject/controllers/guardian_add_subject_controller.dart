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
  bool get isCodeValid => _isCodeValid.value;

  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

  void onCodeChanged(String value) {
    // XXX-XXXX 형식 (7자리 + 하이픈)
    _isCodeValid.value = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{4}$').hasMatch(value.trim().toUpperCase());
  }

  /// 대상자 연결 — 서버 API + 별칭 로컬 저장
  Future<void> connectSubject() async {
    if (!_isCodeValid.value) return;

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) {
      Get.snackbar('오류', '로그인이 필요합니다.', snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('완료', '보호 대상자가 연결되었습니다.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      final msg = e.toString().contains('404')
          ? '유효하지 않은 코드입니다.'
          : e.toString().contains('409')
              ? '이미 연결된 보호 대상자입니다.'
              : '연결에 실패했습니다. 잠시 후 다시 시도해 주세요.';
      Get.snackbar('오류', msg, snackPosition: SnackPosition.BOTTOM);
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
