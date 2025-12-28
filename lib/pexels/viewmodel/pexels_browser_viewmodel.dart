import 'package:flutter/foundation.dart';
import '../data/pexels_api_client.dart';
import '../data/pexels_repository.dart';
import '../models/pexels_photo.dart';

/// 加载状态
enum PexelsLoadingState {
  initial, // 初始状态
  loading, // 首次加载中
  loadingMore, // 加载更多中
  refreshing, // 刷新中
  success, // 加载成功
  error, // 加载失败
  empty, // 无数据
}

/// Pexels 浏览器状态
class PexelsBrowserState {
  final List<PexelsPhoto> photos;
  final PexelsLoadingState loadingState;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;

  const PexelsBrowserState({
    this.photos = const [],
    this.loadingState = PexelsLoadingState.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
  });

  PexelsBrowserState copyWith({
    List<PexelsPhoto>? photos,
    PexelsLoadingState? loadingState,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return PexelsBrowserState(
      photos: photos ?? this.photos,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isLoading =>
      loadingState == PexelsLoadingState.loading ||
      loadingState == PexelsLoadingState.refreshing;

  bool get isLoadingMore => loadingState == PexelsLoadingState.loadingMore;

  bool get isEmpty =>
      loadingState == PexelsLoadingState.empty ||
      (loadingState == PexelsLoadingState.success && photos.isEmpty);
}

/// Pexels 浏览器 ViewModel
/// 使用 ValueNotifier 进行状态管理
class PexelsBrowserViewModel extends ChangeNotifier {
  final PexelsRepository _repository;
  final int _perPage;

  PexelsBrowserState _state = const PexelsBrowserState();
  PexelsBrowserState get state => _state;

  /// 状态通知器（用于监听特定状态变化）
  final ValueNotifier<PexelsLoadingState> loadingStateNotifier =
      ValueNotifier(PexelsLoadingState.initial);

  PexelsBrowserViewModel({
    required String apiKey,
    int perPage = 15,
    PexelsRepository? repository,
  })  : _perPage = perPage,
        _repository = repository ??
            PexelsRepository(
              apiClient: PexelsApiClient(apiKey: apiKey),
            );

  /// 更新状态
  void _updateState(PexelsBrowserState newState) {
    _state = newState;
    loadingStateNotifier.value = newState.loadingState;
    notifyListeners();
  }

  /// 加载精选图片
  Future<void> loadCuratedPhotos({bool forceRefresh = false}) async {
    if (_state.isLoading && !forceRefresh) return;

    _updateState(_state.copyWith(
      loadingState: forceRefresh
          ? PexelsLoadingState.refreshing
          : PexelsLoadingState.loading,
      errorMessage: null,
    ));

    try {
      final response = await _repository.getCuratedPhotos(
        page: 1,
        perPage: _perPage,
        forceRefresh: forceRefresh,
      );

      if (response.photos.isEmpty) {
        _updateState(_state.copyWith(
          photos: [],
          loadingState: PexelsLoadingState.empty,
          currentPage: 1,
          hasMore: false,
          searchQuery: null,
        ));
      } else {
        _updateState(_state.copyWith(
          photos: response.photos,
          loadingState: PexelsLoadingState.success,
          currentPage: 1,
          hasMore: response.hasMore,
          searchQuery: null,
        ));
      }
    } on PexelsNetworkException catch (e) {
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.error,
        errorMessage: '加载失败: ${e.toString()}',
      ));
    }
  }

  /// 搜索图片
  Future<void> searchPhotos(
    String query, {
    bool forceRefresh = false,
  }) async {
    if (query.trim().isEmpty) {
      await loadCuratedPhotos(forceRefresh: forceRefresh);
      return;
    }

    if (_state.isLoading && !forceRefresh) return;

    _updateState(_state.copyWith(
      loadingState: forceRefresh
          ? PexelsLoadingState.refreshing
          : PexelsLoadingState.loading,
      errorMessage: null,
      searchQuery: query,
    ));

    try {
      final response = await _repository.searchPhotos(
        query: query,
        page: 1,
        perPage: _perPage,
        forceRefresh: forceRefresh,
      );

      if (response.photos.isEmpty) {
        _updateState(_state.copyWith(
          photos: [],
          loadingState: PexelsLoadingState.empty,
          currentPage: 1,
          hasMore: false,
        ));
      } else {
        _updateState(_state.copyWith(
          photos: response.photos,
          loadingState: PexelsLoadingState.success,
          currentPage: 1,
          hasMore: response.hasMore,
        ));
      }
    } on PexelsNetworkException catch (e) {
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.error,
        errorMessage: '搜索失败: ${e.toString()}',
      ));
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_state.hasMore || _state.isLoading || _state.isLoadingMore) return;

    _updateState(_state.copyWith(
      loadingState: PexelsLoadingState.loadingMore,
    ));

    try {
      final nextPage = _state.currentPage + 1;
      final PexelsResponse response;

      if (_state.searchQuery != null && _state.searchQuery!.isNotEmpty) {
        response = await _repository.searchPhotos(
          query: _state.searchQuery!,
          page: nextPage,
          perPage: _perPage,
        );
      } else {
        response = await _repository.getCuratedPhotos(
          page: nextPage,
          perPage: _perPage,
        );
      }

      final newPhotos = [..._state.photos, ...response.photos];
      _updateState(_state.copyWith(
        photos: newPhotos,
        loadingState: PexelsLoadingState.success,
        currentPage: nextPage,
        hasMore: response.hasMore,
      ));
    } on PexelsNetworkException catch (e) {
      // 加载更多失败时恢复到成功状态
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.success,
        errorMessage: e.message,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        loadingState: PexelsLoadingState.success,
        errorMessage: '加载更多失败',
      ));
    }
  }

  /// 刷新
  Future<void> refresh() async {
    if (_state.searchQuery != null && _state.searchQuery!.isNotEmpty) {
      await searchPhotos(_state.searchQuery!, forceRefresh: true);
    } else {
      await loadCuratedPhotos(forceRefresh: true);
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await _repository.clearCache();
  }

  @override
  void dispose() {
    loadingStateNotifier.dispose();
    super.dispose();
  }
}
