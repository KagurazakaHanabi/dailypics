import 'package:dailypics/misc/config.g.dart';
import 'package:dio/dio.dart';

Dio http = Dio(BaseOptions(
  headers: {
    'User-Agent': 'Dailypics/${Config.version} Version/${Config.buildNumber}',
  },
));
