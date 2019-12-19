package com.yaerin.dailypics

import android.app.Activity
import android.app.WallpaperManager
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import java.io.IOException


class UseAsWallpaperActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val data: String? = intent?.extras?.getString(Intent.EXTRA_STREAM)
        if (data == null) {
            finish()
        }

        val uri = Uri.parse(data)
        try {
            val intent: Intent? = PlatformPluginBaseImpl.getCropAndSetWallpaperIntent(this, uri)
            startActivity(Intent.createChooser(intent, "设置为壁纸"))
        } catch (e: Exception) {
            val wm = WallpaperManager.getInstance(this)
            try {
                wm.setStream(contentResolver.openInputStream(uri))
            } catch (ex: IOException) {
            }
        }
        finish()
    }
}
