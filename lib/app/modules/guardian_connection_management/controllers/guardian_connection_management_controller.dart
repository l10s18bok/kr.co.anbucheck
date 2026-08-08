import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/subject_phone_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 연결 관리 컨트롤러
/// PRD: 대상자 목록 편집, 추가/삭제
class GuardianConnectionManagementController extends BaseController {
  final _subjects = <ConnectedSubject>[].obs;
  List<ConnectedSubject> get subjects => _subjects;

  int get maxSubjects => _svc.maxSubjects.value;
  bool get canAddMore => _svc.canAddMore.value;

  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _phoneDs = SubjectPhoneLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    _loadSubjects(force: true);
  }

  Future<void> _loadSubjects({bool force = false}) async {
    isLoading = true;
    try {
      if (force) {
        await _svc.refresh();
      } else {
        await _svc.load();
      }
      _subjects.value = _svc.subjects.map((s) => ConnectedSubject(
            guardianId: s.guardianId,
            alias: s.alias,
            phone: s.phone,
            code: s.inviteCode,
            deviceId: s.deviceId,
            heartbeatHour: s.heartbeatHour,
            heartbeatMinute: s.heartbeatMinute,
          )).toList();
    } catch (_) {
      AppSnackbar.show('common_error'.tr, 'connection_load_failed'.tr);
    } finally {
      isLoading = false;
    }
  }

  void goToAddSubject() {
    Get.toNamed(AppRoutes.guardianAddSubject)
        ?.then((_) => _loadSubjects(force: true));
  }

  /// 별칭 + 연락처를 함께 저장 — 연락처는 선택 입력이라 비우면 삭제 처리
  Future<void> saveSubjectEdits(int index, String newAlias, String newPhone) async {
    final subject = _subjects[index];
    final trimmedAlias = newAlias.trim();
    if (trimmedAlias.isEmpty) return;
    await _nicknameDs.save(subject.code, trimmedAlias);
    _svc.updateAlias(subject.code, trimmedAlias);
    // 서버에도 반영 — Push 제목의 "누구의 알림인지" 표시에 쓰인다.
    // 이 경로는 서버 재조회를 하지 않으므로(로컬 캐시만 갱신) 직접 호출한다.
    // 실패해도 무시되며 다음 목록 로드에서 자동 재시도된다.
    unawaited(_svc.syncAliasesIfChanged());

    final trimmedPhone = newPhone.trim();
    if (trimmedPhone.isEmpty) {
      await _phoneDs.remove(subject.code);
    } else {
      await _phoneDs.save(subject.code, trimmedPhone);
    }
    final savedPhone = trimmedPhone.isEmpty ? null : trimmedPhone;
    _svc.updatePhone(subject.code, savedPhone);

    _subjects[index] = ConnectedSubject(
      guardianId: subject.guardianId,
      alias: trimmedAlias,
      phone: savedPhone,
      code: subject.code,
      deviceId: subject.deviceId,
      heartbeatHour: subject.heartbeatHour,
      heartbeatMinute: subject.heartbeatMinute,
    );
  }

  /// ReorderableListView 콜백 — 드래그 앤 드롭으로 표시 순서 변경
  Future<void> reorderSubjects(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    // ReorderableListView 규약: 아래로 이동 시 newIndex가 1 더 크게 들어옴
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = _subjects.removeAt(oldIndex);
    _subjects.insert(adjusted, moved);
    await _svc.reorder(_subjects.map((s) => s.code).toList());
  }

  Future<void> deleteSubject(int index) async {
    final subject = _subjects[index];
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    final confirm = await Get.dialog<bool>(
      _buildConfirmDialog(subject.alias),
    );
    if (confirm != true) return;

    isLoading = true;
    try {
      await _subjectDs.unlinkSubject(deviceToken, subject.guardianId);
      await _nicknameDs.remove(subject.code);
      await _phoneDs.remove(subject.code);
      _svc.removeByGuardianId(subject.guardianId);
      _subjects.removeAt(index);
      AppSnackbar.show('common_complete'.tr, 'connection_unlink_success'.tr);
    } catch (_) {
      AppSnackbar.show('common_error'.tr, 'connection_unlink_failed'.tr);
    } finally {
      isLoading = false;
    }
  }

  dynamic _buildConfirmDialog(String alias) {
    return _ConfirmUnlinkDialog(alias: alias);
  }
}

class _ConfirmUnlinkDialog extends StatelessWidget {
  final String alias;
  const _ConfirmUnlinkDialog({required this.alias});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('connection_unlink_title'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'connection_unlink_warning'.tr} ${'connection_unlink_warning_detail'.tr}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFFE65100), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('connection_unlink_confirm'.trParams({'alias': alias})),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('common_cancel'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('common_unlink'.tr),
        ),
      ],
    );
  }
}

class ConnectedSubject {
  final int guardianId;
  final String alias;
  final String? phone;
  final String code;
  final String? deviceId;
  final int heartbeatHour;
  final int heartbeatMinute;

  const ConnectedSubject({
    required this.guardianId,
    required this.alias,
    this.phone,
    required this.code,
    this.deviceId,
    this.heartbeatHour = 18,
    this.heartbeatMinute = 0,
  });
}
