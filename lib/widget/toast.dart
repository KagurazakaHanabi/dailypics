import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  static const Duration length_short = const Duration(seconds: 4);

  static const Duration length_long = const Duration(seconds: 7);

  static const Duration _animationDuration = const Duration(milliseconds: 500);

  static Queue<Toast> _toasts = Queue<Toast>();

  static Timer _toastTimer;


  Toast(
    this.context,
    this.text, {
    this.duration = length_short,
    this.alignment = const Alignment(0, 0.75),
  }) : assert(context != null);

  final BuildContext context;

  final String text;

  final Duration duration;

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Color(0xDE000000), fontSize: 14);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: MediaQuery.of(context).padding,
      alignment: alignment,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead.merge(textStyle),
        child: AnimatedOpacity(
          opacity: _toasts.contains(this) ? 1 : 0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Color(0xE6EEEEEE),
            ),
            child: Text(text ?? 'null'),
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
    OverlayState overlay = Overlay.of(context);
    OverlayEntry entry = OverlayEntry(builder: (_) => this);
    overlay.insert(entry);
    entry.markNeedsBuild();
    await Future.delayed(_animationDuration);
    _toastTimer = Timer.periodic(duration, (_) async {
      _toasts.removeFirst();
      entry.markNeedsBuild();
      await Future.delayed(_animationDuration);
      entry.remove();
      if (_toasts.isNotEmpty) {
        entry = OverlayEntry(builder: (_) => _toasts.first);
        overlay.insert(entry);
        entry.markNeedsBuild();
        await Future.delayed(_animationDuration);
      } else {
        _toastTimer.cancel();
        _toastTimer = null;
      }
    });
  }

  void cancel() => _toasts.remove(this);
}
