package com.yaerin.daily_pics.util;

import android.app.WallpaperManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import java.io.IOException;
import java.net.URL;

import static android.content.Context.WALLPAPER_SERVICE;

public class WallpaperHelper {
    private Context mContext;

    public WallpaperHelper(Context context) {
        mContext = context;
    }

    public static boolean set(Context context, String imageUrl) {
        WallpaperHelper setWallpaperHelper = new WallpaperHelper(context);
        if (!setWallpaperHelper.forMIUI(imageUrl)) {
            if (!setWallpaperHelper.forEMUI(imageUrl)) {
                if (!setWallpaperHelper.byCropImage(imageUrl)) {
                    if (!setWallpaperHelper.byChooseActivity(imageUrl)) {
                        return setWallpaperHelper.byWallpaperManager(imageUrl);
                    }
                }
            }
        }
        return true;
    }

    public boolean byWallpaperManager(String url) {
        WallpaperManager manager = (WallpaperManager) mContext.getSystemService(WALLPAPER_SERVICE);
        try {
            manager.setStream(new URL(url).openStream());
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean byCropImage(String url) {
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
            intent.putExtra("data", Uri.parse(url));
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean byChooseActivity(String url) {
        try {
            Intent intent = new Intent(Intent.ACTION_ATTACH_DATA);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.putExtra("mimeType", "image/*");
            intent.setData(Uri.parse(url));
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean forMIUI(String url) {
        try {
            ComponentName componentName = new ComponentName("com.android.thememanager", "com.android.thememanager.activity.WallpaperDetailActivity");
            Intent intent = new Intent("miui.intent.action.START_WALLPAPER_DETAIL");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(Uri.parse(url), "image/*");
            intent.putExtra("mimeType", "image/*");
            intent.setComponent(componentName);
            mContext.startActivity(intent);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean forEMUI(String url) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(Uri.parse(url), "image/*");
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
