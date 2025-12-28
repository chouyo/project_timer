import 'package:dio/dio.dart';

/// Pexels API 客户端
/// 使用 Dio 进行网络请求，配置拦截器处理 API 密钥
class PexelsApiClient {
  static const String _baseUrl = 'https://api.pexels.com/v1';

  final Dio _dio;
  final String apiKey;

  PexelsApiClient({required this.apiKey}) : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    );

    // 添加拦截器
    _dio.interceptors.add(_PexelsAuthInterceptor(apiKey));
    _dio.interceptors.add(_PexelsLogInterceptor());
  }

  /// 获取精选图片（Curated Photos）
  Future<Response> getCuratedPhotos({
    int page = 1,
    int perPage = 15,
  }) async {
    return _dio.get(
      '/curated',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  /// 搜索图片
  Future<Response> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 15,
    String? orientation, // landscape, portrait, square
    String? size, // large, medium, small
    String? color,
    String? locale,
  }) async {
    final Map<String, dynamic> params = {
      'query': query,
      'page': page,
      'per_page': perPage,
    };

    if (orientation != null) params['orientation'] = orientation;
    if (size != null) params['size'] = size;
    if (color != null) params['color'] = color;
    if (locale != null) params['locale'] = locale;

    return _dio.get('/search', queryParameters: params);
  }

  /// 获取单张图片详情
  Future<Response> getPhoto(int id) async {
    return _dio.get('/photos/$id');
  }

  /// 取消所有请求
  void cancelRequests() {
    _dio.close(force: true);
  }
}

/// API 密钥认证拦截器
class _PexelsAuthInterceptor extends Interceptor {
  final String apiKey;

  _PexelsAuthInterceptor(this.apiKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = apiKey;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理特定错误
    if (err.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'API 密钥无效或已过期',
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }

    if (err.response?.statusCode == 429) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: '请求过于频繁，请稍后再试',
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }

    handler.next(err);
  }
}

/// 日志拦截器（调试用）
class _PexelsLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 调试时可以打开日志
    // print('Pexels API Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('Pexels API Response: ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // print('Pexels API Error: ${err.message}');
    handler.next(err);
  }
}

/// 网络错误类型
enum PexelsNetworkErrorType {
  unauthorized,
  rateLimited,
  serverError,
  connectionError,
  timeout,
  unknown,
}

/// Pexels 网络异常
class PexelsNetworkException implements Exception {
  final String message;
  final PexelsNetworkErrorType type;
  final int? statusCode;

  PexelsNetworkException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  factory PexelsNetworkException.fromDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      return PexelsNetworkException(
        message: 'API 密钥无效',
        type: PexelsNetworkErrorType.unauthorized,
        statusCode: 401,
      );
    }

    if (e.response?.statusCode == 429) {
      return PexelsNetworkException(
        message: '请求过于频繁',
        type: PexelsNetworkErrorType.rateLimited,
        statusCode: 429,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return PexelsNetworkException(
        message: '请求超时',
        type: PexelsNetworkErrorType.timeout,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return PexelsNetworkException(
        message: '网络连接失败',
        type: PexelsNetworkErrorType.connectionError,
      );
    }

    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return PexelsNetworkException(
        message: '服务器错误',
        type: PexelsNetworkErrorType.serverError,
        statusCode: e.response?.statusCode,
      );
    }

    return PexelsNetworkException(
      message: e.message ?? '未知错误',
      type: PexelsNetworkErrorType.unknown,
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'PexelsNetworkException: $message (type: $type)';
}
