import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 연결 관리 컨트롤러
/// PRD: 대상자 목록 편집, 추가/삭제
class GuardianConnectionManagementController extends BaseController {
  final _subjects = <ConnectedSubject>[].obs;
  List<ConnectedSubject> get subjects => _subjects;

  int get maxSubjects => _svc.maxSubjects.value;

  final listScrollController = ScrollController();

  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    _loadSubjects(force: true);
  }

  @override
  void onClose() {
    listScrollController.dispose();
    super.onClose();
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
            code: s.inviteCode,
            deviceId: s.deviceId,
            heartbeatHour: s.heartbeatHour,
            heartbeatMinute: s.heartbeatMinute,
          )).toList();
    } catch (_) {
      Get.snackbar('오류', '목록을 불러오지 못했습니다.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
    }
  }

  void goToAddSubject() {
    Get.toNamed(AppRoutes.guardianAddSubject)
        ?.then((_) => _loadSubjects(force: true));
  }

  Future<void> saveAlias(int index, String newAlias) async {
    final subject = _subjects[index];
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty) return;
    await _nicknameDs.save(subject.code, trimmed);
    _svc.updateAlias(subject.code, trimmed);
    _subjects[index] = ConnectedSubject(
      guardianId: subject.guardianId,
      alias: trimmed,
      code: subject.code,
      deviceId: subject.deviceId,
      heartbeatHour: subject.heartbeatHour,
      heartbeatMinute: subject.heartbeatMinute,
    );
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
      _svc.removeByGuardianId(subject.guardianId);
      _subjects.removeAt(index);
      Get.snackbar('완료', '연결이 해제되었습니다.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('오류', '연결 해제에 실패했습니다.',
          snackPosition: SnackPosition.BOTTOM);
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
      title: const Text('연결 해제'),
      content: Text('$alias 연결을 해제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('해제'),
        ),
      ],
    );
  }
}

class ConnectedSubject {
  final int guardianId;
  final String alias;
  final String code;
  final String? deviceId;
  final int heartbeatHour;
  final int heartbeatMinute;

  const ConnectedSubject({
    required this.guardianId,
    required this.alias,
    required this.code,
    this.deviceId,
    this.heartbeatHour = 9,
    this.heartbeatMinute = 30,
  });
}
