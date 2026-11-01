import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/rooms/game_pix/models/game_pix_models.dart';

class GamePixController extends GetxController {
  static const int pageSize = 24;
  static const String sid = 'UOU4Y';

  final http.Client _client;
  final Future<Map<String, dynamic>> Function() _loadConfig;

  GamePixController({
    http.Client? client,
    Future<Map<String, dynamic>> Function()? loadConfig,
  }) : _client = client ?? http.Client(),
       _loadConfig =
           loadConfig ??
           (() => CallServerAPI.post(
             'game/gamePixConfig',
             {},
             withMessage: false,
           ));

  final RxList<GamePixCategoryModel> categories = <GamePixCategoryModel>[].obs;
  final RxSet<String> blockedGameIds = <String>{}.obs;
  final Rx<GamePixCategoryModel?> selectedCategory = Rx<GamePixCategoryModel?>(
    null,
  );
  final RxList<GamePixGameModel> games = <GamePixGameModel>[].obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString paginationErrorMessage = ''.obs;
  final RxBool hasMore = false.obs;

  int _requestGeneration = 0;
  bool _disposed = false;
  int _currentPage = 0;
  String? _nextUrl;
  final Set<String> _loadedGameIds = <String>{};
  final Set<Uri> _loadedPages = <Uri>{};

  Uri buildFeedUri({required String selectedCategoryKey, required int page}) {
    return Uri.https('feeds.gamepix.com', '/v2/json', {
      'sid': sid,
      'category': selectedCategoryKey,
      'pagination': pageSize.toString(),
      'page': page.toString(),
      'order': 'quality',
    });
  }

  Future<void> loadInitial({required String fallbackAllLabel}) async {
    if (_disposed || isInitialLoading.value || categories.isNotEmpty) return;

    final generation = ++_requestGeneration;
    isInitialLoading.value = true;
    isPageLoading.value = false;
    isRefreshing.value = false;
    errorMessage.value = '';
    paginationErrorMessage.value = '';
    games.clear();
    _loadedGameIds.clear();
    _currentPage = 0;
    _nextUrl = null;
    hasMore.value = false;

    try {
      final config = await _loadConfig();
      if (_disposed || generation != _requestGeneration) return;
      // The shared API helper returns {} on transport/authentication failure.
      // Never silently bypass server-side blocks by treating that as a config.
      if (config['gamePixConfig'] is! List ||
          config['blocked_game_ids'] is! List) {
        throw const FormatException('Invalid GamePix configuration');
      }

      categories.assignAll(
        _parseCategories(
          config['gamePixConfig'],
          fallbackAllLabel: fallbackAllLabel,
        ),
      );
      blockedGameIds.assignAll(_parseBlockedIds(config['blocked_game_ids']));
      selectedCategory.value = categories.first;
      await _loadPage(page: 1, generation: generation, replace: true);
    } catch (error) {
      if (generation == _requestGeneration) {
        errorMessage.value = error.toString();
      }
    } finally {
      if (generation == _requestGeneration) {
        isInitialLoading.value = false;
      }
    }
  }

  Future<void> retry({required String fallbackAllLabel}) {
    return categories.isEmpty
        ? loadInitial(fallbackAllLabel: fallbackAllLabel)
        : refreshGames();
  }

  Future<void> refreshGames() async {
    final category = selectedCategory.value;
    if (_disposed ||
        category == null ||
        isRefreshing.value ||
        isInitialLoading.value) {
      return;
    }

    final generation = ++_requestGeneration;
    isRefreshing.value = true;
    isPageLoading.value = false;
    errorMessage.value = '';
    paginationErrorMessage.value = '';

    try {
      await _loadPage(page: 1, generation: generation, replace: true);
    } catch (error) {
      if (generation == _requestGeneration) {
        errorMessage.value = error.toString();
      }
    } finally {
      if (generation == _requestGeneration) {
        isRefreshing.value = false;
      }
    }
  }

  Future<void> selectCategory(GamePixCategoryModel category) async {
    if (_disposed) return;
    if (selectedCategory.value?.key == category.key &&
        selectedCategory.value?.label == category.label) {
      return;
    }

    selectedCategory.value = category;
    final generation = ++_requestGeneration;
    isInitialLoading.value = true;
    isRefreshing.value = false;
    isPageLoading.value = false;
    errorMessage.value = '';
    paginationErrorMessage.value = '';
    games.clear();
    _loadedGameIds.clear();
    _currentPage = 0;
    _nextUrl = null;
    hasMore.value = false;

    try {
      await _loadPage(page: 1, generation: generation, replace: true);
    } catch (error) {
      if (generation == _requestGeneration) {
        errorMessage.value = error.toString();
      }
    } finally {
      if (generation == _requestGeneration) {
        isInitialLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (_disposed ||
        isInitialLoading.value ||
        isPageLoading.value ||
        isRefreshing.value ||
        !hasMore.value) {
      return;
    }

    final generation = _requestGeneration;
    isPageLoading.value = true;
    paginationErrorMessage.value = '';

    try {
      final nextPage = _currentPage + 1;
      await _loadPage(page: nextPage, generation: generation, replace: false);
    } catch (error) {
      if (generation == _requestGeneration) {
        paginationErrorMessage.value = error.toString();
      }
    } finally {
      if (generation == _requestGeneration) {
        isPageLoading.value = false;
      }
    }
  }

  bool isBlocked(GamePixGameModel game) {
    return blockedGameIds.contains(game.id.trim());
  }

  bool canOpenGame(GamePixGameModel game) {
    return game.id.trim().isNotEmpty &&
        !isBlocked(game) &&
        isAllowedGameUri(Uri.tryParse(game.url.trim()));
  }

  static bool isAllowedGameUri(Uri? uri) =>
      uri != null &&
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      uri.port == 443 &&
      isExpectedGamePixHost(uri.host);

  static bool _isFeedUri(Uri? uri) =>
      isAllowedGameUri(uri) &&
      uri!.host == 'feeds.gamepix.com' &&
      (uri.path == '/v2/json' || uri.path == '/v2/json/');

  static bool isExpectedGamePixHost(String host) {
    final normalized = host.toLowerCase().trim();
    return normalized == 'gamepix.com' || normalized.endsWith('.gamepix.com');
  }

  Future<void> _loadPage({
    required int page,
    required int generation,
    required bool replace,
  }) async {
    final category = selectedCategory.value;
    if (category == null) return;

    final uri = _nextUriFor(page: page, categoryKey: category.key);
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (_disposed ||
        generation != _requestGeneration ||
        selectedCategory.value?.key != category.key) {
      return;
    }
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid GamePix feed');
    }

    final feed = GamePixFeedModel.fromJson(body);
    if (replace) {
      games.clear();
      _loadedGameIds.clear();
      _loadedPages.clear();
    }

    final visibleItems = <GamePixGameModel>[];
    for (final game in feed.items) {
      final id = game.id.trim();
      if (!canOpenGame(game)) continue;
      if (_loadedGameIds.add(id)) {
        visibleItems.add(game);
      }
    }

    games.addAll(visibleItems);
    _loadedPages.add(uri);
    _currentPage = page;
    _nextUrl = feed.nextUrl;
    hasMore.value = _hasMore(feed);
  }

  Uri _nextUriFor({required int page, required String categoryKey}) {
    final next = _nextUrl;
    if (page > 1 && next != null && next.trim().isNotEmpty) {
      final parsed = Uri.tryParse(next.trim());
      if (_isFeedUri(parsed)) {
        return parsed!;
      }
    }
    return buildFeedUri(selectedCategoryKey: categoryKey, page: page);
  }

  bool _hasMore(GamePixFeedModel feed) {
    final next = feed.nextUrl?.trim();
    if (next == null || next.isEmpty) return false;
    final nextUri = Uri.tryParse(next);
    return _isFeedUri(nextUri) && !_loadedPages.contains(nextUri);
  }

  List<GamePixCategoryModel> _parseCategories(
    dynamic value, {
    required String fallbackAllLabel,
  }) {
    final parsed = <GamePixCategoryModel>[];
    final seenKeys = <String>{};

    if (value is List) {
      for (final item in value) {
        if (item is! Map) continue;
        final category = GamePixCategoryModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (category.label.isEmpty) continue;
        if (seenKeys.add(category.key)) {
          parsed.add(category);
        }
      }
    }

    if (parsed.isEmpty) {
      parsed.add(GamePixCategoryModel(key: '', label: fallbackAllLabel));
    }
    return parsed;
  }

  Set<String> _parseBlockedIds(dynamic value) {
    final parsed = <String>{};
    if (value is List) {
      for (final item in value) {
        final id = item?.toString().trim();
        if (id != null && id.isNotEmpty) {
          parsed.add(id);
        }
      }
    }
    return parsed;
  }

  @override
  void onClose() {
    _disposed = true;
    _requestGeneration++;
    _client.close();
    super.onClose();
  }
}
