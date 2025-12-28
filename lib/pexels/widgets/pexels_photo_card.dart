import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pexels_photo.dart';

/// 单个图片卡片组件
class PexelsPhotoCard extends StatelessWidget {
  final PexelsPhoto photo;
  final VoidCallback? onTap;
  final bool showPhotographer;

  const PexelsPhotoCard({
    super.key,
    required this.photo,
    this.onTap,
    this.showPhotographer = true,
  });

  /// 解析颜色字符串
  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholderColor = _parseColor(photo.avgColor);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 图片
            Hero(
              tag: 'pexels_photo_${photo.id}',
              child: CachedNetworkImage(
                imageUrl: photo.src.medium,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: placeholderColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: placeholderColor,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            // 摄影师信息
            if (showPhotographer)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    photo.photographer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 图片详情对话框
class PexelsPhotoDetailDialog extends StatelessWidget {
  final PexelsPhoto photo;
  final Function(String url)? onSelectUrl;

  const PexelsPhotoDetailDialog({
    super.key,
    required this.photo,
    this.onSelectUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片预览
            Flexible(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'pexels_photo_${photo.id}',
                  child: CachedNetworkImage(
                    imageUrl: photo.src.large,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),

            // 信息和操作区
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 摄影师信息
                  Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          photo.photographer,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),

                  if (photo.alt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      photo.alt,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 尺寸选择按钮
                  Text(
                    '选择尺寸',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SizeButton(
                        label: '原图',
                        onTap: () =>
                            _selectAndClose(context, photo.src.original),
                      ),
                      _SizeButton(
                        label: '大图',
                        onTap: () => _selectAndClose(context, photo.src.large),
                      ),
                      _SizeButton(
                        label: '中图',
                        onTap: () => _selectAndClose(context, photo.src.medium),
                      ),
                      _SizeButton(
                        label: '小图',
                        onTap: () => _selectAndClose(context, photo.src.small),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAndClose(BuildContext context, String url) {
    Navigator.of(context).pop();
    onSelectUrl?.call(url);
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
