import 'package:dio/dio.dart';


class DioClient {
  DioClient._();
  // static final Dio _dio = Dio(BaseOptions(
  //   connectTimeout: const Duration(seconds: 10),
  //   receiveTimeout: const Duration(seconds: 20),
  //   sendTimeout: const Duration(seconds: 10),
  // ));
    // ..interceptors.add(LogInterceptor(responseBody: false));

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'x-api-key': 'reqres-free-v1',
      'Authorization': 'Bearer reqres-free-v1', // optional
      'Content-Type': 'application/json',
    },
  ));


  static Dio get i => _dio;
}