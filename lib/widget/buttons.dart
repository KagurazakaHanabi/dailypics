import 'package:flutter/cupertino.dart';

class Button extends StatelessWidget {
  final Widget child;

  final Color color;

  final GestureTapCallback onPressed;

  const Button({
    Key key,
    @required this.child,
    this.color,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        decoration: BoxDecoration(
          color: color ?? CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(46),
        ),
        child: DefaultTextStyle(
          child: child,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoTheme.of(context).primaryContrastingColor,
          ),
        ),
      ),
    );
  }
}
