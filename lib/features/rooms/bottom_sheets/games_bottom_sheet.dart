import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/game_model.dart';

class GamesBottomSheet extends StatefulWidget {
  final RoomController controller;
  const GamesBottomSheet({super.key, required this.controller});

  @override
  State<GamesBottomSheet> createState() => _GamesBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: GamesBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _GamesBottomSheetState extends State<GamesBottomSheet> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // widget.controller.onLinePage = 1;
    // widget.controller.hasMoreOnlineUsers.value = true;
    // widget.controller.onlineUsers.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchGames(1);
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await widget.controller.fetchGames(1);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      colorIndex: 1,
      radius: 10,
      child: Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.all(10).r,
        child: Obx(() {
          if (widget.controller.gameIsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.controller.games.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.noDataFound),
                  TextButton(
                    onPressed: () => widget.controller.fetchGames(1),
                    child: Text(context.l10n.diceRetry),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              childAspectRatio: 0.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.controller.games.length,
            itemBuilder: (context, index) {
              final game = widget.controller.games[index];
              return GestureDetector(
                onTap: () {
                  _openGameFullScreen(
                    context,
                    game,
                    widget.controller,
                    widget.controller.room.value.id,
                  );
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (Uri.tryParse(
                            game.icon,
                          )?.path.toLowerCase().endsWith('.svg') ==
                          true)
                        Positioned.fill(
                          child: SvgPicture.network(
                            game.icon,
                            fit: BoxFit.contain,
                          ),
                        )
                      else if (game.icon.isNotEmpty)
                        CachedImage(
                          game.icon,
                          fit: BoxFit.cover,
                          type: ImageType.general,
                        ),
                      Positioned(
                        bottom: 3.h,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: Text(
                            game.name,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            },
          );
        }),
      ),
    );
  }

  static void _openGameFullScreen(
    BuildContext context,
    GameModel game,
    RoomController controller,
    int roomId,
  ) async {
    Navigator.of(context).pop();
    await openHtmlGame(game);
  }
}
