import 'package:flutter/cupertino.dart';

const CupertinoDynamicColor _kBarColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x1F767680),
  darkColor: Color(0x3D767680),
);

const CupertinoDynamicColor _kClearColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

class CupertinoSearchBar extends StatelessWidget {
  final TextEditingController controller;

  final EdgeInsets padding;

  final bool readOnly;

  final bool autofocus;

  final bool showCancelButton;

  final ValueChanged<String> onChanged;

  final ValueChanged<String> onSubmitted;

  final GestureTapCallback onTap;

  CupertinoSearchBar({
    Key key,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 10),
    this.readOnly = false,
    this.autofocus = false,
    this.showCancelButton = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoTheme.of(context).barBackgroundColor,
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'CupertinoSearchBar',
              child: CupertinoTextField(
                controller: controller,
                readOnly: readOnly,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onTap: onTap,
                clearButtonMode: OverlayVisibilityMode.editing,
                textInputAction: TextInputAction.search,
                keyboardAppearance: CupertinoTheme.of(context).brightness,
                placeholder: '搜索',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _kBarColor.resolveFrom(context),
                ),
                prefix: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: _kClearColor.resolveFrom(context),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Hero(
            tag: 'CupertinoSearchBar.showCancelButton',
            child: Offstage(
              offstage: !showCancelButton,
              child: CupertinoButton(
                padding: EdgeInsets.only(left: 16),
                child: Text('取消', softWrap: false,),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
