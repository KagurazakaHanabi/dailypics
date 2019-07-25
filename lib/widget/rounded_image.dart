import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class RoundedImage extends StatelessWidget {
  final String imageUrl;

  final PlaceholderWidgetBuilder placeholder;

  final BoxFit fit;

  final BorderRadius borderRadius;

  RoundedImage({
    Key key,
    this.imageUrl,
    this.placeholder,
    this.fit,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: placeholder,
        fit: fit,
      ),
    );
  }
}
