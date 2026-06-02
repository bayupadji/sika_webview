package com.example.sika

import android.app.DownloadManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val DOWNLOAD_CHANNEL = "com.sika.download"
    private val SECURITY_CHANNEL = "com.sika.security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─── Download Channel ───────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOWNLOAD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFileToDownloads" -> {
                    val url = call.argument<String>("url")
                    val fileName = call.argument<String>("fileName")
                    try {
                        val request = DownloadManager.Request(Uri.parse(url))
                        request.setTitle(fileName)
                        request.setDescription("Downloading...")
                        request.setNotificationVisibility(
                            DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
                        )
                        request.setDestinationInExternalPublicDir(
                            Environment.DIRECTORY_DOWNLOADS,
                            fileName
                        )
                        val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                        dm.enqueue(request)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("DOWNLOAD_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ─── Security Channel ───────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SECURITY_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "isVpnActive" -> {
                    result.success(checkVpnActive())
                }

                "isDeveloperModeEnabled" -> {
                    result.success(checkDeveloperMode())
                }

                "isMockLocationEnabled" -> {
                    result.success(checkMockLocationEnabled())
                }

                "getAndroidSdkInfo" -> {
                    val sdkInt = Build.VERSION.SDK_INT
                    var isWebViewAvailable = false
                    try {
                        val webviewPackage = android.webkit.WebView.getCurrentWebViewPackage()
                        isWebViewAvailable = webviewPackage != null
                    } catch (e: Exception) {
                        isWebViewAvailable = false
                    }
                    val info = mapOf(
                        "sdkInt" to sdkInt,
                        "isWebViewAvailable" to isWebViewAvailable
                    )
                    result.success(info)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ─── VPN Detection ─────────────────────────────────────────────────────
    private fun checkVpnActive(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
    }

    // ─── Developer Mode Detection ──────────────────────────────────────────
    private fun checkDeveloperMode(): Boolean {
        return Settings.Global.getInt(
            contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
            0
        ) != 0
    }

    // ─── Mock Location Detection ───────────────────────────────────────────
    // Strategi per API level:
    //
    // API < 18 (pre-JellyBean 4.3):
    //   Gunakan Settings.Secure.ALLOW_MOCK_LOCATION (masih berlaku).
    //
    // API 18-30 (JellyBean 4.3 s/d Android 11):
    //   Settings.Secure.ALLOW_MOCK_LOCATION sudah deprecated tapi masih
    //   bisa dibaca pada sebagian device. Namun di banyak device Android 6+
    //   nilainya selalu 0, jadi kurang reliable.
    //   Sebelumnya kita scan installed apps untuk ACCESS_MOCK_LOCATION
    //   permission — tapi ini menyebabkan FALSE POSITIVE karena banyak
    //   system app (Google Play Services, dsb.) punya permission itu
    //   secara default.
    //   Solusi: untuk API 18-30, kembalikan false di native layer dan
    //   andalkan deteksi di Dart layer via LocationData.isMock dan
    //   detect_fake_location plugin yang lebih akurat.
    //
    // API 31+ (Android 12+):
    //   Location.isMock() tersedia dan reliable. Deteksi dilakukan
    //   di Dart layer via LocationData.isMock flag.
    //
    private fun checkMockLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
            // Pre-4.3: cek setting lama
            @Suppress("DEPRECATION")
            Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ALLOW_MOCK_LOCATION,
                0
            ) != 0
        } else {
            // API 18+: native setting tidak reliable, serahkan ke Dart layer
            // (LocationData.isMock + detect_fake_location plugin)
            false
        }
    }
}
