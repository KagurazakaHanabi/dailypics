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

import androidx.annotation.NonNull;
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
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static android.os.Environment.DIRECTORY_PICTURES;
import static android.os.Environment.getExternalStoragePublicDirectory;
import static androidx.core.content.ContextCompat.checkSelfPermission;

public class PlatformPlugin implements MethodCallHandler {
    private static final String PROVIDER_AUTHORITY = BuildConfig.APPLICATION_ID + ".file_provider";
    private static final String ACTION_CROP_AND_SET_WALLPAPER = "android.service.wallpaper.CROP_AND_SET_WALLPAPER";

    private final Registrar mRegistrar;

    private PlatformPlugin(Registrar registrar) {
        this.mRegistrar = registrar;
    }

    static void registerWith(Registrar registrar) {
        MethodChannel channel = new MethodChannel(registrar.messenger(), "ml.cerasus.pics");
        PlatformPlugin instance = new PlatformPlugin(registrar);
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "share": {
                share((String) call.arguments, result);
                break;
            }

            case "useAsWallpaper": {
                useAsWallpaper((String) call.arguments, result);
                break;
            }

            case "requestReview": {
                requestReview(result);
                break;
            }

            case "isAlbumAuthorized": {
                isAlbumAuthorized(result);
                break;
            }

            case "openAppSettings": {
                openAppSettings(result);
                break;
            }

            case "syncAlbum": {
                try {
                    syncAlbum(call, result);
                } catch (IOException e) {
                    result.error("0", "The image failed to be stored", null);
                }
                break;
            }

            default: {
                result.notImplemented();
                break;
            }
        }
    }

    private void share(String file, Result result) {
        Context context = mRegistrar.activity();
        Uri uri = FileProvider.getUriForFile(context, PROVIDER_AUTHORITY, new File(file));
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setType("image/*");
        context.startActivity(Intent.createChooser(intent, null));
        result.success(null);
    }

    // FIXME 2019-08-17: 部分设备上不可用
    private void useAsWallpaper(String file, Result result) {
        Context context = mRegistrar.activity();
        Uri uri = FileProvider.getUriForFile(context, PROVIDER_AUTHORITY, new File(file));
        Intent intent = getCropAndSetWallpaperIntent(context, uri);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        context.startActivity(Intent.createChooser(intent, "设置为壁纸"));
        result.success(null);
    }

    private void requestReview(Result result) {
        Uri uri = Uri.parse("market://details?id=" + BuildConfig.APPLICATION_ID);
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mRegistrar.activity().startActivity(intent);
        result.success(null);
    }

    private void isAlbumAuthorized(Result result) {
        Context context = mRegistrar.activity();
        int status = checkSelfPermission(context, WRITE_EXTERNAL_STORAGE);
        result.success(status == PackageManager.PERMISSION_GRANTED);
    }

    private void openAppSettings(Result result) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.fromParts("package", BuildConfig.APPLICATION_ID, null));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mRegistrar.activity().startActivity(intent);
        result.success(null);
    }

    @SuppressWarnings("ResultOfMethodCallIgnored")
    private void syncAlbum(MethodCall call, Result result) throws IOException {
        ContentResolver cr = mRegistrar.activity().getContentResolver();

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
                result.error("0", "The image failed to be stored", null);
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
            result.error("0", "The image failed to be stored", null);
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
        Intent cropAndSetWallpaperIntent =
                new Intent(ACTION_CROP_AND_SET_WALLPAPER, imageUri);
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
        // com.android.internal.R.string.config_wallpaperCropperPackage
        final String cropperPackage = "com.android.wallpapercropper";
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
