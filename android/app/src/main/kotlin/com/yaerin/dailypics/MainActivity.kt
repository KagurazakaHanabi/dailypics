package com.yaerin.dailypics

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull engine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(engine)
        engine.plugins.add(PlatformPlugin())
    }
}
