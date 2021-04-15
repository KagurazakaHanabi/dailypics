// Copyright 2019-2021 KagurazakaHanabi<i@hanabi.su>
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

import 'package:flutter/widgets.dart';

extension ColorX on Color {
  static Color fromHexString(String source) {
    String s = source.toUpperCase().replaceAll('#', '');
    if (s.length == 6) {
      s = 'FF$s';
    } else if (s.length == 3) {
      s = 'FF${s[0] * 2}${s[1] * 2}${s[2] * 2}';
    }
    return Color(int.parse(s, radix: 16));
  }

  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0')}';
  }

  bool get isDark {
    // See https://github.com/FooStudio/tinycolor
    return (red * 299 + green * 587 + blue * 114) / 1000 < 128;
  }
}

extension StringX on String {
  bool get isUuid {
    if (isEmpty) return false;
    return RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$',
      caseSensitive: false,
    ).hasMatch(this);
  }
}
