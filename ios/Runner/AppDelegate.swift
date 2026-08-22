import Flutter
import UIKit
import UserNotifications
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS G+S는 BGTaskScheduler / WorkManager 백그라운드 태스크를 사용하지 않음
    // 로컬 알림(UserNotifications) + 앱 열기 자동 전송만으로 동작

    // Google Maps SDK 초기화 — Info.plist의 GMSApiKey에서 키 로드
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty, key != "YOUR_IOS_MAPS_API_KEY" {
      GMSServices.provideAPIKey(key)
    }

    // Flutter 엔진 + Firebase + 플러그인 초기화
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 포그라운드 알림 배너 표시를 위해 delegate 설정
    UNUserNotificationCenter.current().delegate = self

    // Firebase 초기화 완료 후 APNs 등록
    application.registerForRemoteNotifications()

    // ── [probe/ios-nse] 오프라인 폴백 알림 사전 무장 (프로브 전용) ──────
    // Q2 검증용: **앱 프로세스가** 심어둔 pending 요청을 나중에 **확장 프로세스가**
    // 지울 수 있는지 본다. 같은 호출에서 심고 지우면 아무것도 증명하지 못한다.
    // 본 구현에서는 "예약시각 +15분 오프라인 알림"이 이 자리에 온다.
    // [probe/ios-nse] 알림 권한을 런치 즉시 요청한다.
    // 시뮬레이터는 simctl로 알림 권한을 미리 줄 수 없고, 권한이 없으면 푸시가
    // 폐기되어 확장 자체가 실행되지 않는다 → 검증이 성립하지 않는다.
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
      NSLog("[PROBE] notification auth: %@", ok ? "granted" : "denied")
    }
    armProbeOfflineNotification()

    return result
  }

  /// [probe/ios-nse] 15분 뒤 발화하는 오프라인 폴백 알림을 심는다.
  /// 확장이 이걸 pending에서 제거하지 못하면 화면에 그대로 뜬다 = Q2 실패.
  private func armProbeOfflineNotification() {
    let content = UNMutableNotificationContent()
    content.title = "PROBE-OFFLINE (앱이 심음)"
    content.body = "확장이 지우지 못하면 이 알림이 그대로 발화한다."
    let req = UNNotificationRequest(
      identifier: "probe-offline",
      content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 900, repeats: false)
    )
    UNUserNotificationCenter.current().add(req) { err in
      NSLog("[PROBE] arm probe-offline: %@", err == nil ? "ok" : err!.localizedDescription)
    }
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
  // FCM 푸시만 대시보드 갱신 트리거 — 오늘의 안부 확인 메시지 로컬 알림(gs_deadman)은 제외
  // FCM 메시지는 gcm.message_id 필드를 항상 포함하므로 이를 구분자로 사용
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    let isFcmPush = userInfo["gcm.message_id"] != nil
    if isFcmPush, let vc = getFlutterVC() {
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
      // Dart에서 lat/lng 등 부가 데이터까지 라우팅 분기에 활용하도록 userInfo 전체를
      // JSON 문자열로 전달. FCM이 내부적으로 추가하는 비-JSON 키가 섞여 있을 수 있으므로,
      // 문자열 value만 선별하고 실패 시 type 문자열로 폴백.
      var payload: String = type
      var stringMap: [String: String] = [:]
      for (k, v) in userInfo {
        if let key = k as? String, let value = v as? String {
          stringMap[key] = value
        }
      }
      if !stringMap.isEmpty,
         let jsonData = try? JSONSerialization.data(withJSONObject: stringMap, options: []),
         let jsonStr = String(data: jsonData, encoding: .utf8) {
        payload = jsonStr
      }
      let channel = FlutterMethodChannel(name: "kr.co.anbucheck/fcm", binaryMessenger: vc.engine.binaryMessenger)
      channel.invokeMethod("onNotificationTap", arguments: payload)
    }

    // firebase_messaging에도 위임 (종료 상태에서 getInitialMessage 경로 보존 + 플러그인 체인)
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  /// 표시 중인 알림 정리 채널 — 엔진 수명 동안 유지해야 하므로 프로퍼티로 보관.
  private var notificationChannel: FlutterMethodChannel?

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // 앱 포그라운드 진입 시 트레이에 쌓인 알림을 일괄 정리하는 채널.
    // getFlutterVC()는 scene 기반 앱에서 런치 직후 nil일 수 있으므로,
    // 엔진 초기화 시점의 applicationRegistrar.messenger()로 등록한다.
    //
    // ⚠️ **removeAllDeliveredNotifications만 호출한다.**
    //   removeAllPendingNotificationRequests를 절대 함께 부르지 말 것 —
    //   iOS 일일 안전망 알림(gs_deadman, matchDateTimeComponents.time)은
    //   pending 반복 요청으로 남아 있어야 매일 발화하며, 이것이 iOS G+S의
    //   PRIMARY heartbeat 트리거다. pending을 지우면 iOS 안부 전송이 조용히 죽는다.
    //   (무료체험 종료 trial_ended 단발 예약도 동일하게 pending으로 살아있어야 한다.)
    let channel = FlutterMethodChannel(
      name: "kr.co.anbucheck/notifications",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "clearDelivered" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let center = UNUserNotificationCenter.current()
      center.removeAllDeliveredNotifications()
      if #available(iOS 16.0, *) {
        center.setBadgeCount(0)
      } else {
        UIApplication.shared.applicationIconBadgeNumber = 0
      }
      result(nil)
    }
    notificationChannel = channel
  }
}
