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