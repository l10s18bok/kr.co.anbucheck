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

    // ⚠️ 확장이 남긴 전송 마커를 **Flutter 엔진 시작보다 먼저** 흡수한다.
    // 늦으면 Dart가 첫 조회에서 옛 값을 읽어 "오늘 미전송"으로 판단하고 중복 전송한다.
    SharedStore.importFromExtension()

    // Flutter 엔진 + Firebase + 플러그인 초기화
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 확장이 쓸 값(device_token·예약시각 등)을 App Group으로 내보낸다
    SharedStore.exportToExtension()

    // 포그라운드 알림 배너 표시를 위해 delegate 설정
    UNUserNotificationCenter.current().delegate = self

    // Firebase 초기화 완료 후 APNs 등록
    application.registerForRemoteNotifications()

    return result
  }

  /// 백그라운드 진입 시 최신값을 확장에 넘긴다.
  /// 확장은 앱이 없는 동안 실행되므로, 이 시점의 값이 확장이 보게 될 값이다.
  override func applicationDidEnterBackground(_ application: UIApplication) {
    SharedStore.exportToExtension()
    super.applicationDidEnterBackground(application)
  }

  /// 포그라운드 복귀 시 확장이 보낸 사실을 먼저 흡수한다(Dart의 onResumed보다 앞선다).
  override func applicationWillEnterForeground(_ application: UIApplication) {
    SharedStore.importFromExtension()
    super.applicationWillEnterForeground(application)
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
    //   iOS 오프라인 폴백 알림(anbu_offline_<날짜>)은 pending으로 살아 있어야
    //   **망이 없는 날** 발화한다 — 그날 사용자에게 안부 전송을 알릴 유일한 수단이다
    //   (푸시는 망이 있어야 도착하므로 그 역할을 대신할 수 없다).
    //   (무료체험 종료 trial_ended 단발 예약도 동일하게 pending으로 살아있어야 한다.)
    let channel = FlutterMethodChannel(
      name: "kr.co.anbucheck/notifications",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      // 오프라인 폴백 알림 롤링 재무장 — Dart LocalAlarmService.schedule()이 호출한다.
      // 구현은 앱·확장이 공유하는 HeartbeatStore에 있다(확장도 전송 성공 시 같은 함수를
      // 부른다 — 두 벌로 나누면 규칙이 어긋난다).
      if call.method == "armOfflineFallback" {
        let args = call.arguments as? [String: Any]
        let hour = args?["hour"] as? Int ?? 18
        let minute = args?["minute"] as? Int ?? 0
        // ⚠️ 폴백 재무장 **직전에** 최신값을 확장으로 밀어 넣는다.
        // 이 채널은 예약시각이 바뀐 순간에도 호출되는데, export를 다음 백그라운드
        // 진입까지 미루면 그 사이 확장이 **옛 예약시각으로 scheduled_key**를 만든다.
        SharedStore.exportToExtension()
        HeartbeatStore.rearmOfflineFallback(hour: hour, minute: minute)
        result(nil)
        return
      }

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
