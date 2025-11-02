import 'package:shared_preferences/shared_preferences.dart';


class KV {
  static const token = 'auth_token';
  static const cachedUsers = 'cached_users_json';
}


class Storage {
  static Future<void> setString(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }


  static Future<String?> getString(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }


  static Future<void> remove(String key) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }
}