package com.yaerin.daily_pics;

import android.Manifest;
import android.os.Build;
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            }, 1000);
        }
    }
}
