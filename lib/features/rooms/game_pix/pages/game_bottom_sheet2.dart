import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/game_pix/controllers/game_pix_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/models/game_pix_models.dart';
import 'package:tom_chat/features/rooms/game_pix/pages/game_pix_game_page.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class Games2BottomSheet extends StatefulWidget {
  final String liveuid;
  // The sheet owns and closes this controller, including an injected instance.
  final GamePixController? controller;

  const Games2BottomSheet({super.key, required this.liveuid, this.controller});

  static bool _showing = false;

  static Future<T?> show<T>(BuildContext context, String liveuid) async {
    if (_showing) return null;
    _showing = true;
    try {
      return await AppBottomSheet.show<T>(
        context: context,
        maxHeight: Get.height * 0.8,
        padding: EdgeInsets.zero,
        child: Games2BottomSheet(liveuid: liveuid),
        hideHeader: true,
        borderRadius: 0,
        isScrollable: false,
      );
    } finally {
      _showing = false;
    }
  }

  @override
  State<Games2BottomSheet> createState() => _Games2BottomSheetState();
}

class _Games2BottomSheetState extends State<Games2BottomSheet>
    with TickerProviderStateMixin {
  late final GamePixController _controller;
  late final ScrollController _scrollController;
  TabController? _tabController;
  int _tabCount = 0;
  bool _openingGame = false;
  bool _roomEnded = false;
  final List<Worker> _roomWorkers = [];
  ModalRoute<dynamic>? _gameRoute;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? Get.put(GamePixController(),permanent: true);
    if (Get.isRegistered<RoomController>()) {
      final room = Get.find<RoomController>();
      _roomWorkers.add(
        ever(room.room, (_) {
          if (room.room.value.id.toString() != widget.liveuid) _closeForRoom();
        }),
      );
      _roomWorkers.add(
        ever(room.isRoomConnected, (connected) {
          if (!connected) _closeForRoom();
        }),
      );
    }
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _roomEnded) return;
      _controller.loadInitial(fallbackAllLabel: context.l10n.gameList);
    });
  }

  @override
  void dispose() {
    for (final worker in _roomWorkers) {
      worker.dispose();
    }
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _closeForRoom() {
    if (!mounted || _roomEnded) return;
    _roomEnded = true;
    final catalogRoute = ModalRoute.of(context);
    // Remove only routes owned by this catalog; a room-ended screen may
    // already have been pushed by the socket listener.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final route in [_gameRoute, catalogRoute]) {
        if (route != null && route.isActive) {
          route.navigator?.removeRoute(route);
        }
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      _controller.loadMore();
    }
  }

  void _syncTabController(int count) {
    if (count <= 0 || count == _tabCount) return;
    _tabController?.dispose();
    _tabCount = count;
    _tabController = TabController(length: count, vsync: this);
  }

  Future<void> _openGame(GamePixGameModel game) async {
    if (_openingGame || _roomEnded || !mounted) return;
    if (!_controller.canOpenGame(game)) {
      snakbarDialog(
        title: context.l10n.errorOcoredPleaseTryAgain,
        durationSecound: 5,
      );
      return;
    }
    _openingGame = true;
    try {
      await AppBottomSheet.show<void>(
        context: context,
        maxHeight: Get.height * 0.8,
        padding: EdgeInsets.zero,
        child: Builder(
          builder: (context) {
            _gameRoute = ModalRoute.of(context);
            return GamePixGamePage(game: game);
          },
        ),
        isScrollable: false,
        enableDrag: false,
        hideHeader: true,
        borderRadius: 0,
        isDismissible: false,
      );
    } finally {
      _gameRoute = null;
      _openingGame = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardWidget(
      colorIndex: 1,
      radius: 10,
      child: SizedBox(
        height: Get.height * 0.8,
        child: Obx(() {
          final categories = _controller.categories.toList(growable: false);
          _syncTabController(categories.length);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (categories.isNotEmpty)
                _GamePixCategoryTabs(
                  tabController: _tabController!,
                  categories: categories,
                  selectedCategory: _controller.selectedCategory.value,
                  onTap: (index) =>
                      _controller.selectCategory(categories[index]),
                ),
              if (_controller.games.isNotEmpty &&
                  _controller.errorMessage.value.isNotEmpty)
                TextButton.icon(
                  onPressed: _controller.refreshGames,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.errorOcoredPleaseTryAgain),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _buildBody(theme),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_controller.isInitialLoading.value && _controller.games.isEmpty) {
      return const _GamePixLoadingGrid(key: ValueKey('loading'));
    }

    if (_controller.errorMessage.value.isNotEmpty &&
        _controller.games.isEmpty) {
      return _GamePixErrorState(
        key: const ValueKey('error'),
        message: context.l10n.errorOcoredPleaseTryAgain,
        onRetry: () =>
            _controller.retry(fallbackAllLabel: context.l10n.gameList),
      );
    }

    if (_controller.games.isEmpty) {
      return _GamePixEmptyState(
        key: const ValueKey('empty'),
        message: context.l10n.noDataFound,
        onRetry: _controller.hasMore.value
            ? _controller.loadMore
            : _controller.refreshGames,
        isLoading:
            _controller.isPageLoading.value || _controller.isRefreshing.value,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refreshGames,
      color: AppColors.primaryDark,
      child: GridView.builder(
        key: const ValueKey('grid'),
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.82,
        ),
        itemCount:
            _controller.games.length +
            (_controller.hasMore.value ||
                    _controller.isPageLoading.value ||
                    _controller.paginationErrorMessage.value.isNotEmpty
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (index >= _controller.games.length) {
            if (_controller.paginationErrorMessage.value.isNotEmpty) {
              return _PaginationErrorCard(onRetry: _controller.loadMore);
            }
            return _PaginationLoadingCard();
          }
          final game = _controller.games[index];
          return _GamePixCard(
            key: ValueKey(game.id),
            game: game,
            onTap: () => _openGame(game),
          );
        },
      ),
    );
  }
}

class _GamePixCategoryTabs extends StatelessWidget {
  const _GamePixCategoryTabs({
    required this.tabController,
    required this.categories,
    required this.selectedCategory,
    required this.onTap,
  });

  final TabController tabController;
  final List<GamePixCategoryModel> categories;
  final GamePixCategoryModel? selectedCategory;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = categories.indexWhere(
      (category) => category.key == selectedCategory?.key,
    );
    if (selectedIndex >= 0 && tabController.index != selectedIndex) {
      tabController.index = selectedIndex;
    }

    return TabBar(
      controller: tabController,
      isScrollable: true,
      onTap: onTap,
      labelStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
      dividerColor: Colors.transparent,

      tabs: [
        for (final category in categories)
          Tab(text: category.label, height: 42.h),
      ],
    );
  }
}

class _GamePixCard extends StatelessWidget {
  const _GamePixCard({super.key, required this.game, required this.onTap});

  final GamePixGameModel game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = game.cardImage;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (180 * dpr).round();
    final cacheHeight = (120 * dpr).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Ink(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: imageUrl == null
                      ? const Icon(Icons.broken_image, color: Colors.grey)
                      : CachedImage(
                          imageUrl,
                          fit: BoxFit.cover,
                          type: ImageType.general,
                          cacheWidth: cacheWidth,
                          cacheHeight: cacheHeight,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          if (game.category != null)
                            Expanded(
                              child: Text(
                                game.category!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GamePixLoadingGrid extends StatelessWidget {
  const _GamePixLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(
      color: Colors.white,
    ));
  }
}

class _GamePixEmptyState extends StatelessWidget {
  const _GamePixEmptyState({
    super.key,
    required this.message,
    required this.onRetry,
    required this.isLoading,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(),
            ),
            if (isLoading)
              const CircularProgressIndicator()
            else
              TextButton(
                onPressed: onRetry,
                child: Text(context.l10n.diceRetry),
              ),
          ],
        ),
      ),
    );
  }
}

class _GamePixErrorState extends StatelessWidget {
  const _GamePixErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Container(
          padding: EdgeInsets.all(18.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.gray50),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.diceRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationLoadingCard extends StatelessWidget {
  const _PaginationLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        SizedBox(height: 10.h),
        Text(
          context.l10n.loading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(),
        ),
      ],
    );
  }
}

class _PaginationErrorCard extends StatelessWidget {
  const _PaginationErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.errorOcoredPleaseTryAgain,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.diceRetry)),
        ],
      ),
    );
  }
}
