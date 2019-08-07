package com.yaerin.daily_pics;

import android.app.WallpaperManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.io.IOException;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

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
            case "syncAlbum": {
                syncAlbum((String) call.arguments, result);
                break;
            }

            case "share": {
                share((String) call.arguments, result);
                break;
            }

            case "useAsWallpaper": {
                useAsWallpaper((String) call.arguments, result);
                break;
            }

            default: {
                result.notImplemented();
                break;
            }
        }
    }

    private void syncAlbum(String file, Result result) {
        Context context = mRegistrar.activity();
        ContentResolver cr = context.getContentResolver();
        try {
            MediaStore.Images.Media.insertImage(cr, file, null, null);
            result.success(null);
        } catch (IOException e) {
            result.error("0", e.getLocalizedMessage(), e);
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

    private void useAsWallpaper(String file, Result result) {
        Context context = mRegistrar.activity();
        Uri uri = FileProvider.getUriForFile(context, PROVIDER_AUTHORITY, new File(file));
        Intent intent = getCropAndSetWallpaperIntent(context, uri);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        context.startActivity(Intent.createChooser(intent, "设置为壁纸"));
        result.success(null);
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
     * @throws IllegalArgumentException if the URI is not a content URI or its MIME type is
     *                                  not "image/*"
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
