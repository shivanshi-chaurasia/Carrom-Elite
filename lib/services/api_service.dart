import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/errors/app_exception.dart';
import 'storage_service.dart';

class ApiService {
  ApiService(this.storage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 18),
            receiveTimeout: const Duration(seconds: 18),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.accessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401 && !_isRefresh(err.requestOptions)) {
            final retry = await _refreshAndRetry(err.requestOptions);
            if (retry != null) return handler.resolve(retry);
          }
          handler.next(err);
        },
      ),
    );
  }

  final StorageService storage;
  final Dio dio;

  bool _isRefresh(RequestOptions req) => req.path.contains(ApiEndpoints.refreshToken);

  Future<Response<dynamic>?> _refreshAndRetry(RequestOptions req) async {
    try {
      final refresh = await storage.refreshToken();
      if (refresh == null) return null;
      final res = await dio.post(ApiEndpoints.refreshToken, data: {'refreshToken': refresh});
      final data = Map<String, dynamic>.from(res.data as Map);
      await storage.saveTokens(data['accessToken'] ?? '', data['refreshToken'] ?? refresh);

      final opts = Options(method: req.method, headers: req.headers);
      opts.headers?['Authorization'] = 'Bearer ${data['accessToken']}';
      return dio.request<dynamic>(
        req.path,
        data: req.data,
        queryParameters: req.queryParameters,
        options: opts,
      );
    } catch (e) {
      print('token refresh failed $e');
      return null;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await dio.get(path, queryParameters: query);
      return res.data;
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ?? 'Something went wrong',
        code: e.response?.statusCode,
      );
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final res = await dio.post(path, data: data);
      return res.data;
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ?? 'Request failed',
        code: e.response?.statusCode,
      );
    }
  }
}
