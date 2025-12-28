import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/pexels_photo.dart';
import '../viewmodel/pexels_browser_viewmodel.dart';
import 'pexels_photo_card.dart';

/// 瀑布流网格组件
class PexelsPhotoGrid extends StatefulWidget {
  final PexelsBrowserViewModel viewModel;
  final Function(PexelsPhoto photo, String url)? onPhotoSelected;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const PexelsPhotoGrid({
    super.key,
    required this.viewModel,
    this.onPhotoSelected,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding,
  });

  @override
  State<PexelsPhotoGrid> createState() => _PexelsPhotoGridState();
}

class _PexelsPhotoGridState extends State<PexelsPhotoGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        // 首次加载
        if (state.loadingState == PexelsLoadingState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 错误状态
        if (state.loadingState == PexelsLoadingState.error &&
            state.photos.isEmpty) {
          return _ErrorView(
            message: state.errorMessage ?? '加载失败',
            onRetry: () => widget.viewModel.refresh(),
          );
        }

        // 空状态
        if (state.isEmpty) {
          return _EmptyView(
            query: state.searchQuery,
            onRefresh: () => widget.viewModel.refresh(),
          );
        }

        // 正常列表
        return RefreshIndicator(
          onRefresh: () => widget.viewModel.refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: widget.padding ?? const EdgeInsets.all(8),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,
                  childCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];
                    // 计算高度比例
                    final aspectRatio = photo.aspectRatio;
                    final height = 150 / aspectRatio;

                    return SizedBox(
                      height: height.clamp(100.0, 300.0),
                      child: PexelsPhotoCard(
                        photo: photo,
                        onTap: () => _showPhotoDetail(context, photo),
                      ),
                    );
                  },
                ),
              ),

              // 加载更多指示器
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // 没有更多数据
              if (!state.hasMore && state.photos.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '没有更多图片了',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoDetail(BuildContext context, PexelsPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => PexelsPhotoDetailDialog(
        photo: photo,
        onSelectUrl: (url) {
          widget.onPhotoSelected?.call(photo, url);
        },
      ),
    );
  }
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 空状态视图
class _EmptyView extends StatelessWidget {
  final String? query;
  final VoidCallback? onRefresh;

  const _EmptyView({
    this.query,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              query != null ? '未找到 "$query" 相关图片' : '暂无图片',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRefresh != null)
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新'),
              ),
          ],
        ),
      ),
    );
  }
}
