import 'dart:async';

import 'package:flutter/material.dart';

class FutureButton extends StatefulWidget {
  FutureButton({
    Key key,
    this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;

  final Future<void> Function() onPressed;

  @override
  State<StatefulWidget> createState() => _FutureButtonState();
}

class _FutureButtonState extends State<FutureButton> {
  bool _doing = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: AnimatedCrossFade(
        firstChild: widget.child,
        secondChild: Container(
          width: 24,
          height: 24,
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        crossFadeState:
            _doing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 240),
      ),
      onPressed: () {
        _doing = true;
        Timer(Duration(milliseconds: 200), () {
          if (_doing) setState(() => _doing = true);
        });
        widget.onPressed().then((val) => setState(() => _doing = false));
      },
    );
  }
}
