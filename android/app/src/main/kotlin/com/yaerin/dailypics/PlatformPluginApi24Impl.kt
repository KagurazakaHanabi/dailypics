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

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.yaerin.dailypics.PlatformPluginImpl.Companion.PROVIDER_AUTHORITY
import io.flutter.plugin.common.MethodChannel
import java.io.File

class PlatformPluginApi24Impl(context: Context) : PlatformPluginBaseImpl(context) {
    override fun share(path: String, result: MethodChannel.Result?) {
        val uri: Uri = FileProvider.getUriForFile(context, PROVIDER_AUTHORITY, File(path))
        val intent = Intent(Intent.ACTION_SEND)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.putExtra(Intent.EXTRA_STREAM, uri)
        context.startActivity(Intent.createChooser(intent, null))
        result?.success(null)
    }
}
