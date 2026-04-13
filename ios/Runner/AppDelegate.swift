import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS G+S는 BGTaskScheduler / WorkManager 백그라운드 태스크를 사용하지 않음
    // 로컬 알림(UserNotifications) + 앱 열기 자동 전송만으로 동작

    // Flutter 엔진 + Firebase + 플러그인 초기화
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 포그라운드 알림 배너 표시를 위해 delegate 설정
    UNUserNotificationCenter.current().delegate = self

    // Firebase 초기화 완료 후 APNs 등록
    application.registerForRemoteNotifications()

    return result
  }

  /// SceneDelegate 환경에서 FlutterViewController 조회
  private func getFlutterVC() -> FlutterViewController? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController as? FlutterViewController
  }

  // 포그라운드에서 알림 수신 시 배너 표시 + Dart에 대시보드 갱신 전달
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if let vc = getFlutterVC() {
      let channel = FlutterMethodChannel(name: "kr.co.anbucheck/fcm", binaryMessenger: vc.engine.binaryMessenger)
      channel.invokeMethod("onForegroundMessage", arguments: NSNull())
    }
    completionHandler([.banner, .list, .sound, .badge])
  }

  // 알림 탭 시 처리
  // firebase_messaging iOS 플러그인은 FlutterSceneDelegate(scene-based 앱)를 지원하지 않아
  // onMessageOpenedApp / getInitialMessage()가 백그라운드/종료 상태에서 동작하지 않음
  // (FlutterFire #13212, #12398, #10356 — 공식 수정 미정)
  // → 포그라운드/백그라운드/종료 상태 모두 MethodChannel로 직접 Dart에 전달
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    let type = userInfo["type"] as? String ?? ""

    if let vc = getFlutterVC() {
      let channel = FlutterMethodChannel(name: "kr.co.anbucheck/fcm", binaryMessenger: vc.engine.binaryMessenger)
      channel.invokeMethod("onNotificationTap", arguments: type)
    }

    // firebase_messaging에도 위임 (종료 상태에서 getInitialMessage 경로 보존 + 플러그인 체인)
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
