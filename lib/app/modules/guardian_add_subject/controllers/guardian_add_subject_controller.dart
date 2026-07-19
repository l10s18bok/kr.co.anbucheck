import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/subject_phone_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';

/// 보호자 대상자 추가 컨트롤러
/// PRD 7.7: 고유 코드 입력 → 서버 연결 → 별칭/연락처 저장(로컬)
class GuardianAddSubjectController extends BaseController {
  final codeController = TextEditingController();
  final aliasController = TextEditingController();
  final phoneController = TextEditingController();

  final _isCodeValid = false.obs;
  final _isAliasValid = false.obs;
  // 연락처는 선택 입력 — 연결하기 버튼 활성화 조건에는 포함되지 않음
  bool get isFormValid => _isCodeValid.value && _isAliasValid.value;

  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _phoneDs = SubjectPhoneLocalDatasource();
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
      AppSnackbar.show('common_error'.tr, 'add_subject_error_login'.tr);
      return;
    }

    final inviteCode = codeController.text.trim().toUpperCase();

    // 본인 코드 연결 방지 (G+S 사용자가 자기 invite_code 입력 시).
    // 순수 보호자는 invite_code가 없어 자연히 통과. 서버 400은 백스톱으로 유지.
    final ownCode = (await _tokenDs.getInviteCode())?.trim().toUpperCase();
    if (ownCode != null && ownCode.isNotEmpty && ownCode == inviteCode) {
      AppSnackbar.show('common_error'.tr, 'add_subject_error_self'.tr);
      return;
    }

    // 최대 등록 인원 초과 사전 차단 — 서버가 내려준 max_subjects 기반(동적).
    // 서버 400(최대 인원 초과)은 stale 캐시 race 시의 백스톱으로 유지.
    if (Get.isRegistered<GuardianSubjectService>()) {
      final svc = Get.find<GuardianSubjectService>();
      if (!svc.canAddMore.value) {
        AppSnackbar.show(
          'common_error'.tr,
          'add_subject_error_limit'.trParams({'max': '${svc.maxSubjects.value}'}),
        );
        return;
      }
    }

    isLoading = true;
    try {
      await _subjectDs.linkSubject(deviceToken, inviteCode);

      // 별칭/연락처는 서버에 전송하지 않고 로컬에만 저장
      final alias = aliasController.text.trim();
      if (alias.isNotEmpty) {
        await _nicknameDs.save(inviteCode, alias);
      }
      final phone = phoneController.text.trim();
      if (phone.isNotEmpty) {
        await _phoneDs.save(inviteCode, phone);
      }

      // 뒤로 pop(result: true)만 한다 — Get.offNamed로 연결관리 라우트를 새로
      // push하면, 이미 연결관리 화면에서 "+"로 진입한 경우 기존에 살아있던
      // 연결관리 페이지(및 그 listScrollController) 위에 동일 컨트롤러를 공유하는
      // 페이지 인스턴스가 하나 더 쌓여 전환 애니메이션 중 같은 ScrollController에
      // ScrollPosition이 2개 붙는 크래시가 발생한다. 호출부(Dashboard/연결관리)가
      // 각자 .then()으로 목록을 재로드하므로 단순 pop으로 충분하다.
      // 성공 스낵바는 표시하지 않는다 — Get.snackbar 직후 Get.back()을 호출하면
      // 페이지가 아니라 스낵바 오버레이 쪽이 pop되어 화면이 안 넘어가는 문제가
      // 있었다(GetX 알려진 충돌). 목록 화면으로 돌아가 방금 추가한 대상자가
      // 바로 보이는 것 자체가 성공 확인이므로 스낵바 없이도 충분하다.
      Get.back(result: true);
    } catch (e) {
      final msg = e.toString().contains('404')
          ? 'add_subject_error_invalid_code'.tr
          : e.toString().contains('409')
              ? 'add_subject_error_already_connected'.tr
              : 'add_subject_error_failed'.tr;
      AppSnackbar.show('common_error'.tr, msg);
    } finally {
      isLoading = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    aliasController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
