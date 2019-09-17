import 'package:daily_pics/misc/bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model {
  List<Picture> _today;
  List<Picture> get today => _today;
  set today(List<Picture> data) {
    _today = data;
    notifyListeners();
  }

  List<Picture> _recent;
  List<Picture> get recent => _recent;
  set recent(List<Picture> data) {
    _recent = data;
    notifyListeners();
  }

  static AppModel of(BuildContext context) {
    return ScopedModel.of<AppModel>(context);
  }
}
