import 'package:dio/dio.dart';
import '../../../shared/dio_client.dart';

class AuthRepository {
  final _dio = DioClient.i;

  Future<String> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(
        'https://reqres.in/api/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(validateStatus: (_) => true),
      );

      if (res.statusCode == 200 && res.data is Map && res.data['token'] != null) {
        return res.data['token'] as String;
      }

      // print("res.data ${res.data}");

      final msg = (res.data is Map && res.data['error'] is String)
          ? res.data['error'] as String
          : 'Login failed (${res.statusCode})';
      throw Exception(msg);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] is String)
          ? data['error'] as String
          : 'Network error';
      throw Exception(msg);
    }
  }
}
