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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;

  final BorderRadius borderRadius;

  final Object heroTag;

  OptimizedImage({
    Key key,
    this.imageUrl,
    this.borderRadius = BorderRadius.zero,
    this.heroTag,
  })  : assert(imageUrl != null),
        assert(borderRadius != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholderFadeInDuration: Duration.zero,
        fadeInDuration: Duration(milliseconds: 700),
        fadeInCurve: Curves.easeIn,
        fadeOutDuration: Duration(milliseconds: 300),
        fadeOutCurve: Curves.easeOut,
        placeholder: (_, __) {
          return Container(
            color: Color(0xFFE0E0E0),
            alignment: Alignment.center,
            child: Image.asset('res/placeholder.jpg'),
          );
        },
      ),
    );
    if (result != null) {
      result = Hero(
        tag: heroTag,
        transitionOnUserGestures: true,
        child: result,
      );
    }
    return result;
  }
}
