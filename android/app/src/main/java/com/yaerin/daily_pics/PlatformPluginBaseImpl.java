/*
 * Copyright 2019 KagurazakaHanabi<i@yaerin.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.yaerin.daily_pics;

import android.app.WallpaperManager;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.provider.Settings;

import androidx.core.content.FileProvider;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static android.os.Environment.DIRECTORY_PICTURES;
import static android.os.Environment.getExternalStoragePublicDirectory;
import static androidx.core.content.ContextCompat.checkSelfPermission;

class PlatformPluginBaseImpl implements PlatformPluginImpl {
    private static final String ACTION_CROP_AND_SET_WALLPAPER = "android.service.wallpaper.CROP_AND_SET_WALLPAPER";

    final Context mContext;

    PlatformPluginBaseImpl(Registrar registrar) {
        this.mContext = registrar.activeContext();
    }

    @Override
    @SuppressWarnings({"ResultOfMethodCallIgnored"})
    public void share(String path, Result result) throws IOException {
        File file = new File(path);
        File dir = new File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/图鉴日图");
        if (!dir.exists()) dir.mkdirs();
        File dest = new File(dir, file.getName());
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(dest));
        byte[] bytes = new byte[1024];
        int len;
        while ((len = bis.read(bytes)) != -1) {
            bos.write(bytes, 0, len);
        }
        bis.close();
        bos.close();
        file.delete();

        Uri uri = Uri.parse("file://" + dest);
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setDataAndType(uri, "image/*");
        mContext.startActivity(Intent.createChooser(intent, null));
        result.success(null);
    }

    @Override
    public void useAsWallpaper(String file, Result result) {
        try {
            Uri uri = FileProvider.getUriForFile(mContext, PROVIDER_AUTHORITY, new File(file));
            Intent intent = getCropAndSetWallpaperIntent(mContext, uri);
            mContext.startActivity(Intent.createChooser(intent, "设置为壁纸"));
            result.success(null);
        } catch (Exception e) {
            WallpaperManager wm = WallpaperManager.getInstance(mContext);
            try {
                wm.setStream(new FileInputStream(new File(file)));
                result.success(null);
            } catch (IOException ex) {
                result.error(ex.getClass().getName(), ex.getLocalizedMessage(), null);
            }
        }
    }

    @Override
    public void requestReview(Result result) {
        Uri uri = Uri.parse("market://details?id=" + BuildConfig.APPLICATION_ID);
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
        result.success(null);
    }

    @Override
    public void isAlbumAuthorized(Result result) {
        result.success(true);
    }

    @Override
    public void openAppSettings(Result result) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.fromParts("package", BuildConfig.APPLICATION_ID, null));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
        result.success(null);
    }

    @Override
    @SuppressWarnings("ResultOfMethodCallIgnored")
    public void syncAlbum(MethodCall call, Result result) throws IOException {
        ContentResolver cr = mContext.getContentResolver();

        String file = call.argument("file");
        String title = call.argument("title");
        String description = call.argument("content");

        assert file != null;
        ContentValues values = new ContentValues();
        values.put(MediaStore.Images.Media.TITLE, title);
        values.put(MediaStore.Images.Media.DISPLAY_NAME, title);
        values.put(MediaStore.Images.Media.DESCRIPTION, description);
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");

        Uri uri = null;
        OutputStream os;
        File dest = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.Images.Media.IS_PENDING, true);
            values.put(MediaStore.Images.Media.RELATIVE_PATH, DIRECTORY_PICTURES + "/图鉴日图");
            uri = cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            if (uri != null) {
                os = cr.openOutputStream(uri);
            } else {
                result.error("0", "Image URI must not be null", null);
                return;
            }
        } else {
            File dir = new File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/图鉴日图");
            if (!dir.exists()) dir.mkdirs();
            dest = new File(dir, new File(file).getName());
            os = new FileOutputStream(dest);
        }

        if (os != null) {
            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
            BufferedOutputStream bos = new BufferedOutputStream(os);
            byte[] bytes = new byte[1024];
            int len;
            while ((len = bis.read(bytes)) != -1) {
                bos.write(bytes, 0, len);
            }
            bis.close();
            bos.close();
        } else {
            result.error("0", "An I/O error occurs", null);
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.Images.Media.IS_PENDING, false);
            cr.update(uri, values, null, null);
            result.success(null);
        } else {
            values.put(MediaStore.Images.Media.DATA, dest.getAbsolutePath());
            cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            result.success(null);
        }
    }

    /**
     * Gets an Intent that will launch an activity that crops the given
     * image and sets the device's wallpaper. If there is a default HOME activity
     * that supports cropping wallpapers, it will be preferred as the default.
     * Use this method instead of directly creating a {@link #ACTION_CROP_AND_SET_WALLPAPER}
     * intent.
     *
     * @param imageUri The image URI that will be set in the intent. The must be a content
     *                 URI and its provider must resolve its type to "image/*"
     * @see WallpaperManager#getCropAndSetWallpaperIntent(Uri)
     */
    private Intent getCropAndSetWallpaperIntent(Context context, Uri imageUri) {
        if (imageUri == null) {
            throw new IllegalArgumentException("Image URI must not be null");
        }

        if (!ContentResolver.SCHEME_CONTENT.equals(imageUri.getScheme())) {
            throw new IllegalArgumentException("Image URI must be of the "
                    + ContentResolver.SCHEME_CONTENT + " scheme type");
        }

        final PackageManager packageManager = context.getPackageManager();
        Intent cropAndSetWallpaperIntent = new Intent(ACTION_CROP_AND_SET_WALLPAPER);
        cropAndSetWallpaperIntent.setDataAndType(imageUri, "image/*");
        cropAndSetWallpaperIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        // Find out if the default HOME activity supports CROP_AND_SET_WALLPAPER
        Intent homeIntent = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME);
        ResolveInfo resolvedHome = packageManager.resolveActivity(homeIntent,
                PackageManager.MATCH_DEFAULT_ONLY);
        if (resolvedHome != null) {
            cropAndSetWallpaperIntent.setPackage(resolvedHome.activityInfo.packageName);

            List<ResolveInfo> cropAppList = packageManager.queryIntentActivities(
                    cropAndSetWallpaperIntent, 0);
            if (cropAppList.size() > 0) {
                return cropAndSetWallpaperIntent;
            }
        }

        // fallback crop activity
        String cropperPackage;
        try {
            int resId = context.getResources().getIdentifier(
                    "config_wallpaperCropperPackage", "string", "android");
            cropperPackage = context.getResources().getString(resId);
        } catch (Exception e) {
            cropperPackage = "com.android.wallpapercropper";
        }

        cropAndSetWallpaperIntent.setPackage(cropperPackage);
        List<ResolveInfo> cropAppList = packageManager.queryIntentActivities(
                cropAndSetWallpaperIntent, 0);
        if (cropAppList.size() > 0) {
            return cropAndSetWallpaperIntent;
        }
        // If the URI is not of the right type, or for some reason the system wallpaper
        // cropper doesn't exist, return null
        throw new IllegalArgumentException("Cannot use passed URI to set wallpaper; " +
                "check that the type returned by ContentProvider matches image/*");
    }
}
