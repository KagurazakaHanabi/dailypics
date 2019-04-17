package com.yaerin.daily_pics.plugins;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;

import com.yaerin.daily_pics.util.WallpaperHelper;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.os.Environment.DIRECTORY_PICTURES;
import static android.os.Environment.getExternalStoragePublicDirectory;

/**
 * Create by Yaerin on 2019/2/18
 *
 * @author Yaerin
 */
public class PlatformPlugin implements MethodCallHandler {
    private final Registrar mRegistrar;

    private PlatformPlugin(Registrar registrar) {
        this.mRegistrar = registrar;
    }

    public static void registerWith(Registrar registrar) {
        MethodChannel channel = new MethodChannel(registrar.messenger(), "ml.cerasus.pics");
        PlatformPlugin instance = new PlatformPlugin(registrar);
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        try {
            switch (call.method) {
                case "setWallpaper": {
                    new Thread(() -> {
                        String url = (String) call.arguments;
                        boolean success = WallpaperHelper.set(mRegistrar.activity(), url);
                        if (success) {
                            result.success(null);
                        } else {
                            result.error(null, null, null);
                        }
                    }).start();
                    break;
                }

                case "syncGallery": {
                    syncGallery(call, result);
                    break;
                }

                default:
                    result.notImplemented();
            }
        } catch (IOException e) {
            result.error(e.toString(), null, null);
        }
    }

    private void syncGallery(MethodCall call, Result result) throws IOException {
        File file = new File((String) call.arguments);
        File destDir = new File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/Tujian");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            destDir = new File(mRegistrar.context().getExternalMediaDirs()[0], "/Tujian");
        }
        if (!destDir.exists()) destDir.mkdirs();
        File dest = new File(destDir, file.getName());
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(dest));
        byte[] bytes = new byte[1024];
        int len;
        while ((len = bis.read(bytes)) != -1) {
            bos.write(bytes, 0, len);
        }
        bis.close();
        bos.close();
        mRegistrar.context().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                .setData(Uri.fromFile(dest)));
        result.success(dest.getPath());
    }
}
