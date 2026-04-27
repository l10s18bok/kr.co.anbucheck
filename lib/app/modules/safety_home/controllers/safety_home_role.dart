/// 안전 홈 페이지의 역할
///
/// - [subject]: 대상자 모드 — heartbeat 자동 전송 + Drawer + S 전용 (탈퇴/모드 전환).
///   Android 전용 (iOS는 보호자 전용 정책으로 진입 불가).
/// - [guardianSubject]: 보호자 겸 대상자(G+S) — heartbeat 자동 재전송은
///   `GuardianDashboardController`가 단독 소유하고, 이 모드는 UI 전용.
enum HomeRole {
  subject,
  guardianSubject,
}
