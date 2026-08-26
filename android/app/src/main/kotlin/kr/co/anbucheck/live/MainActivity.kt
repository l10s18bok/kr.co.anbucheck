package kr.co.anbucheck.live

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val hibernationChannel = "anbucheck/hibernation"
    private val deviceIdChannel = "anbucheck/device_id"

    // Doze 관통 알람 실측 프로브 (Phase 1). 포그라운드 전용 채널이면 충분하다 —
    // 리시버가 발화 때마다 스스로 다음 날로 재무장하므로 1회만 무장하면 된다.
    private val heartbeatAlarmChannel = "anbucheck/heartbeat_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceIdChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Settings.Secure.ANDROID_ID(SSAID) — 기기별 고유값, 공장 초기화 시에만 변경.
                    // device_info_plus의 AndroidDeviceInfo.id는 Build.ID(펌웨어 빌드 식별자)라
                    // 같은 기종·같은 빌드의 모든 기기가 동일한 값을 반환하므로 사용 금지.
                    "getAndroidId" -> {
                        val id = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                        result.success(id)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, heartbeatAlarmChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "arm" -> {
                        val hour = call.argument<Int>("hour") ?: 18
                        val minute = call.argument<Int>("minute") ?: 0
                        HeartbeatAlarmReceiver.arm(applicationContext, hour, minute)
                        result.success(true)
                    }
                    "cancel" -> {
                        HeartbeatAlarmReceiver.cancel(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, hibernationChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAutoRevokeWhitelisted" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            result.success(packageManager.isAutoRevokeWhitelisted)
                        } else {
                            result.success(true)
                        }
                    }
                    "isBatteryUnrestricted" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "openBatterySettings" -> {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "openAutoRevokeSettings" -> {
                        val opened = openAutoRevokeSettings()
                        result.success(opened)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// API 30+ 에서는 자동 권한 회수 토글 화면으로 직행, 미지원/실패 시 앱 정보 페이지로 폴백
    private fun openAutoRevokeSettings(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(Intent.ACTION_AUTO_REVOKE_PERMISSIONS).apply {
                    data = Uri.fromParts("package", packageName, null)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                return true
            } catch (e: ActivityNotFoundException) {
                // OEM 가로채기 실패 → 폴백
            } catch (e: Exception) {
                // 폴백
            }
        }
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }
}
