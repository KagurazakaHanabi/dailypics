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

class AnimatedTransform extends ImplicitlyAnimatedWidget {
  AnimatedTransform({
    Key key,
    this.child,
    @required this.transform,
    this.alignment = Alignment.center,
    this.transformHitTests = true,
    Curve curve = Curves.linear,
    @required Duration duration,
  }) : assert(transform != null),
       super(key: key, curve: curve, duration: duration);

  AnimatedTransform.scale({
    Key key,
    this.child,
    @required double scale,
    this.alignment = Alignment.center,
    this.transformHitTests = true,
    Curve curve = Curves.linear,
    @required Duration duration,
  }) : transform = Matrix4.diagonal3Values(scale, scale, 1),
       super(key: key, curve: curve, duration: duration);

  final Widget child;

  final Matrix4 transform;

  final AlignmentGeometry alignment;

  final bool transformHitTests;

  @override
  _AnimatedTransformState createState() => _AnimatedTransformState();
}

class _AnimatedTransformState extends AnimatedWidgetBaseState<AnimatedTransform> {
  AlignmentGeometryTween _alignment;
  Matrix4Tween _transform;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment = visitor(_alignment, widget.alignment, (dynamic value) => AlignmentGeometryTween(begin: value));
    _transform = visitor(_transform, widget.transform, (dynamic value) => Matrix4Tween(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      child: widget.child,
      transform: _transform.evaluate(animation),
      alignment: _alignment?.evaluate(animation),
      transformHitTests: widget.transformHitTests,
    );
  }
}