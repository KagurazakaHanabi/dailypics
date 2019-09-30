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

import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] with simple API.
class LocalStorage {
  static LocalStorage _instance;

  static LocalStorage getInstance(SharedPreferences prefs) {
    if (_instance == null) {
      _instance = LocalStorage._(prefs);
    }
    return _instance;
  }

  LocalStorage._(this._preferences);

  factory LocalStorage(SharedPreferences parent) => getInstance(parent);

  final SharedPreferences _preferences;

  Future<bool> clear() => _preferences.clear();

  bool containsKey(String key) => _preferences.containsKey(key);

  dynamic get(String key) => _preferences.get(key);

  Future<bool> set(String key, dynamic value) {
    if (value == null) {
      return _preferences.remove(key);
    }
    if (value is bool) {
      return _preferences.setBool(key, value);
    } else if (value is int) {
      return _preferences.setInt(key, value);
    } else if (value is double) {
      return _preferences.setDouble(key, value);
    } else if (value is String) {
      return _preferences.setString(key, value);
    } else if (value is List<String>) {
      return _preferences.setStringList(key, value);
    } else {
      throw UnsupportedError(
        'The type of value must be one of bool, int, double, String, and List<String>.',
      );
    }
  }

  Set<String> getKeys() => _preferences.getKeys();

  bool getBool(String key) => _preferences.getBool(key);

  int getInt(String key) => _preferences.getInt(key);

  double getDouble(String key) => _preferences.getDouble(key);

  String getString(String key) => _preferences.getString(key);

  List<String> getStringList(String key) => _preferences.getStringList(key);

  dynamic operator [](String key) {
    dynamic value = get(key);
    if (value is List) {
      return value.cast<String>();
    }
    return value;
  }

  /// 慎用！
  void operator []=(String key, dynamic value) => set(key, value);

  Future<bool> setBool(String key, bool value) => _preferences.setBool(key, value);

  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);

  Future<bool> setDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _preferences.setStringList(key, value);
  }
}
