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
    private fun checkMockLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Android 6+: cek via Settings.Secure.ALLOW_MOCK_LOCATION sudah deprecated
            // Deteksi berdasarkan mock location app yang memiliki permission
            try {
                val pm = packageManager
                val packages = pm.getInstalledApplications(0)
                packages.any { appInfo ->
                    try {
                        pm.checkPermission(
                            "android.permission.ACCESS_MOCK_LOCATION",
                            appInfo.packageName
                        ) == android.content.pm.PackageManager.PERMISSION_GRANTED &&
                        appInfo.packageName != packageName
                    } catch (e: Exception) {
                        false
                    }
                }
            } catch (e: Exception) {
                false
            }
        } else {
            @Suppress("DEPRECATION")
            Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ALLOW_MOCK_LOCATION,
                0
            ) != 0
        }
    }
}
