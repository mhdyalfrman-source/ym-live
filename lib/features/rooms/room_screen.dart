import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tom_chat/core/helpers/app_share_helper.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/core/widgets/video_viewer.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/exit_dialog.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/games_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/comments/live_comments_list.dart';
import 'package:tom_chat/features/rooms/components/bottom_action_bar.dart';
import 'package:tom_chat/features/rooms/components/mini_player.dart';
import 'package:tom_chat/features/rooms/components/seats_grid.dart';
import 'package:tom_chat/features/rooms/components/top_bar_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/pages/game_bottom_sheet2.dart';
import 'package:tom_chat/features/rooms/gifts/global_gift.dart';
import 'package:tom_chat/features/rooms/gifts/received_global_lucky_gift_widget.dart';
import 'package:tom_chat/features/rooms/gifts/received_lucky_gift_widget.dart';
import 'package:tom_chat/features/rooms/gifts/side_list_received_gifts.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/red_box/received_global_red_box_widget.dart';
import 'package:tom_chat/features/rooms/red_box/treasure_box.dart';
import 'package:tom_chat/features/rooms/rocket/received_global_rocket_widget.dart';
import 'package:tom_chat/features/rooms/rocket/rocket_rank_bottom_sheet.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class RoomScreen extends StatefulWidget {
  final int? creatorId;
  final int roomId;
  final bool withSetup;
  const RoomScreen({
    super.key,
    required this.creatorId,
    required this.roomId,
    this.withSetup = true,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with WidgetsBindingObserver {
  final RoomController controller = Get.put(RoomController(), permanent: true);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.withSetup) {
        controller.setup(creatorId: widget.creatorId, roomId: widget.roomId);
      }
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (controller.room.value.id == 0) return true;

    final result = await ExitDialog.show(context);

    if (result == "EXIT") {
      try {
        if (!controller.currentUserIsHost.value) {
          bool result = await controller.leaveRoom(
            withOutCheck: false,
            withEndCall: true,
          );
          Get.back();
          return result;
        }
        await controller.leaveRoom(withEndCall: true);
        Get.back();
        return true;
      } catch (_) {}
    } else if (result == "KEEP") {
      try {
        Get.find<HomeController>().keepRoom.value = controller.room.value;
        Get.back();
        return true;
      } catch (_) {}
    } else if (result == "SHARE") {
      try {
        AppShareHelper share = AppShareHelper(
          type: AppShareType.rooms,
          parameters: {
            ShareKeyType.rid: controller.room.value.id.toString(),
            ShareKeyType.uid: controller.room.value.owner!.userId.toString(),
          },
        );
        await SharePlus.instance.share(
          ShareParams(
            uri: Uri.parse(share.getShareUrl),
            title: context.l10n.share,
          ),
        );
        return false;
      } catch (_) {}
    }

    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // controller.leaveRoom(true,true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // initForegroundTask();
      // await FlutterForegroundTask.startService(
      //   notificationTitle: "BikMedi Running",
      //   notificationText: "${controller.room.value.hostInfo?.fullName} is in live now.",
      // );
    } else if (state == AppLifecycleState.resumed) {
      // await FlutterForegroundTask.stopService();
    } else if (state == AppLifecycleState.detached) {
      // controller.endCall();
      // await FlutterForegroundTask.stopService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        bool allow = await _onWillPop(context);

        if (allow) {
          Get.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // background image for atmosphere
              Positioned.fill(
                child: Obx(() {
                  if ((controller.room.value.bg?.network ?? "") != "") {
                    return AppImage(
                      image: controller.room.value.bg,
                      fit: BoxFit.cover,
                    );
                  }
                  return Image.asset('assets/images/bg.png', fit: BoxFit.cover);
                }),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoomTopBar(
                    controller: controller,
                    onClose: () async {
                      if (await _onWillPop(context)) {
                        Get.back();
                      }
                    },
                  ),
                  SizedBox(height: 5.h),
                  Obx(() {
                    if (controller.redBoxes.isNotEmpty) {
                      return AnimatedTreasureBox(
                        controller: controller,
                        liveId: controller.room.value.owner?.userId ?? 0,
                      );
                    }
                    return SizedBox();
                  }),
                  SizedBox(height: 5.h),
                  // seats
                  SeatsGrid(controller: controller),

                  // chat area with tabs
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          constraints: constraints,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          child: LiveCommentsList(
                            room: controller.room.value,
                            controller: controller,
                            onCommentTap: (user) {
                              controller.openSmallProfile(user);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  BottomActionBar(c: controller),
                ],
              ),

              Obx(() {
                if (controller.isInitialized.value) {
                  return AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    bottom: controller.showFullMiniPlayer.value
                        ? 80.h
                        : controller.rocket.value == null
                        ? 110.h
                        : 190.h,
                    left: 0,
                    right: 0,
                    child: MiniPlayer(c: controller),
                  );
                }
                return SizedBox();
              }),

              // // Floating gift button
              // Positioned(
              //   left: 16,
              //   bottom: 200,
              //   child: FloatingActionButton(
              //     // onPressed: c.toggleGiftPanel,
              //     onPressed: (){
              //       Get.to(()=>MusicScreen());
              //     },
              //     backgroundColor: Colors.black87,
              //     child: const Icon(Icons.music_note, color: Colors.orange),
              //   ),
              // ),

              // Slider Gifts
              IgnorePointer(
                ignoring: true,
                child: SafeArea(
                  child: Obx(() {
                    GiftModel? gift = controller.receivedLuckyGifts.firstOrNull;
                    return Column(
                      children: [
                        Spacer(
                          flex: controller.isBottomSheetOpen.value ? 1 : 2,
                        ),
                        SideListReceivedGifts(
                          room: controller.room.value,
                          directionality: Directionality.of(context),
                          controller: controller,
                        ),
                        if (gift != null) ...[
                          ReceivedLuckyGiftWidget(
                            key: ValueKey(gift.sendId),
                            gift: gift,
                            directionality: Directionality.of(context),
                            onFinish: () {
                              controller.removeLuckyGift();
                            },
                          ),
                        ],
                        Spacer(
                          flex: controller.isBottomSheetOpen.value ? 6 : 3,
                        ),
                      ],
                    );
                  }),
                ),
              ),

              PositionedDirectional(
                end: 10.r,
                bottom: 60.r,
                child: SizedBox(
                  width: Get.width / 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Games2BottomSheet.show(context, controller.room.value.id.toString());
                        },
                        child: Image.asset(
                          "assets/images/game.png",
                          width: 60.r,
                          height: 60.r,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Obx(() {
                        if (controller.rocket.value != null) {
                          return InkWell(
                            onTap: () {
                              RocketRankBottomSheet.show(
                                context,
                                controller,
                                controller.room.value,
                                controller.moveOnClickOnRoom,
                              );
                            },
                            child: Transform.scale(
                              scale: 1.2,
                              child: AppImage(
                                image: ImageModel(
                                  network: controller.rocket.value!.iconAnim,
                                ),
                                width: Get.width / 5,
                                height: Get.width / 5,
                              ),
                            ),
                          );
                        }
                        return SizedBox();
                      }),
                    ],
                  ),
                ),
              ),

              IgnorePointer(
                child: Obx(() {
                  if ((controller.enteryAnimation.value?.entry?.network ??
                          "") !=
                      "") {
                    return SafeArea(
                      child:
                          (controller.enteryAnimation.value?.entry?.network ??
                                  "")
                              .endsWith(".mp4")
                          ? VideoViewer(
                              fit: BoxFit.cover,
                              // networkVideo: "https://bikmeida.fra1.digitaloceanspaces.com/video/6990edf061b7e.mp4",
                              networkVideo: controller
                                  .enteryAnimation
                                  .value!
                                  .entry!
                                  .network!,
                              repeated: false,
                              count: 1,
                              onFinish: () async {
                                await controller.removeCurrentEnteryAnimation();
                              },
                            )
                          : SvgaViwer(
                              fit: BoxFit.cover,
                              networkSvga: controller
                                  .enteryAnimation
                                  .value!
                                  .entry!
                                  .network!,
                              repeated: false,
                              count: 1,
                              onFinish: () async {
                                await controller.removeCurrentEnteryAnimation();
                              },
                            ),
                    );
                  } else if ((controller
                              .enteryAnimation
                              .value
                              ?.vip
                              ?.entryEffect ??
                          "") !=
                      "") {
                    return SafeArea(
                      top: false,
                      child:
                          (controller.enteryAnimation.value?.vip?.entryEffect ??
                                  "")
                              .endsWith(".mp4")
                          ? VideoViewer(
                              fit: BoxFit.cover,
                              // networkVideo: "https://bikmeida.fra1.digitaloceanspaces.com/video/6990edf061b7e.mp4",
                              networkVideo: controller
                                  .enteryAnimation
                                  .value
                                  ?.vip
                                  ?.entryEffect,
                              repeated: false,
                              count: 1,
                              onFinish: () async {
                                await controller.removeCurrentEnteryAnimation();
                              },
                            )
                          : SvgaViwer(
                              fit: BoxFit.cover,
                              networkSvga: controller
                                  .enteryAnimation
                                  .value!
                                  .vip!
                                  .entryEffect,
                              repeated: false,
                              count: 1,
                              onFinish: () async {
                                await controller.removeCurrentEnteryAnimation();
                              },
                            ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              // Slider Gifts
              SafeArea(
                child: Column(
                  children: [
                    Spacer(),
                    GiftEntryWidget(controller: controller),
                    GlobalLuckyGiftWidget(controller: controller),
                    GlobalRedBoxQueueWidget(
                      controller: controller,
                      onMoveToNewLive: (red) async {
                        await controller.moveOnClickOnRedBox(red!);
                      },
                    ),
                    GlobalRocketWidget(
                      onMoveToNewLive: controller.moveOnClickOnRoom,
                      controller: controller,
                    ),
                    Spacer(flex: 11),
                  ],
                ),
              ),

              // gift panel overlay
              // GiftPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
