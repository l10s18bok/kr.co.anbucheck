import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Silent Push (content-available) 백그라운드 수신 등록
    application.registerForRemoteNotifications()

    // WorkManager 백그라운드 FlutterEngine에 플러그인 등록
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // BGProcessingTask 등록 (registerProcessingTask에서 사용)
    // Info.plist의 BGTaskSchedulerPermittedIdentifiers와 일치해야 함
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "workmanager.background.task")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
