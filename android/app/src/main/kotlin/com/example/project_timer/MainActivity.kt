package com.example.project_timer

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "native_timezone").setMethodCallHandler {
            call, result ->
            if (call.method == "getLocalTimezone") {
                val tz = TimeZone.getDefault().id
                result.success(tz)
            } else {
                result.notImplemented()
            }
        }
    }
}
