// Copyright 2019 KagurazakaHanabi<i@yaerin.com>
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

import 'package:flutter/cupertino.dart';
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
