import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Divider extends StatelessWidget {
  final List<Color> colors;

  final double height;

  Divider({
    Key key,
    @required this.colors,
    this.height = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(window.physicalSize.width, height),
      painter: _DividerPainter(this.colors),
    );
  }
}

class _DividerPainter extends CustomPainter {
  final List<Color> colors;

  _DividerPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width / colors.length;
    for (int i = 0; i < colors.length; i++) {
      Paint paint = Paint()..color = colors[i];
      canvas.drawRect(Rect.fromLTWH(width * i, 0, width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
