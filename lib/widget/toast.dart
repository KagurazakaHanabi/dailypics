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

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  Toast(
    this.context,
    this.text, {
    this.duration = length_short,
    this.alignment = const Alignment(0, 0.75),
  })  : assert(context != null),
        assert(duration != null),
        assert(alignment != null);

  static const Duration length_short = Duration(seconds: 4);

  static const Duration length_long = Duration(seconds: 7);

  static const Duration _animationDuration = Duration(milliseconds: 500);

  static Queue<Toast> _toasts = Queue<Toast>();

  static Timer _toastTimer;

  final BuildContext context;

  final String text;

  final Duration duration;

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      color: Color(0xDE000000),
      fontSize: 14,
    );
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: MediaQuery.of(context).padding,
      alignment: alignment,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subtitle1.merge(textStyle),
        child: AnimatedOpacity(
          opacity: _toasts.contains(this) ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xE6EEEEEE),
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
