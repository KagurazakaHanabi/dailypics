/**
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

import android.os.Build;

import androidx.annotation.NonNull;

import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class PlatformPlugin implements MethodCallHandler {
    private final PlatformPluginImpl IMPL;

    private PlatformPlugin(Registrar registrar) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            IMPL = new PlatformPluginApi24Impl(registrar);
        } else {
            IMPL = new PlatformPluginBaseImpl(registrar);
        }
    }

    static void registerWith(Registrar registrar) {
        MethodChannel channel = new MethodChannel(registrar.messenger(), "ml.cerasus.pics");
        channel.setMethodCallHandler(new PlatformPlugin(registrar));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "share":
                try {
                    IMPL.share(call.argument("file"), result);
                } catch (IOException e) {
                    result.error("0", e.getLocalizedMessage(), null);
                }
                break;

            case "useAsWallpaper":
                IMPL.useAsWallpaper((String) call.arguments, result);
                break;

            case "requestReview":
                IMPL.requestReview(result);
                break;

            case "isAlbumAuthorized":
                IMPL.isAlbumAuthorized(result);
                break;

            case "openAppSettings":
                IMPL.openAppSettings(result);
                break;

            case "syncAlbum":
                try {
                    IMPL.syncAlbum(call, result);
                } catch (IOException e) {
                    result.error("0", e.getLocalizedMessage(), null);
                }
                break;

            default:
                result.notImplemented();
                break;
        }
    }
}
