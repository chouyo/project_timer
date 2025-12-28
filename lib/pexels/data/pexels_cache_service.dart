import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pexels_photo.dart';

/// 两级缓存服务（Memory + SharedPreferences）
class PexelsCacheService {
  static final PexelsCacheService _instance = PexelsCacheService._internal();
  factory PexelsCacheService() => _instance;
  PexelsCacheService._internal();

  // 内存缓存
  final Map<String, _CacheEntry<PexelsResponse>> _memoryCache = {};

  // 缓存配置
  static const Duration _memoryCacheDuration = Duration(minutes: 5);
  static const Duration _diskCacheDuration = Duration(hours: 1);
  static const int _maxMemoryCacheSize = 50;
  static const String _diskCachePrefix = 'pexels_cache_';
  static const String _diskCacheKeysKey = 'pexels_cache_keys';

  /// 生成缓存键
  String _generateKey({
    String? query,
    int page = 1,
    int perPage = 15,
    String? orientation,
    String? color,
  }) {
    final parts = <String>[
      query ?? 'curated',
      'p$page',
      'pp$perPage',
    ];
    if (orientation != null) parts.add('o$orientation');
    if (color != null) parts.add('c$color');
    return parts.join('_');
  }

  /// 从缓存获取数据
  Future<PexelsResponse?> get({
    String? query,
    int page = 1,
    int perPage = 15,
    String? orientation,
    String? color,
  }) async {
    final key = _generateKey(
      query: query,
      page: page,
      perPage: perPage,
      orientation: orientation,
      color: color,
    );

    // 1. 先检查内存缓存
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data;
    }

    // 内存缓存过期，移除
    if (memoryEntry != null) {
      _memoryCache.remove(key);
    }

    // 2. 检查磁盘缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final diskKey = '$_diskCachePrefix$key';
      final jsonStr = prefs.getString(diskKey);

      if (jsonStr != null) {
        final Map<String, dynamic> cached = jsonDecode(jsonStr);
        final timestamp = cached['timestamp'] as int?;
        final data = cached['data'] as Map<String, dynamic>?;

        if (timestamp != null && data != null) {
          final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();

          if (now.difference(cachedTime) < _diskCacheDuration) {
            final response = PexelsResponse.fromJson(data);
            // 写入内存缓存
            _setMemoryCache(key, response);
            return response;
          } else {
            // 磁盘缓存过期，移除
            await prefs.remove(diskKey);
            await _removeDiskCacheKey(key);
          }
        }
      }
    } catch (e) {
      // 缓存读取失败，忽略错误
    }

    return null;
  }

  /// 设置缓存
  Future<void> set({
    required PexelsResponse response,
    String? query,
    int page = 1,
    int perPage = 15,
    String? orientation,
    String? color,
  }) async {
    final key = _generateKey(
      query: query,
      page: page,
      perPage: perPage,
      orientation: orientation,
      color: color,
    );

    // 1. 写入内存缓存
    _setMemoryCache(key, response);

    // 2. 写入磁盘缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final diskKey = '$_diskCachePrefix$key';
      final cached = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': response.toJson(),
      };
      await prefs.setString(diskKey, jsonEncode(cached));
      await _addDiskCacheKey(key);
    } catch (e) {
      // 缓存写入失败，忽略错误
    }
  }

  /// 设置内存缓存
  void _setMemoryCache(String key, PexelsResponse response) {
    // 检查内存缓存大小，超出则清理最旧的
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _cleanupMemoryCache();
    }

    _memoryCache[key] = _CacheEntry(
      data: response,
      createdAt: DateTime.now(),
      duration: _memoryCacheDuration,
    );
  }

  /// 清理内存缓存（移除过期和最旧的）
  void _cleanupMemoryCache() {
    // 移除过期的
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // 如果还是太多，移除最旧的一半
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final entries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

      final removeCount = _memoryCache.length ~/ 2;
      for (var i = 0; i < removeCount; i++) {
        _memoryCache.remove(entries[i].key);
      }
    }
  }

  /// 添加磁盘缓存键记录
  Future<void> _addDiskCacheKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_diskCacheKeysKey) ?? [];
    if (!keys.contains(key)) {
      keys.add(key);
      await prefs.setStringList(_diskCacheKeysKey, keys);
    }
  }

  /// 移除磁盘缓存键记录
  Future<void> _removeDiskCacheKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_diskCacheKeysKey) ?? [];
    keys.remove(key);
    await prefs.setStringList(_diskCacheKeysKey, keys);
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    // 清除内存缓存
    _memoryCache.clear();

    // 清除磁盘缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList(_diskCacheKeysKey) ?? [];
      for (final key in keys) {
        await prefs.remove('$_diskCachePrefix$key');
      }
      await prefs.remove(_diskCacheKeysKey);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清除指定查询的缓存
  Future<void> clearQuery(String? query) async {
    final prefix = query ?? 'curated';

    // 清除内存缓存
    _memoryCache.removeWhere((key, _) => key.startsWith(prefix));

    // 清除磁盘缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList(_diskCacheKeysKey) ?? [];
      final keysToRemove = keys.where((k) => k.startsWith(prefix)).toList();

      for (final key in keysToRemove) {
        await prefs.remove('$_diskCachePrefix$key');
        keys.remove(key);
      }
      await prefs.setStringList(_diskCacheKeysKey, keys);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final diskKeys = prefs.getStringList(_diskCacheKeysKey) ?? [];

    return {
      'memoryCacheCount': _memoryCache.length,
      'diskCacheCount': diskKeys.length,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
    };
  }
}

/// 缓存条目
class _CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration duration;

  _CacheEntry({
    required this.data,
    required this.createdAt,
    required this.duration,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > duration;
}
