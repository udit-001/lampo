package com.lampo

import android.Manifest
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "com.lampo/wifi_band"
        const val PERMISSION_REQUEST_CODE = 1001
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWifiBand" -> {
                        if (hasLocationPermission()) {
                            result.success(getWifiBand())
                        } else {
                            pendingResult = result
                            requestPermissions(
                                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                                PERMISSION_REQUEST_CODE
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pendingResult?.success(getWifiBand())
            } else {
                pendingResult?.success("unknown")
            }
            pendingResult = null
        }
    }

    private fun hasLocationPermission(): Boolean {
        return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED
    }

    private fun getWifiBand(): String {
        try {
            val wifiInfo: WifiInfo? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val cm = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
                val network = cm.activeNetwork
                val caps = cm.getNetworkCapabilities(network)
                caps?.transportInfo as? WifiInfo
            } else {
                val wm = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
                @Suppress("DEPRECATION")
                wm.connectionInfo
            }

            val frequency = wifiInfo?.frequency ?: 0
            return when {
                frequency in 2400..2500 -> "2.4GHz"
                frequency in 4900..5900 -> "5GHz"
                frequency in 5925..7125 -> "6GHz"
                else -> "unknown"
            }
        } catch (_: Exception) {
            return "unknown"
        }
    }
}
