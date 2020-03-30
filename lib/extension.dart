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
