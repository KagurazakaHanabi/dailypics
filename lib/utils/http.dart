import 'package:dailypics/misc/config.g.dart';
import 'package:dio/dio.dart';

Dio http = Dio(BaseOptions(
  headers: {
    'user-agent': 'Dailypics/${Config.version} Version/${Config.buildNumber}',
  },
));
