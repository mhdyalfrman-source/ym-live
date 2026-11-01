class GamePixCategoryModel {
  const GamePixCategoryModel({required this.key, required this.label});

  final String key;
  final String label;

  factory GamePixCategoryModel.fromJson(Map<String, dynamic> json) {
    return GamePixCategoryModel(
      key: json['key']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? '',
    );
  }
}

class GamePixFeedModel {
  const GamePixFeedModel({
    this.version,
    this.title,
    this.homePageUrl,
    this.feedUrl,
    this.nextUrl,
    this.firstPageUrl,
    this.lastPageUrl,
    this.modified,
    required this.items,
  });

  final String? version;
  final String? title;
  final String? homePageUrl;
  final String? feedUrl;
  final String? nextUrl;
  final String? firstPageUrl;
  final String? lastPageUrl;
  final String? modified;
  final List<GamePixGameModel> items;

  factory GamePixFeedModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return GamePixFeedModel(
      version: json['version']?.toString(),
      title: json['title']?.toString(),
      homePageUrl: json['home_page_url']?.toString(),
      feedUrl: json['feed_url']?.toString(),
      nextUrl: json['next_url']?.toString(),
      firstPageUrl: json['first_page_url']?.toString(),
      lastPageUrl: json['last_page_url']?.toString(),
      modified: json['modified']?.toString(),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => GamePixGameModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((game) => game.id.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class GamePixGameModel {
  const GamePixGameModel({
    required this.id,
    required this.title,
    this.namespace,
    this.description,
    this.category,
    this.orientation,
    this.qualityScore,
    this.width,
    this.height,
    this.dateModified,
    this.datePublished,
    this.bannerImage,
    this.image,
    required this.url,
  });

  final String id;
  final String title;
  final String? namespace;
  final String? description;
  final String? category;
  final String? orientation;
  final num? qualityScore;
  final int? width;
  final int? height;
  final String? dateModified;
  final String? datePublished;
  final String? bannerImage;
  final String? image;
  final String url;

  String get displayTitle => title.trim().isEmpty ? id : title.trim();

  Uri? launchUri(String languageCode) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        !(uri.host == 'gamepix.com' || uri.host.endsWith('.gamepix.com'))) {
      return null;
    }
    // Retain publisher attribution and the game's own query parameters.
    return uri.replace(
      queryParameters: {...uri.queryParametersAll, 'lang': languageCode},
    );
  }

  String? get cardImage {
    for (final candidate in [bannerImage, image]) {
      final uri = Uri.tryParse(candidate?.trim() ?? '');
      if (uri != null &&
          uri.scheme == 'https' &&
          uri.host.isNotEmpty &&
          uri.userInfo.isEmpty) {
        return uri.toString();
      }
    }
    return null;
  }

  factory GamePixGameModel.fromJson(Map<String, dynamic> json) {
    return GamePixGameModel(
      id: json['id']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
      namespace: _stringOrNull(json['namespace']),
      description: _stringOrNull(json['description']),
      category: _stringOrNull(json['category']),
      orientation: _stringOrNull(json['orientation']),
      qualityScore: _numOrNull(json['quality_score']),
      width: _intOrNull(json['width']),
      height: _intOrNull(json['height']),
      dateModified: _stringOrNull(json['date_modified']),
      datePublished: _stringOrNull(json['date_published']),
      bannerImage: _stringOrNull(json['banner_image']),
      image: _stringOrNull(json['image']),
      url: json['url']?.toString().trim() ?? '',
    );
  }

  static String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static num? _numOrNull(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }
}
