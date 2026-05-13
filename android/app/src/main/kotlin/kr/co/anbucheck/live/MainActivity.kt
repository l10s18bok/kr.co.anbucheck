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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
