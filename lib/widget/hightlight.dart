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
import 'package:flutter/gestures.dart';

typedef RecognizerBuilder = GestureRecognizer Function(String match);

class HighlightedText {
  final RecognizerBuilder recognizer;

  final TextStyle style;

  HighlightedText({this.recognizer, this.style});
}

class _LinkSpec {
  final HighlightedText pattern;

  final RegExpMatch origin;

  final String text;

  final int start;

  final int end;

  _LinkSpec(this.pattern, this.origin, this.text, this.start, this.end);

  @override
  String toString() {
    return '_LinkSpec { text: $text, start: $start, end: $end }';
  }
}

class Highlight extends StatelessWidget {
  final String text;

  final TextStyle defaultStyle;

  final TextStyle style;

  final Map<Pattern, HighlightedText> patterns;

  const Highlight({
    Key key,
    @required this.text,
    @required this.defaultStyle,
    @required this.style,
    @required this.patterns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<_LinkSpec> links = [];
    patterns.forEach((Pattern p, HighlightedText h) {
      p.allMatches(text).forEach((Match e) {
        int start = e.start, end = e.end;
        links.add(_LinkSpec(h, e, e.input.substring(start, end), start, end));
      });
    });
    links.sort((a, b) => a.start - b.start);
    return Text.rich(
      TextSpan(
        text: links.length == 0 ? text : text.substring(0, links[0].start),
        style: defaultStyle,
        children: links.map<InlineSpan>((_LinkSpec e) {
          HighlightedText p = e.pattern;
          int i = links.indexOf(e);
          bool last = i == links.length - 1;
          return TextSpan(
            text: e.text,
            recognizer: p.recognizer != null ? p.recognizer(e.text) : null,
            style: p.style ?? style,
            children: [
              TextSpan(
                style: defaultStyle,
                text: text.substring(e.end, last ? null : links[i + 1].start),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
