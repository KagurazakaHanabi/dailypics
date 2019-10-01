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

import 'package:daily_pics/misc/bean.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'image_card.dart';

class SliverImageCardList extends StatelessWidget {
  final Widget header;

  final Widget footer;

  final List<Picture> data;

  final String Function(int index) tagBuilder;

  final bool adaptiveTablet;

  const SliverImageCardList({
    Key key,
    this.header,
    this.footer,
    @required this.data,
    this.tagBuilder,
    this.adaptiveTablet = false,
  })  : assert(data != null),
        assert(adaptiveTablet != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bool iPad = SystemUtils.isIPad(context, true);
    bool portrait = SystemUtils.isPortrait(context);
    int cnt = SystemUtils.isIPad(context)
        ? iPad && !portrait && adaptiveTablet ? 6 : 2
        : 1;
    return SliverPadding(
      padding: SystemUtils.isIPad(context, true)
          ? EdgeInsets.fromLTRB(12, 12, 12, 0)
          : EdgeInsets.only(left: 4, top: 15, right: 4),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: cnt,
        itemCount: data.length + 2,
        staggeredTileBuilder: (i) {
          if (i == 0 || i == data.length + 1) {
            return StaggeredTile.fit(cnt);
          } else if (iPad && !portrait && adaptiveTablet) {
            if (_needWiden(i)) {
              return StaggeredTile.count(4, 3);
            } else {
              return StaggeredTile.count(2, 3);
            }
          } else {
            return StaggeredTile.fit(1);
          }
        },
        itemBuilder: (_, int i) {
          if (i == 0) {
            return header ?? Container();
          } else if (i == data.length + 1) {
            return footer ?? Container();
          } else if (iPad && !portrait && adaptiveTablet) {
            return ImageCard(
              data[i - 1],
              tagBuilder != null ? tagBuilder(i - 1) : '#$i',
              aspectRatio: _needWiden(i) ? 4 / 3 : 2 / 3.15,
            );
          } else {
            return ImageCard(
              data[i - 1],
              tagBuilder != null ? tagBuilder(i - 1) : '#$i',
            );
          }
        },
      ),
    );
  }

  bool _needWiden(int index) {
    return index % 4 == 1 || index % 4 == 0;
  }
}
