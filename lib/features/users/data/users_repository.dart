import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../shared/storage.dart';
import '../model/user.dart';

class UsersRepository {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'x-api-key': 'reqres-free-v1',
      'Authorization': 'Bearer reqres-free-v1',
      'Content-Type': 'application/json',
    },
  ));

  static const _cacheKey = 'cached_users_json';

  Future<List<UserX>> fetchUsers() async {
    try {
      final conn = await Connectivity().checkConnectivity();
      if (conn == ConnectivityResult.none) {
        return _readCache();
      }

      final r = await _dio.get(
        'https://reqres.in/api/users',
        queryParameters: {'page': 1},
        options: Options(validateStatus: (_) => true),
      );

      if (r.statusCode == 200 && r.data is Map && r.data['data'] is List) {
        final List data = r.data['data'] as List;
        final users = data.map((e) => UserX.fromJson(e)).toList();
        await _writeCache(users);
        return users;
      }

      return _readCache();
    } catch (_) {
      return _readCache();
    }
  }

  Future<void> _writeCache(List<UserX> users) async {
    final jsonStr = jsonEncode(users.map((e) => e.toJson()).toList());
    await Storage.setString(_cacheKey, jsonStr);
  }

  Future<List<UserX>> _readCache() async {
    final s = await Storage.getString(_cacheKey);
    if (s == null) return [];
    final List data = jsonDecode(s) as List;
    return data.map((e) => UserX.fromJson(e)).toList();
  }
}
