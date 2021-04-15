/*
 * Copyright 2019-2021 KagurazakaHanabi<i@hanabi.su>
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

import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.app.Activity
import android.content.pm.PackageManager.PERMISSION_DENIED
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.io.IOException

internal class PlatformPlugin : ActivityAware, FlutterPlugin, MethodCallHandler, RequestPermissionsResultListener {
    private var pluginImpl: PlatformPluginImpl? = null

    private var activity: Activity? = null
    private var methodChannel: MethodChannel? = null

    private var methodCall: MethodCall? = null
    private var methodResult: Result? = null

    companion object {

        @Suppress("UNUSED")
        fun registerWith(registrar: Registrar) {
            val instance = PlatformPlugin()
            instance.onAttachedToEngine(registrar.messenger())
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        val context = binding.applicationContext
        pluginImpl = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            PlatformPluginApi24Impl(context)
        } else {
            PlatformPluginBaseImpl(context)
        }
        onAttachedToEngine(binding.binaryMessenger)
    }

    fun onAttachedToEngine(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "ml.cerasus.pics")
        methodChannel!!.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        methodChannel!!.setMethodCallHandler(null)
        methodChannel = null
        pluginImpl = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "share" -> try {
                pluginImpl!!.share(call.argument("file")!!, result)
            } catch (e: IOException) {
                result.error(e.javaClass.name, e.localizedMessage, null)
            }

            "useAsWallpaper" -> pluginImpl!!.useAsWallpaper(call.arguments as String, result)

            "requestReview" -> pluginImpl!!.requestReview(result)

            "isAlbumAuthorized" -> pluginImpl!!.isAlbumAuthorized(result)

            "openAppSettings" -> pluginImpl!!.openAppSettings(result)

            "syncAlbum" -> {
                methodCall = call
                methodResult = result
                val requestCode = 1080
                val permissions = arrayOf(WRITE_EXTERNAL_STORAGE)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    activity!!.requestPermissions(permissions, requestCode)
                } else {
                    val grantResults = intArrayOf(PERMISSION_GRANTED)
                    onRequestPermissionsResult(requestCode, permissions, grantResults)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
        if (requestCode != 1080) {
            return false
        }
        if (grantResults[0] == PERMISSION_DENIED) {
            methodResult!!.error("-1", "Permission denied", null)
            return true
        }
        return try {
            pluginImpl!!.syncAlbum(methodCall!!, methodResult!!)
            true
        } catch (e: IOException) {
            methodResult!!.error(e.javaClass.name, e.localizedMessage, null)
            false
        }

    }
}
