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

import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public interface PlatformPluginImpl {
    String PROVIDER_AUTHORITY = BuildConfig.APPLICATION_ID + ".file_provider";

    void share(String path, Result result) throws IOException;

    void useAsWallpaper(String file, Result result);

    void requestReview(Result result);

    void isAlbumAuthorized(Result result);

    void openAppSettings(Result result);

    void syncAlbum(MethodCall call, Result result) throws IOException;
}