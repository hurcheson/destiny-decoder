import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            // Tighter timeouts to surface errors faster on device
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 20),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  // Simple request/response logging for debugging connectivity during dev
  void enableLogging() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ignore: avoid_print
          print('[API] -> ${options.method} ${options.baseUrl}${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('[API] <- ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (e, handler) {
          // ignore: avoid_print
          print('[API] !! ${e.message} at ${e.requestOptions.baseUrl}${e.requestOptions.path}');
          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? e.message ?? 'Network error occurred';
      throw Exception(message);
    }
  }

  Future<List<int>> downloadFile(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is List<int>) {
        return response.data as List<int>;
      } else {
        throw Exception('Invalid response format for file download');
      }
    } on DioException catch (e) {
      final message = e.message ?? 'File download error occurred';
      throw Exception(message);
    }
  }
}
