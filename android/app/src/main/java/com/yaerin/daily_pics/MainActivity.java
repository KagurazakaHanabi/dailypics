package com.yaerin.daily_pics;

import android.os.Bundle;

import com.yaerin.daily_pics.plugins.PlatformPlugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        PlatformPlugin.registerWith(registrarFor("ml.cerasus.pics"));
    }
}
