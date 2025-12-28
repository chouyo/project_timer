import 'package:flutter/material.dart';
import '../models/pexels_photo.dart';
import '../viewmodel/pexels_browser_viewmodel.dart';
import 'pexels_photo_grid.dart';

/// Pexels 图片浏览器主组件
/// 集成搜索、瀑布流展示、图片选择功能
class PexelsBrowserWidget extends StatefulWidget {
  /// Pexels API 密钥
  final String apiKey;

  /// 图片选中回调，返回选中的图片URL
  final Function(String url)? onImageSelected;

  /// 图片选中回调，返回图片对象和URL
  final Function(PexelsPhoto photo, String url)? onPhotoSelected;

  /// 每页加载数量
  final int perPage;

  /// 网格列数
  final int crossAxisCount;

  /// 是否显示搜索栏
  final bool showSearchBar;

  /// 初始搜索关键词
  final String? initialQuery;

  /// 标题
  final String? title;

  /// 是否以页面形式展示（包含AppBar）
  final bool asPage;

  const PexelsBrowserWidget({
    super.key,
    required this.apiKey,
    this.onImageSelected,
    this.onPhotoSelected,
    this.perPage = 15,
    this.crossAxisCount = 2,
    this.showSearchBar = true,
    this.initialQuery,
    this.title,
    this.asPage = false,
  });

  @override
  State<PexelsBrowserWidget> createState() => _PexelsBrowserWidgetState();
}

class _PexelsBrowserWidgetState extends State<PexelsBrowserWidget> {
  late final PexelsBrowserViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = PexelsBrowserViewModel(
      apiKey: widget.apiKey,
      perPage: widget.perPage,
    );

    // 初始加载
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _viewModel.searchPhotos(widget.initialQuery!);
    } else {
      _viewModel.loadCuratedPhotos();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    _searchFocusNode.unfocus();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _viewModel.loadCuratedPhotos(forceRefresh: true);
    } else {
      _viewModel.searchPhotos(query);
    }
  }

  void _onPhotoSelected(PexelsPhoto photo, String url) {
    widget.onImageSelected?.call(url);
    widget.onPhotoSelected?.call(photo, url);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // 搜索栏
        if (widget.showSearchBar)
          Padding(
            padding: const EdgeInsets.all(8),
            child: _SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSearch: _onSearch,
              onClear: () {
                _searchController.clear();
                _viewModel.loadCuratedPhotos(forceRefresh: true);
              },
            ),
          ),

        // 图片网格
        Expanded(
          child: PexelsPhotoGrid(
            viewModel: _viewModel,
            crossAxisCount: widget.crossAxisCount,
            onPhotoSelected: _onPhotoSelected,
          ),
        ),
      ],
    );

    // 作为页面展示
    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Pexels 图库'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _viewModel.refresh(),
              tooltip: '刷新',
            ),
          ],
        ),
        body: content,
      );
    }

    return content;
  }
}

/// 搜索栏组件
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: '搜索图片...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            );
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
    );
  }
}

/// 便捷方法：以底部弹窗形式展示图片选择器
Future<String?> showPexelsImagePicker(
  BuildContext context, {
  required String apiKey,
  String? title,
  String? initialQuery,
  int crossAxisCount = 2,
  double heightFactor = 0.8,
}) async {
  String? selectedUrl;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖动指示条
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title ?? '选择图片',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 图片浏览器
          Expanded(
            child: PexelsBrowserWidget(
              apiKey: apiKey,
              crossAxisCount: crossAxisCount,
              initialQuery: initialQuery,
              onImageSelected: (url) {
                selectedUrl = url;
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    ),
  );

  return selectedUrl;
}

/// 便捷方法：以全屏页面形式展示图片选择器
Future<String?> showPexelsImagePickerPage(
  BuildContext context, {
  required String apiKey,
  String? title,
  String? initialQuery,
  int crossAxisCount = 2,
}) async {
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (context) => _PexelsPickerPage(
        apiKey: apiKey,
        title: title ?? '选择图片',
        initialQuery: initialQuery,
        crossAxisCount: crossAxisCount,
      ),
    ),
  );

  return result;
}

class _PexelsPickerPage extends StatelessWidget {
  final String apiKey;
  final String title;
  final String? initialQuery;
  final int crossAxisCount;

  const _PexelsPickerPage({
    required this.apiKey,
    required this.title,
    this.initialQuery,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PexelsBrowserWidget(
        apiKey: apiKey,
        crossAxisCount: crossAxisCount,
        initialQuery: initialQuery,
        showSearchBar: true,
        onImageSelected: (url) {
          Navigator.of(context).pop(url);
        },
      ),
    );
  }
}
