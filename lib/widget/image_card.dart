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
import 'package:daily_pics/pages/details.dart';
import 'package:daily_pics/utils/utils.dart';
import 'package:daily_pics/widget/animated_transform.dart';
import 'package:daily_pics/widget/optimized_image.dart';
import 'package:daily_pics/widget/qrcode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

class ImageCard extends StatefulWidget {
  final Picture data;

  final String heroTag;

  final double aspectRatio;

  final bool showQrCode;

  final GlobalKey repaintKey;

  ImageCard(
    this.data,
    this.heroTag, {
    this.aspectRatio = 4 / 5,
    this.showQrCode = false,
    this.repaintKey,
  }) : assert(aspectRatio != null);

  @override
  State<StatefulWidget> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final Duration duration = Duration(milliseconds: 150);

  double scale = 1;
  DateTime tapDown;

  @override
  Widget build(BuildContext context) {
    Color textColor = Utils.isDarkColor(widget.data.color)
        ? Colors.white
        : Colors.black;
    return AnimatedTransform.scale(
      scale: scale,
      duration: duration,
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio ?? 4 / 5,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                spreadRadius: -24,
                blurRadius: 32,
              )
            ],
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
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 32, right: 16),
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
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            widget.data.content,
                            maxLines: 1,
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
                        padding: EdgeInsets.only(right: 8, bottom: 8),
                        child: QrCodeView(
                          widget.data.url.contains('bing.com/')
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
