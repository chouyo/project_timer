/// Pexels 图片浏览器模块
///
/// 提供 Pexels API 集成，支持图片浏览、搜索和选择功能
///
/// ## 功能特性
/// - 瀑布流网格布局
/// - 图片懒加载
/// - 下拉刷新
/// - 分页加载
/// - 两级缓存（Memory + SharedPreferences）
/// - 错误处理和空状态展示
///
/// ## 使用示例
///
/// ### 1. 作为Widget嵌入页面
/// ```dart
/// PexelsBrowserWidget(
///   apiKey: 'YOUR_PEXELS_API_KEY',
///   onImageSelected: (url) {
///     print('选中图片: $url');
///   },
/// )
/// ```
///
/// ### 2. 以底部弹窗形式展示
/// ```dart
/// final url = await showPexelsImagePicker(
///   context,
///   apiKey: 'YOUR_PEXELS_API_KEY',
///   title: '选择背景图片',
/// );
/// if (url != null) {
///   print('选中图片: $url');
/// }
/// ```
///
/// ### 3. 以全屏页面形式展示
/// ```dart
/// final url = await showPexelsImagePickerPage(
///   context,
///   apiKey: 'YOUR_PEXELS_API_KEY',
///   title: '选择图片',
///   initialQuery: 'nature',
/// );
/// ```
library;

// 导出模型
export 'models/pexels_photo.dart';

// 导出数据层
export 'data/pexels_api_client.dart';
export 'data/pexels_cache_service.dart';
export 'data/pexels_repository.dart';

// 导出 ViewModel
export 'viewmodel/pexels_browser_viewmodel.dart';

// 导出 Widgets
export 'widgets/pexels_photo_card.dart';
export 'widgets/pexels_photo_grid.dart';
export 'widgets/pexels_browser_widget.dart';
