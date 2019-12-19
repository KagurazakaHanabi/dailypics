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

package com.yaerin.dailypics

import android.app.WallpaperManager
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
import android.net.Uri
import android.os.Build
import android.os.Environment.DIRECTORY_PICTURES
import android.os.Environment.getExternalStoragePublicDirectory
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.content.FileProvider
import com.yaerin.dailypics.PlatformPluginImpl.Companion.PROVIDER_AUTHORITY
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*

open class PlatformPluginBaseImpl(val context: Context) : PlatformPluginImpl {
    companion object {
        const val ACTION_CROP_AND_SET_WALLPAPER = "android.service.wallpaper.CROP_AND_SET_WALLPAPER"
    }

    @Suppress("DEPRECATION")
    override fun share(path: String, result: Result?) {
        val file = File(path)
        val dir = File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/图鉴日图")
        if (!dir.exists()) dir.mkdirs()
        val dest = File(dir, file.name)
        val bis = BufferedInputStream(FileInputStream(file))
        val bos = BufferedOutputStream(FileOutputStream(dest))
        val bytes = ByteArray(1024)
        var len: Int
        while (bis.read(bytes).also { len = it } != -1) {
            bos.write(bytes, 0, len)
        }
        bis.close()
        bos.close()
        file.delete()

        val uri = Uri.parse("file://$dest")
        val intent = Intent(Intent.ACTION_SEND)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra(Intent.EXTRA_STREAM, uri)
        intent.setDataAndType(uri, "image/*")
        context.startActivity(Intent.createChooser(intent, null))
        result?.success(null)
    }

    override fun useAsWallpaper(file: String, result: Result?) {
        try {
            val uri = FileProvider.getUriForFile(context, PROVIDER_AUTHORITY, File(file))
            val intent: Intent? = getCropAndSetWallpaperIntent(context, uri)
            context.startActivity(Intent.createChooser(intent, "设置为壁纸"))
            result?.success(null)
        } catch (e: Exception) {
            val wm = WallpaperManager.getInstance(context)
            try {
                wm.setStream(FileInputStream(File(file)))
                result?.success(null)
            } catch (ex: IOException) {
                result?.error(ex.javaClass.name, ex.localizedMessage, null)
            }
        }
    }

    override fun requestReview(result: Result?) {
        val uri = Uri.parse("market://details?id=" + BuildConfig.APPLICATION_ID)
        val intent = Intent(Intent.ACTION_VIEW, uri)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        result?.success(null)
    }

    override fun isAlbumAuthorized(result: Result?) {
        result?.success(true)
    }

    override fun openAppSettings(result: Result?) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.fromParts("package", BuildConfig.APPLICATION_ID, null)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        result?.success(null)
    }

    @Suppress("DEPRECATION")
    override fun syncAlbum(call: MethodCall, result: Result) {
        val cr: ContentResolver = context.contentResolver

        val file = call.argument<String>("file")!!
        val title = call.argument<String>("title")
        val description = call.argument<String>("content")

        val values = ContentValues()
        values.put(MediaStore.Images.Media.TITLE, title)
        values.put(MediaStore.Images.Media.DISPLAY_NAME, title)
        values.put(MediaStore.Images.Media.DESCRIPTION, description)
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")

        var uri: Uri? = null
        val os: OutputStream?
        var dest: File? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.Images.Media.IS_PENDING, true)
            values.put(MediaStore.Images.Media.RELATIVE_PATH, "$DIRECTORY_PICTURES/图鉴日图")
            uri = cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            os = if (uri != null) {
                cr.openOutputStream(uri)
            } else {
                result.error("0", "Image URI must not be null", null)
                return
            }
        } else {
            val dir = File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/图鉴日图")
            if (!dir.exists()) dir.mkdirs()
            dest = File(dir, File(file).name)
            os = FileOutputStream(dest)
        }

        if (os != null) {
            val bis = BufferedInputStream(FileInputStream(file))
            val bos = BufferedOutputStream(os)
            val bytes = ByteArray(1024)
            var len: Int
            while (bis.read(bytes).also { len = it } != -1) {
                bos.write(bytes, 0, len)
            }
            bis.close()
            bos.close()
        } else {
            result.error("0", "An I/O error occurs", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.put(MediaStore.Images.Media.IS_PENDING, false)
            cr.update(uri!!, values, null, null)
            result.success(null)
        } else {
            values.put(MediaStore.Images.Media.DATA, dest!!.absolutePath)
            cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            result.success(null)
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
     *                 URI and its provider must resolve its type to "image/"
     * @see WallpaperManager#getCropAndSetWallpaperIntent(Uri)
     */
    private fun getCropAndSetWallpaperIntent(context: Context, imageUri: Uri?): Intent? {
        requireNotNull(imageUri) { "Image URI must not be null" }

        require(ContentResolver.SCHEME_CONTENT == imageUri.scheme) {
            ("Image URI must be of the " + ContentResolver.SCHEME_CONTENT + " scheme type")
        }

        val packageManager = context.packageManager
        val cropAndSetWallpaperIntent = Intent(ACTION_CROP_AND_SET_WALLPAPER)
        cropAndSetWallpaperIntent.setDataAndType(imageUri, "image/*")
        cropAndSetWallpaperIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        // Find out if the default HOME activity supports CROP_AND_SET_WALLPAPER
        val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val resolvedHome = packageManager.resolveActivity(homeIntent, MATCH_DEFAULT_ONLY)
        if (resolvedHome != null) {
            cropAndSetWallpaperIntent.setPackage(resolvedHome.activityInfo.packageName)

            val cropAppList = packageManager.queryIntentActivities(cropAndSetWallpaperIntent, 0)
            if (cropAppList.size > 0) {
                return cropAndSetWallpaperIntent
            }
        }

        // fallback crop activity
        val cropperPackage: String
        cropperPackage = try {
            val resId = context.resources
                    .getIdentifier("config_wallpaperCropperPackage", "string", "android")
            context.resources.getString(resId)
        } catch (e: Exception) {
            "com.android.wallpapercropper"
        }

        cropAndSetWallpaperIntent.setPackage(cropperPackage)
        val cropAppList = packageManager.queryIntentActivities(cropAndSetWallpaperIntent, 0)
        if (cropAppList.size > 0) {
            return cropAndSetWallpaperIntent
        }
        // If the URI is not of the right type, or for some reason the system wallpaper
        // cropper doesn't exist, return null
        throw IllegalArgumentException("Cannot use passed URI to set wallpaper; " +
                "check that the type returned by ContentProvider matches image/*")
    }
}
