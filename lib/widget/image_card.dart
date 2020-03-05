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

import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/pages/details.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:dailypics/widget/animated_transform.dart';
import 'package:dailypics/widget/optimized_image.dart';
import 'package:dailypics/widget/qrcode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:markdown/markdown.dart' hide Text;

class ImageCard extends StatefulWidget {
  const ImageCard(
    this.data,
    this.heroTag, {
    this.padding = const EdgeInsets.all(16),
    this.aspectRatio = 4 / 5,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 4),
        spreadRadius: -24,
        blurRadius: 32,
      )
    ],
    this.showTexts = true,
    this.showQrCode = false,
    this.repaintKey,
  }) : assert(aspectRatio != null);

  final Picture data;

  final String heroTag;

  final EdgeInsets padding;

  final double aspectRatio;

  final List<BoxShadow> boxShadow;

  final bool showQrCode;

  final bool showTexts;

  final GlobalKey repaintKey;

  @override
  State<StatefulWidget> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final Duration duration = const Duration(milliseconds: 150);

  double scale = 1;
  DateTime tapDown;

  @override
  Widget build(BuildContext context) {
    Color textColor = Utils.isDarkColor(widget.data.color)
        ? CupertinoColors.white
        : CupertinoColors.black;
    return AnimatedTransform.scale(
      scale: scale,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio ?? 4 / 5,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.boxShadow,
          ),
          child: GestureDetector(
            onTapDown: (_) {
              tapDown = DateTime.now();
              setState(() => scale = 0.97);
            },
            onTapCancel: () => setState(() => scale = 1.0),
            onTapUp: (_) async {
              if (DateTime.now().difference(tapDown) < duration) {
                await Future.delayed(duration);
              }
              setState(() => scale = 1.0);
              DetailsPage.push(
                context,
                data: widget.data,
                heroTag: widget.heroTag,
              );
            },
            child: RepaintBoundary(
              key: widget.repaintKey,
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: OptimizedImage(
                      Utils.getCompressed(widget.data),
                      heroTag: widget.heroTag,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  if (widget.showTexts)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.data.title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 28,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              markdownToHtml(widget.data.content.split('\n')[0])
                                  .replaceAll(RegExp(r'<[^>]+>'), ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor.withAlpha(0xB3),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.showQrCode)
                    AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: QrCodeView(
                          widget.data.url?.contains('bing.com/') ?? false
                              ? 'https://cn.bing.com/'
                              : 'https://dailypics.cn/p/${widget.data.id}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
