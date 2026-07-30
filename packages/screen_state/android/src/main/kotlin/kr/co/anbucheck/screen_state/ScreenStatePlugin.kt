package kr.co.anbucheck.screen_state

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/// PowerManager.isInteractive() 조회 및 알림 취소를 제공하는 경량 플러그인.
///
/// WorkManager가 생성하는 백그라운드 FlutterEngine에서도 동작하도록
/// FlutterPlugin 인터페이스로 구현 — GeneratedPluginRegistrant가 UI/백그라운드
/// 양쪽 엔진 모두에 자동 등록한다.
class ScreenStatePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "kr.co.anbucheck/screen_state")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isInteractive" -> {
                val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                result.success(pm.isInteractive)
            }
            "cancelNotificationsByTag" -> {
                val tag = call.argument<String>("tag")
                var matchedCount = 0
                if (tag != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val matched = nm.activeNotifications.filter { it.tag == tag }
                    matchedCount = matched.size
                    matched.forEach { nm.cancel(it.tag, it.id) }
                    // Samsung One UI 등 일부 OEM에서 백그라운드 컨텍스트의
                    // activeNotifications가 FCM 수신 알림을 누락하는 경우가 있다.
                    // FCM은 explicit id 없이 tagged 알림을 항상 id=0으로 발행하므로
                    // matched 0건이면 직접 취소한다(no-op if not present).
                    if (matchedCount == 0) {
                        nm.cancel(tag, 0)
                    }
                }
                result.success(matchedCount)
            }
            "clearDeliveredNotifications" -> {
                // 앱 포그라운드 진입 시 트레이에 쌓인 알림 일괄 정리.
                // NotificationManager.cancelAll()은 **이미 표시된(posted) 알림만** 제거한다.
                // flutter_local_notifications의 zonedSchedule 예약분은 AlarmManager
                // PendingIntent라 아직 post되지 않았으므로 영향받지 않는다
                // (trial_ended 단발 예약 등이 살아남아야 한다).
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.cancelAll()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
