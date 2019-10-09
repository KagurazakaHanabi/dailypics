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

import android.content.Intent;
import android.net.Uri;

import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

class PlatformPluginApi24Impl extends PlatformPluginBaseImpl {
    PlatformPluginApi24Impl(Registrar registrar) {
        super(registrar);
    }

    @Override
    public void share(String path, Result result) {
        Uri uri = FileProvider.getUriForFile(mContext, PROVIDER_AUTHORITY, new File(path));
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.putExtra(Intent.EXTRA_STREAM, uri);
        intent.setDataAndType(uri, "image/*");
        mContext.startActivity(Intent.createChooser(intent, null));
        result.success(null);
    }
}
