package kr.co.anbucheck.screen_state

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/// PowerManager.isInteractive() 조회만 제공하는 경량 플러그인.
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
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
