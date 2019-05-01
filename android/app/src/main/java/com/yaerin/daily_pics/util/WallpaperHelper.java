package com.yaerin.daily_pics.util;

import android.app.WallpaperManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.core.content.FileProvider;

import java.io.File;
import java.io.FileInputStream;
import java.net.URL;

import static android.content.Context.WALLPAPER_SERVICE;

public class WallpaperHelper {
    private Context mContext;

    public WallpaperHelper(Context context) {
        mContext = context;
    }

    public static boolean set(Context context, Uri uri) {
        if (uri.getScheme() == null) {
            uri = Uri.parse("file:" + uri.toString());
        }
        WallpaperHelper helper = new WallpaperHelper(context);
        if (!helper.forMIUI(uri)) {
            if (!helper.forEMUI(uri)) {
                if (!helper.byCropImage(uri)) {
                    if (!helper.byChooseActivity(uri)) {
                        return helper.byWallpaperManager(uri);
                    }
                }
            }
        }
        return true;
    }

    public boolean byWallpaperManager(Uri uri) {
        WallpaperManager manager = (WallpaperManager) mContext.getSystemService(WALLPAPER_SERVICE);
        try {
            manager.setStream(new FileInputStream(uri.getPath()));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean byCropImage(Uri uri) {
        WallpaperManager manager = (WallpaperManager) mContext.getSystemService(WALLPAPER_SERVICE);
        try {
            Intent intent = new Intent("com.android.camera.CropImage");
            int width = manager.getDesiredMinimumWidth();
            int height = manager.getDesiredMinimumHeight();
            intent.putExtra("outputX", width);
            intent.putExtra("outputY", height);
            intent.putExtra("aspectX", width);
            intent.putExtra("aspectY", height);
            intent.putExtra("scale", true);
            intent.putExtra("noFaceDetection", true);
            intent.putExtra("setWallpaper", true);
            intent.putExtra("data", uri);
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean byChooseActivity(Uri uri) {
        try {
            Intent intent = new Intent(Intent.ACTION_ATTACH_DATA);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.putExtra("mimeType", "image/*");
            intent.setData(uri);
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean forMIUI(Uri uri) {
        try {
            ComponentName componentName = new ComponentName("com.android.thememanager", "com.android.thememanager.activity.WallpaperDetailActivity");
            Intent intent = new Intent("miui.intent.action.START_WALLPAPER_DETAIL");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(uri, "image/*");
            intent.putExtra("mimeType", "image/*");
            intent.setComponent(componentName);
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean forEMUI(Uri uri) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(uri, "image/*");
            intent.putExtra("mimeType", "image/*");
            intent.setComponent(new ComponentName(
                    "com.android.gallery3d", "com.android.gallery3d.app.Wallpaper"
            ));
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
