package com.example.finger_print_practice

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "biometric_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "performSigning") {
                    val data = call.argument<String>("data")
                    val signature = performSigning(data)
                    result.success(signature)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun performSigning(data: String?): String {
        if (data != null) {
            try {
                val messageBytes = data.toByteArray() // Convert data to bytes
                val digest = MessageDigest.getInstance("SHA-256")
                val hashedBytes = digest.digest(messageBytes) // Generate hash of the data
                val signature = bytesToHex(hashedBytes) // Convert bytes to a hexadecimal string
                return signature
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return "DefaultSignature"
    }

    private fun bytesToHex(bytes: ByteArray): String {
        val hexArray = "0123456789ABCDEF".toCharArray()
        val hexChars = CharArray(bytes.size * 2)
        for (i in bytes.indices) {
            val v = bytes[i].toInt() and 0xFF
            hexChars[i * 2] = hexArray[v ushr 4]
            hexChars[i * 2 + 1] = hexArray[v and 0x0F]
        }
        return String(hexChars)
    }
}
