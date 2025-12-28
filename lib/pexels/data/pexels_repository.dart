import 'package:dio/dio.dart';
import '../models/pexels_photo.dart';
import 'pexels_api_client.dart';
import 'pexels_cache_service.dart';

/// Pexels 数据仓库
/// 协调 API 客户端和缓存服务
class PexelsRepository {
  final PexelsApiClient _apiClient;
  final PexelsCacheService _cacheService;

  PexelsRepository({
    required PexelsApiClient apiClient,
    PexelsCacheService? cacheService,
  })  : _apiClient = apiClient,
        _cacheService = cacheService ?? PexelsCacheService();

  /// 获取精选图片
  Future<PexelsResponse> getCuratedPhotos({
    int page = 1,
    int perPage = 15,
    bool forceRefresh = false,
  }) async {
    // 检查缓存
    if (!forceRefresh) {
      final cached = await _cacheService.get(
        page: page,
        perPage: perPage,
      );
      if (cached != null) {
        return cached;
      }
    }

    // 从网络获取
    try {
      final response = await _apiClient.getCuratedPhotos(
        page: page,
        perPage: perPage,
      );

      final pexelsResponse = PexelsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // 缓存结果
      await _cacheService.set(
        response: pexelsResponse,
        page: page,
        perPage: perPage,
      );

      return pexelsResponse;
    } on DioException catch (e) {
      throw PexelsNetworkException.fromDioException(e);
    }
  }

  /// 搜索图片
  Future<PexelsResponse> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 15,
    String? orientation,
    String? size,
    String? color,
    bool forceRefresh = false,
  }) async {
    // 检查缓存
    if (!forceRefresh) {
      final cached = await _cacheService.get(
        query: query,
        page: page,
        perPage: perPage,
        orientation: orientation,
        color: color,
      );
      if (cached != null) {
        return cached;
      }
    }

    // 从网络获取
    try {
      final response = await _apiClient.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
        orientation: orientation,
        size: size,
        color: color,
      );

      final pexelsResponse = PexelsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // 缓存结果
      await _cacheService.set(
        response: pexelsResponse,
        query: query,
        page: page,
        perPage: perPage,
        orientation: orientation,
        color: color,
      );

      return pexelsResponse;
    } on DioException catch (e) {
      throw PexelsNetworkException.fromDioException(e);
    }
  }

  /// 获取单张图片详情
  Future<PexelsPhoto> getPhoto(int id) async {
    try {
      final response = await _apiClient.getPhoto(id);
      return PexelsPhoto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw PexelsNetworkException.fromDioException(e);
    }
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    await _cacheService.clearAll();
  }

  /// 清除指定查询的缓存
  Future<void> clearQueryCache(String? query) async {
    await _cacheService.clearQuery(query);
  }

  /// 获取缓存统计
  Future<Map<String, dynamic>> getCacheStats() async {
    return _cacheService.getStats();
  }
}
