/// Pexels 图片数据模型
class PexelsPhoto {
  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String photographerUrl;
  final int photographerId;
  final String avgColor;
  final PexelsSrc src;
  final bool liked;
  final String alt;

  PexelsPhoto({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.src,
    required this.liked,
    required this.alt,
  });

  /// 计算图片宽高比
  double get aspectRatio => width / height;

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    return PexelsPhoto(
      id: json['id'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String? ?? '',
      photographer: json['photographer'] as String? ?? '',
      photographerUrl: json['photographer_url'] as String? ?? '',
      photographerId: json['photographer_id'] as int? ?? 0,
      avgColor: json['avg_color'] as String? ?? '#CCCCCC',
      src: PexelsSrc.fromJson(json['src'] as Map<String, dynamic>),
      liked: json['liked'] as bool? ?? false,
      alt: json['alt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'url': url,
      'photographer': photographer,
      'photographer_url': photographerUrl,
      'photographer_id': photographerId,
      'avg_color': avgColor,
      'src': src.toJson(),
      'liked': liked,
      'alt': alt,
    };
  }
}

/// 图片资源链接
class PexelsSrc {
  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;

  PexelsSrc({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });

  factory PexelsSrc.fromJson(Map<String, dynamic> json) {
    return PexelsSrc(
      original: json['original'] as String? ?? '',
      large2x: json['large2x'] as String? ?? '',
      large: json['large'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      small: json['small'] as String? ?? '',
      portrait: json['portrait'] as String? ?? '',
      landscape: json['landscape'] as String? ?? '',
      tiny: json['tiny'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'large2x': large2x,
      'large': large,
      'medium': medium,
      'small': small,
      'portrait': portrait,
      'landscape': landscape,
      'tiny': tiny,
    };
  }
}

/// 分页响应模型
class PexelsResponse {
  final int page;
  final int perPage;
  final int totalResults;
  final String? nextPage;
  final List<PexelsPhoto> photos;

  PexelsResponse({
    required this.page,
    required this.perPage,
    required this.totalResults,
    this.nextPage,
    required this.photos,
  });

  bool get hasMore => nextPage != null && nextPage!.isNotEmpty;

  factory PexelsResponse.fromJson(Map<String, dynamic> json) {
    return PexelsResponse(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      totalResults: json['total_results'] as int? ?? 0,
      nextPage: json['next_page'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => PexelsPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total_results': totalResults,
      'next_page': nextPage,
      'photos': photos.map((e) => e.toJson()).toList(),
    };
  }
}
