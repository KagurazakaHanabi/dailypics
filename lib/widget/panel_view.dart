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

import 'dart:ui';

import 'package:flutter/material.dart';

enum PanelLockMode {
  unlock,
  closed,
  opened,
}

class PanelView extends StatefulWidget {
  final Alignment alignment;

  final Widget panel;

  final Widget child;

  final double minHeight;

  final double maxHeight;

  final double radius;

  final Color color;

  final List<BoxShadow> boxShadow;

  final PanelLockMode lockMode;

  final Color scrimColor;

  final double scrimOpacity;

  final bool ignorePointer;

  final void Function(double offset) onPanelSlide;

  final VoidCallback onPanelOpened;

  final VoidCallback onPanelClosed;

  PanelView({
    Key key,
    this.alignment = Alignment.bottomCenter,
    @required this.panel,
    @required this.child,
    this.minHeight = kToolbarHeight,
    this.maxHeight = 320,
    this.radius = 8,
    this.color = Colors.white,
    this.boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      )
    ],
    this.lockMode = PanelLockMode.unlock,
    this.scrimColor = Colors.black,
    this.scrimOpacity = 0.5,
    this.ignorePointer = true,
    this.onPanelSlide,
    this.onPanelOpened,
    this.onPanelClosed,
  })  : assert(alignment.x == 0),
        assert(alignment.y == -1 || alignment.y == 1),
        assert(panel != null && child != null),
        assert(color != null),
        assert(scrimOpacity >= 0 && scrimOpacity <= 1),
        super(key: key);

  @override
  PanelViewState createState() => PanelViewState();
}

class PanelViewState extends State<PanelView>
    with SingleTickerProviderStateMixin {
  AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 246),
    )..addListener(_dispatchEvents);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Radius radius = Radius.circular(widget.radius);
    double extent = widget.maxHeight - widget.minHeight;
    return Stack(
      children: <Widget>[
        SizedBox(
          width: size.width,
          height: size.height,
          child: widget.child,
        ),
        widget.scrimColor != null
            ? Offstage(
                offstage: _anim.value == 0,
                child: GestureDetector(
                  onTap: widget.ignorePointer ? close : null,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    color: widget.scrimColor.withOpacity(
                      _anim.value * widget.scrimOpacity,
                    ),
                  ),
                ),
              )
            : Container(),
        Positioned(
          top: widget.alignment.y == -1 ? extent * (_anim.value - 1) : null,
          bottom: widget.alignment.y == 1 ? extent * (_anim.value - 1) : null,
          child: GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Container(
              width: size.width,
              height: widget.maxHeight,
              child: widget.panel,
              decoration: BoxDecoration(
                color: widget.color,
                boxShadow: widget.boxShadow,
                borderRadius: BorderRadius.vertical(
                  top: widget.alignment.y == 1 ? radius : Radius.zero,
                  bottom: widget.alignment.y == -1 ? radius : Radius.zero,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _dispatchEvents() {
    setState(() {});
    if (widget.onPanelSlide != null) {
      widget.onPanelSlide(_anim.value);
    }
    if (widget.onPanelOpened != null && _anim.value == 1) {
      widget.onPanelOpened();
    }
    if (widget.onPanelClosed != null && _anim.value == 0) {
      widget.onPanelClosed();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (widget.lockMode != PanelLockMode.unlock) return;
    double extent = widget.maxHeight - widget.minHeight;
    double newValue = details.primaryDelta / extent;
    _anim.value -= newValue * widget.alignment.y;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (widget.lockMode != PanelLockMode.unlock || _anim.isAnimating) return;
    double minFlingVelocity = 365;
    double extent = widget.maxHeight - widget.minHeight;
    double velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity.abs() >= minFlingVelocity) {
      _anim.fling(velocity: -velocity / extent * widget.alignment.y);
    } else {
      if (_anim.value > 0.5) {
        open();
      } else {
        close();
      }
    }
  }

  void open() => _anim.fling(velocity: 1);

  void close() => _anim.fling(velocity: -1);

  static PanelViewState of(BuildContext context, {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final PanelViewState result = context.ancestorStateOfType(
      const TypeMatcher<PanelViewState>(),
    );
    if (nullOk || result != null) {
      return result;
    }
    throw FlutterError(
      'PanelView.of() called with a context that does not contain a PanelView.',
    );
  }
}
