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

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException

internal interface PlatformPluginImpl {
    companion object {
        const val PROVIDER_AUTHORITY = BuildConfig.APPLICATION_ID + ".file_provider"
    }

    @Throws(IOException::class)
    fun share(path: String, result: Result?)

    fun useAsWallpaper(file: String, result: Result?)

    fun requestReview(result: Result?)

    fun isAlbumAuthorized(result: Result?)

    fun openAppSettings(result: Result?)

    @Throws(IOException::class)
    fun syncAlbum(call: MethodCall, result: Result)
}
