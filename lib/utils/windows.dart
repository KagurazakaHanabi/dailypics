// Copyright 2021 chimon89<chimon@chimon.me>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class Windows {
  static void useAsWallpaper(File wallpaperFile) {
    final hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) throw WindowsException(hr);

    final wallpaper = DesktopWallpaper.createInstance();

    final pathPtr = TEXT(wallpaperFile.path);
    wallpaper.SetWallpaper(nullptr, pathPtr);
    if (FAILED(hr)) throw WindowsException(hr);

    calloc.free(pathPtr);
    calloc.free(wallpaper.ptr);

    CoUninitialize();
  }
}
