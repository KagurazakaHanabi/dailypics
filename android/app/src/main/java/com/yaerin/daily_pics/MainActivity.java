package com.yaerin.daily_pics;

import android.Manifest;
import android.os.Build;
import android.os.Bundle;

import com.yaerin.daily_pics.plugins.PlatformPlugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.content.pm.PackageManager.PERMISSION_GRANTED;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        PlatformPlugin.registerWith(registrarFor("ml.cerasus.pics"));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(Manifest.permission_group.STORAGE) != PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission_group.STORAGE}, 100);
            }
        }
    }
}
