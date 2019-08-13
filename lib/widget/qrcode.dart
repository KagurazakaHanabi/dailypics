import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

class QrCodeView extends StatefulWidget {
  final String data;

  QrCodeView(this.data);

  @override
  _QrCodeViewState createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  QrCode code;

  @override
  void initState() {
    super.initState();
    code = QrCode.fromData(
      data: widget.data,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );
    code.make();
  }

  @override
  Widget build(BuildContext context) {
    double width = (code.moduleCount * 1.5 + 3).toDouble();
    return CustomPaint(
      size: Size(width, width),
      painter: _QrCodePainter(code),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final QrCode code;

  _QrCodePainter(this.code);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color(0xFFFFFFFF),
    );
    canvas.translate(1.5, 1.5);
    for (int x = 0; x < code.moduleCount; x++) {
      for (int y = 0; y < code.moduleCount; y++) {
        if (code.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * 1.5, y *1.5, 1.5, 1.5),
            Paint()..color = Color(0xFF000000),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
