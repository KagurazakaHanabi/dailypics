import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  static const Duration LENGTH_SHORT = const Duration(seconds: 4);

  static const Duration LENGTH_LONG = const Duration(seconds: 7);

  static Queue<Toast> _toasts = Queue<Toast>();

  static Timer _toastTimer;

  Toast(
    this.context,
    this.text, {
    this.duration = LENGTH_SHORT,
    this.alignment = const Alignment(0, 0.75),
  }) : assert(context != null);

  final BuildContext context;

  final String text;

  final Duration duration;

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 14);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: MediaQuery.of(context).padding,
      child: Align(
        alignment: alignment,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.subhead.merge(textStyle),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.black54,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  void show() async {
    if (_toasts.isNotEmpty) {
      _toasts.addLast(this);
      return;
    }
    _toasts.addLast(this);
    OverlayEntry entry = OverlayEntry(builder: (_) => this);
    Overlay.of(context).insert(entry);
    _toastTimer = Timer.periodic(duration, (timer) {
      entry.remove();
      _toasts.removeFirst();
      if (_toasts.isNotEmpty) {
        entry = OverlayEntry(builder: (_) => _toasts.first);
        Overlay.of(context).insert(entry);
      } else {
        _toastTimer.cancel();
        _toastTimer = null;
      }
    });
  }

  void cancel() => _toasts.remove(this);
}
