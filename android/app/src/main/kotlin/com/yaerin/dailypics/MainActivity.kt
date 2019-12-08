package com.yaerin.dailypics

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull engine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(engine)
        val registry = ShimPluginRegistry(engine)
        PlatformPlugin.registerWith(registry.registrarFor("ml.cerasus.pics"))
    }
}
