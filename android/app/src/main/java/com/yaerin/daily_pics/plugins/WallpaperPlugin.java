package com.yaerin.daily_pics.plugins;

import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.os.Environment.DIRECTORY_PICTURES;

/**
 * Create by Yaerin on 2019/2/18
 *
 * @author Yaerin
 */
public class WallpaperPlugin implements MethodCallHandler {
    private final Registrar mRegistrar;

    private WallpaperPlugin(Registrar registrar) {
        this.mRegistrar = registrar;
    }

    public static void registerWith(Registrar registrar) {
        MethodChannel channel = new MethodChannel(registrar.messenger(), "ml.cerasus.pics");
        WallpaperPlugin instance = new WallpaperPlugin(registrar);
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "setWallpaper": {
                setWallpaper(call, result);
                break;
            }

            case "syncGallery": {
                try {
                    syncGallery(call.argument("file"), result);
                } catch (IOException e) {
                    result.error(e.toString(), null, null);
                }
                break;
            }

            default:
                result.notImplemented();
        }
    }

    private void setWallpaper(MethodCall call, Result result) {
        // TODO: 2019/2/18 Yaerin: 设置壁纸怎么写来着？
        Toast.makeText(mRegistrar.context(), "设置壁纸怎么写来着？", Toast.LENGTH_SHORT).show();
        result.success(null);
    }

    private void syncGallery(String path, Result result) throws IOException {
        File file = new File(path);
        File dest = new File(Environment.getExternalStoragePublicDirectory(DIRECTORY_PICTURES), file.getName());
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(dest));
        byte[] bytes = new byte[1024];
        int len;
        while ((len = bis.read(bytes)) != -1) {
            bos.write(bytes, 0, len);
        }
        bis.close();
        bos.close();
        mRegistrar.context()
                .sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                .setData(Uri.fromFile(file)));
        result.success(null);
    }
}
