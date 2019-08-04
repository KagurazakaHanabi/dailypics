import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class RoundedImage extends StatelessWidget {
  final String imageUrl;

  final PlaceholderWidgetBuilder placeholder;

  final BoxFit fit;

  final BorderRadius borderRadius;

  final Object heroTag;

  RoundedImage({
    Key key,
    this.imageUrl,
    this.placeholder,
    this.fit,
    this.borderRadius,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: placeholder,
          fit: fit,
        ),
      ),
    );
  }
}
