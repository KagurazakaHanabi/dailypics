package com.yaerin.daily_pics.plugins;

import android.app.WallpaperManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

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

import static android.content.Context.WALLPAPER_SERVICE;
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
                    setWallpaper(call, result);
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

    private void setWallpaper(MethodCall call, Result result) throws IOException {
        Context context = mRegistrar.activity();
        String path = (String) call.arguments;
        WallpaperManager manager = (WallpaperManager) context.getSystemService(WALLPAPER_SERVICE);
        manager.setStream(new FileInputStream(new File(path)));
        result.success(null);
    }

    private void syncGallery(MethodCall call, Result result) throws IOException {
        File file = new File((String) call.arguments);
        File destDir = new File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/Tujian");
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
