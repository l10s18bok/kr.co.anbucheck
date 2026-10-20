import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/widgets/resume_replay_mixin.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/controllers/guardian_connection_management_controller.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';
import 'package:anbucheck/app/core/widgets/glass_dialog.dart';

/// 보호자 연결 관리 페이지 — 시안 _4 기준
class GuardianConnectionManagementPage
    extends GetWidget<GuardianConnectionManagementController> {
  const GuardianConnectionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.link_rounded, size: 22.w, color: AppColors.onSurface),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'connection_title'.tr,
                  style: AppTextTheme.headlineSmall(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Obx(
          () => Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalMargin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.lg),

                    // 연결된 대상자 섹션
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${'connection_connected_subjects'.tr} ',
                                  style: AppTextTheme.headlineSmall(
                                    fw: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'connection_managed_count_value'
                                      .trParams({
                                        'current':
                                            '${controller.subjects.length}',
                                        'max': '${controller.maxSubjects}',
                                      }),
                                  style: AppTextTheme.headlineSmall(
                                    color: const Color(0xFF4355B9),
                                    fw: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.canAddMore)
                          GestureDetector(
                            onTap: controller.goToAddSubject,
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              size: 26.w,
                              color: const Color(0xFF4355B9),
                            ),
                          ),
                      ],
                    ),
                    // 안내 멘트는 2명 이상일 때만 표시 (1명 이하는 순서 변경 의미 없음)
                    if (controller.subjects.length >= 2) ...[
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '※',
                            style: AppTextTheme.bodySmall(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'connection_reorder_hint'.tr,
                              style: AppTextTheme.bodySmall(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                    ] else
                      SizedBox(height: AppSpacing.lg),

                    // 대상자 리스트 (남은 공간 채움, 내부 스크롤)
                    Expanded(
                      child: Container(
                        // 리스트 영역을 별도 패널로 띄우지 않고 바탕화면과 같은 색으로 둔다
                        // — 카드(surfaceContainerLowest = 흰색)만 떠 보이게 하려는 의도.
                        color: AppColors.surface,
                        child: controller.subjects.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 80.w,
                                      color: AppColors.textTertiary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    Text(
                                      'connection_empty'.tr,
                                      style: AppTextTheme.bodyLarge(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _SubjectReorderableList(
                                subjects: controller.subjects,
                                onReorder: controller.reorderSubjects,
                                onSave: controller.saveSubjectEdits,
                                onDelete: controller.deleteSubject,
                              ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              if (controller.isLoading)
                Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4355B9)),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: const GuardianBottomNav(currentIndex: 1),
      ),
    );
  }
}

/// 대상자 리스트 스크롤 영역 — ScrollController를 State에 직접 소유한다.
/// (GetX 컨트롤러에 두면 컨트롤러 생명주기가 위젯과 1:1이 아니라서, 라우트
/// 전환 애니메이션 도중 같은 컨트롤러를 공유하는 위젯 인스턴스가 동시에 존재하는
/// 순간 하나의 ScrollController에 ScrollPosition이 2개 붙어 Scrollbar
/// thumbVisibility 어서션이 깨지는 크래시가 있었다. State 소유로 바꾸면 위젯
/// 인스턴스마다 자기 ScrollController를 가지므로 이 충돌이 구조적으로 불가능해진다.)
class _SubjectReorderableList extends StatefulWidget {
  final List<ConnectedSubject> subjects;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index, String newAlias, String newPhone)
  onSave;
  final void Function(int index) onDelete;

  const _SubjectReorderableList({
    required this.subjects,
    required this.onReorder,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_SubjectReorderableList> createState() =>
      _SubjectReorderableListState();
}

class _SubjectReorderableListState extends State<_SubjectReorderableList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// long-press drag 시작 시 카드를 살짝 들어올린 듯한 효과
  /// (스케일 + soft shadow 가 점진적으로 적용)
  Widget _buildDragProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(animation.value);
        final scale = 1 + 0.03 * t;
        final elevation = 8 * t;
        return Transform.scale(
          scale: scale,
          child: Material(
            elevation: elevation,
            color: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14.r),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scrollbar는 MediaQuery.padding(세이프 에리어)만큼 썸을 안쪽으로 민다 — Duo처럼 카메라 쪽에
    // 좌우 인셋이 큰 화면에서는 썸이 카드 한가운데에 세로줄로 떠 버린다. 좌우 인셋을 지워 썸을
    // 리스트 오른쪽 끝(이미 padding.right로 비워 둔 자리)에 붙인다. 폰은 좌우 인셋이 0이라 변화 없음.
    return MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeRight: true,
      child: Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        // 우측만 여백 — thumbVisibility 스크롤바가 카드 우측 끝에 겹쳐 그려지는 것을 피한다
        // (Material 스크롤바 두께 8 + 여유 4). 상하·좌측은 0이라 카드가 리스트 영역을
        // 꽉 채우고, 카드 사이 간격은 _SubjectListTile이 각자 bottom 여백으로 갖는다.
        padding: EdgeInsets.only(right: AppSpacing.md),
        itemCount: widget.subjects.length,
        buildDefaultDragHandles: false,
        onReorder: widget.onReorder,
        proxyDecorator: _buildDragProxy,
        autoScrollerVelocityScalar: 4.0,
        itemBuilder: (_, index) {
          final subject = widget.subjects[index];
          return _PopInEntrance(
            // ReorderableListView는 최상위 자식의 key로 항목을 식별한다.
            // code 기준 State라 순서를 바꿔도 연출이 다시 재생되지 않는다.
            key: ValueKey(subject.code),
            index: index,
            child: _SubjectListTile(
            key: ValueKey('tile_${subject.code}'),
            index: index,
            alias: subject.alias,
            phone: subject.phone,
            code: subject.code,
            heartbeatHour: subject.heartbeatHour,
            heartbeatMinute: subject.heartbeatMinute,
            hasDevice: subject.deviceId != null,
            onSave: (newAlias, newPhone) =>
                widget.onSave(index, newAlias, newPhone),
            onDelete: () => widget.onDelete(index),
            ),
          );
        },
      ),
      ),
    );
  }
}

/// 목록 진입 연출 — 카드가 아래에서 떠오르며 살짝 커지는(pop-in) 슬라이드+스케일+페이드.
/// 위에서부터 시차를 두고 재생한다(알림 목록의 좌·우 지그재그와 구분되는 연출).
/// 시차는 [_maxStaggerIndex]로 제한해 화면 밖 카드 때문에 길어지지 않게 한다.
class _PopInEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const _PopInEntrance({super.key, required this.index, required this.child});

  @override
  State<_PopInEntrance> createState() => _PopInEntranceState();
}

class _PopInEntranceState extends State<_PopInEntrance>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, ResumeReplayMixin {
  static const int _maxStaggerIndex = 6;
  static const Duration _stagger = Duration(milliseconds: 110);

  late final AnimationController _ctrl;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _play();
  }

  Timer? _timer;

  /// 처음부터 재생 — 위에서부터 시차를 두고 시작한다.
  void _play() {
    _timer?.cancel();
    _ctrl.value = 0;
    final i = widget.index > _maxStaggerIndex ? _maxStaggerIndex : widget.index;
    _timer = Timer(_stagger * i, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void replayOnResume() => _play();

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // easeOutBack은 1을 넘겨 튀므로 opacity는 0~1로 제한한 별도 곡선을 쓴다.
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_curve),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(_curve),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SubjectListTile extends StatelessWidget {
  final int index;
  final String alias;
  final String? phone;
  final String code;
  final int heartbeatHour;
  final int heartbeatMinute;
  final bool hasDevice;
  final Future<void> Function(String newAlias, String newPhone) onSave;
  final VoidCallback onDelete;

  const _SubjectListTile({
    super.key,
    required this.index,
    required this.alias,
    this.phone,
    required this.code,
    required this.heartbeatHour,
    required this.heartbeatMinute,
    required this.hasDevice,
    required this.onSave,
    required this.onDelete,
  });

  /// "안부 보고시간은 [보호 대상자] 앱에서만 변경 가능합니다" — 라벨만 굵게.
  /// 언어마다 어순이 달라 문장을 조각으로 이어 붙이지 않고, 번역문 안의
  /// `@label` 위치에 라벨을 끼워 넣는다.
  List<TextSpan> _timeChangeNoteSpans() {
    final parts = 'connection_time_change_note'.tr.split('@label');
    final label = TextSpan(
      text: 'connection_subject_label'.tr,
      style: AppTextTheme.labelSmall(color: Colors.white, fw: FontWeight.w600),
    );
    return [
      TextSpan(text: parts.first),
      if (parts.length > 1) ...[label, TextSpan(text: parts.sublist(1).join())],
    ];
  }

  String get _timeLabel {
    return 'connection_heartbeat_schedule'.trParams({
      'time': formatTimeOfDay(heartbeatHour, heartbeatMinute),
    });
  }

  void _openEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => GlassBackdrop(
        child: _EditSubjectDialog(alias: alias, phone: phone, onSave: onSave),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          // 상단 카드: 대상자 정보
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: hasDevice
                  ? BorderRadius.vertical(top: Radius.circular(14.r))
                  : BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                // 편집/삭제 아이콘을 제외한 좌측 영역 long-press drag 시작 영역
                Expanded(
                  child: ReorderableDelayedDragStartListener(
                    index: index,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(
                            Icons.person,
                            size: 22.w,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alias,
                                style: AppTextTheme.bodyLarge(
                                  fw: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                code,
                                style: AppTextTheme.bodySmall(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              if (hasDevice) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  _timeLabel,
                                  style: AppTextTheme.bodySmall(
                                    color: const Color(0xFF4355B9),
                                    fw: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _openEditDialog(context),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20.w,
                    color: const Color(0xFF4355B9),
                  ),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20.w,
                    color: AppColors.error,
                  ),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
              ],
            ),
          ),
          // 하단 카드: 안부 보고시간 안내 — long-press drag 시작 영역 포함
          if (hasDevice)
            ReorderableDelayedDragStartListener(
              index: index,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4355B9),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14.r),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: AppTextTheme.labelSmall(color: Colors.white70),
                    children: _timeChangeNoteSpans(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditSubjectDialog extends StatefulWidget {
  final String alias;
  final String? phone;
  final Future<void> Function(String newAlias, String newPhone) onSave;

  const _EditSubjectDialog({
    required this.alias,
    this.phone,
    required this.onSave,
  });

  @override
  State<_EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<_EditSubjectDialog> {
  late final TextEditingController _aliasController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.alias);
    _phoneController = TextEditingController(text: widget.phone ?? '');
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newAlias = _aliasController.text.trim();
    if (newAlias.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final newPhone = _phoneController.text.trim();
    if (newAlias != widget.alias || newPhone != (widget.phone ?? '')) {
      await widget.onSave(newAlias, newPhone);
    }
    if (mounted) Navigator.pop(context);
  }

  InputDecoration _fieldDecoration(String hint, bool dark) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextTheme.bodyLarge(
      color: dark ? const Color(0xFF8E9096) : const Color(0xFF9A9CA3),
    ),
    filled: true,
    // 글래스 카드 위에서는 불투명 회색 대신 반투명 면으로 — 뒤 블러가 은은하게 비친다.
    fillColor: dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: AppColors.guardianPrimary, width: 1.5),
    ),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    final textColor = dark ? Colors.white : const Color(0xFF1A1C1C);
    final subColor = dark ? const Color(0xFFB0B3BA) : const Color(0xFF5F6168);
    return GlassDialogCard(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'connection_edit_title'.tr,
                  style: AppTextTheme.headlineSmall(color: textColor),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'connection_alias_label'.tr,
                  style: AppTextTheme.labelMedium(color: subColor),
                ),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _aliasController,
                  // 서버가 20자에서 절단하므로(Push 본문에 실리는 값) 입력도 맞춘다.
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  cursorColor: AppColors.guardianPrimary,
                  decoration: _fieldDecoration(widget.alias, dark),
                  style: AppTextTheme.bodyLarge(color: textColor),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'add_subject_phone_label'.tr,
                  style: AppTextTheme.labelMedium(color: subColor),
                ),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _phoneController,
                  cursorColor: AppColors.guardianPrimary,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                  decoration: _fieldDecoration('add_subject_phone_hint'.tr, dark),
                  style: AppTextTheme.bodyLarge(color: textColor),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 14.w,
                        color: subColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'add_subject_phone_info'.tr,
                        style: AppTextTheme.bodySmall(color: subColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        // 앱 테마가 버튼 최소 크기를 가로 무한대·높이 64로 잡아 두므로(Row 안에서
                        // 무한 폭 예외) 다이얼로그 버튼은 직접 지정한다.
                        minimumSize: Size(0, 48.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'common_cancel'.tr,
                        style: AppTextTheme.bodyMedium(color: subColor),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(0, 48.h),
                        backgroundColor: AppColors.guardianPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'common_save'.tr,
                        style: AppTextTheme.bodyMedium(
                          color: Colors.white,
                          fw: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
