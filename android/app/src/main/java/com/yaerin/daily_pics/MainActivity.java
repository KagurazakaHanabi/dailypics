package com.yaerin.daily_pics;

import android.os.Build;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        PlatformPlugin.registerWith(registrarFor("ml.cerasus.pics"));
        // FIXME 2019-08-16: 不应该在启动时申请所有权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{WRITE_EXTERNAL_STORAGE}, 1000);
        }
    }
}
