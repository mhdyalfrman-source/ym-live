import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/small_profile_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/components/seat_user_action.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/features/rooms/rocket/controllers/ranking_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RocketRankBottomSheet extends StatefulWidget {
  final RoomController controller;
  final RoomModel room;
  final Function(int?, int?) onMoveToNewLive;

  const RocketRankBottomSheet({
    super.key,
    required this.room,
    required this.controller,
    required this.onMoveToNewLive,
  });

  @override
  State<RocketRankBottomSheet> createState() => _RocketRankBottomSheetState();

  static void show(
    BuildContext context,
    RoomController controller,
    RoomModel room,
    Function(int?, int?) onMoveToNewLive,
  ) {
    AppBottomSheet.show(
      context: context,
      child: RocketRankBottomSheet(
        room: room,
        onMoveToNewLive: onMoveToNewLive,
        controller: controller,
      ),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      borderRadius: 5,
      hideHeader: true,
      isDismissible: true,
      isScrollControlled: true,
      isScrollable: true,
    );
  }
}

class _RocketRankBottomSheetState extends State<RocketRankBottomSheet> {
  late RankingController controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(RankingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRocketRanking(widget.room.id);
      controller.fetchRocketsLevels(widget.room.id).then((_) {
        if ((controller.rocketLevel.value?.lvl ?? 0) > 2) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            }
          });
        }
      });
    });
  }

  String assetLink(String name) {
    return "assets/images/rocket/$name";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.75,
      child: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: Get.height * 0.75,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: controller.isLoading.value ? 0 : Get.width,
                    child: Container(
                      color: Color(0xff49008e),
                      child: Center(
                        child: CupertinoActivityIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                  if (!controller.isLoading.value)
                    Image.asset(
                      assetLink("iv_rocket_bg.png"),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  if (!controller.isLoading.value)
                    Positioned.fill(
                      top: Get.width / 10,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                children: [
                                  SizedBox(width: 10.w),
                              
                                  SizedBox(
                                    width: Get.width / 5,
                                    height: Get.height * 0.4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                assetLink(
                                                  "iv_rocket_battery.png",
                                                ),
                                                width: Get.width / 12,
                                              ),
                                              SizedBox(height: 10.h),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xffdfbaff),
                                                      Color(0xffa232fa),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10).r,
                                                ),
                                                width: Get.width / 5,
                                                height: 30.h,
                                                child: Center(
                                                  child: Text(
                                                    context.l10n.coins,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: Get.height * 0.4,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: SingleChildScrollView(
                                                  controller: scrollController,
                                                  child: Obx(() {
                                                    return Column(
                                                      spacing: 2.h,
                                                      children: [
                                                        ...controller
                                                            .rocketsLevels
                                                            .map(
                                                              (l) => SizedBox(
                                                                height:
                                                                    Get.height *
                                                                    0.1,
                                                                child: rocketItem(
                                                                  l.lvl,
                                                                  l.icon,
                                                                  l.name,
                                                                  controller
                                                                          .selectedRocket
                                                                          .value ==
                                                                      l.lvl,
                                                                ),
                                                              ),
                                                            ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              
                                  Expanded(
                                    child: Obx(() {
                                      return SizedBox(
                                        height: Get.height * 0.4,
                                        width: double.infinity,
                                        child: !controller.showRocket.value
                                            ? null
                                            : Transform.scale(
                                                scale: 1.2,
                                                child: AppImage(
                                                  image: ImageModel(
                                                    network:
                                                        controller.rocketsLevels
                                                            .firstWhereOrNull(
                                                              (r) =>
                                                                  r.lvl ==
                                                                  controller
                                                                      .selectedRocket
                                                                      .value,
                                                            )
                                                            ?.iconAnim ??
                                                        "",
                                                  ),
                                                ),
                                              ),
                                      );
                                    }),
                                  ),
                              
                                  SizedBox(
                                    width: Get.width / 5,
                                    height: Get.height * 0.4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: Get.back,
                                                child: Image.asset(
                                                  assetLink(
                                                    "iv_fighter_launching_close.png",
                                                  ),
                                                  width: Get.width / 12,
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xfff2f7a9),
                                                      Color(0xffe0a41e),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10).r,
                                                ),
                                                width: Get.width / 5,
                                                height: 30.h,
                                                child: Center(
                                                  child: Text(
                                                    MyMath.numberToShort(
                                                      (controller
                                                                  .rocketLevel
                                                                  .value
                                                                  ?.nextPoints ??
                                                              0)
                                                          .abs(),
                                                    ),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: AnimatedContainer(
                                                  margin:
                                                      EdgeInsetsDirectional.only(
                                                        bottom: Get.height * 0.05,
                                                        top: Get.height * 0.02,
                                                        start: 2.w,
                                                      ),
                                                  duration: Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  height: double.infinity,
                                                  width: 35.w,
                                                  // decoration: BoxDecoration(
                                                  //   border: Border.all(color: Colors.amberAccent,width: 2),
                                                  //   borderRadius: BorderRadius.circular(5),
                                                  //   color: Color(0xff886a06)
                                                  // ),
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child:
                                                      controller
                                                              .rocketLevel
                                                              .value ==
                                                          null
                                                      ? SizedBox()
                                                      : FractionallySizedBox(
                                                          heightFactor:
                                                              controller
                                                                          .rocketLevel
                                                                          .value!
                                                                          .nextPoints <=
                                                                      0 ||
                                                                  (controller
                                                                              .rocketLevel
                                                                              .value!
                                                                              .points /
                                                                          controller
                                                                              .rocketLevel
                                                                              .value!
                                                                              .nextPoints >
                                                                      1) /*|| (controller.selectedRocket.value - 1 < controller.rocketLevel.value!.lvl)*/
                                                              ? 1
                                                              : (controller
                                                                        .rocketLevel
                                                                        .value!
                                                                        .points /
                                                                    controller
                                                                        .rocketLevel
                                                                        .value!
                                                                        .nextPoints),
                                                          child: Container(
                                                            color: Colors
                                                                .amberAccent,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              Image.asset(
                                                assetLink(
                                                  "ic_treasure_right_bg.png",
                                                ),
                                              ),
                                              if (controller.rocketLevel.value !=
                                                  null)
                                                Center(
                                                  child: Text(
                                                    "${controller.rocketLevel.value!.points == 0
                                                        ? "0"
                                                        : controller.rocketLevel.value!.nextPoints <= 0 || (controller.rocketLevel.value!.points / controller.rocketLevel.value!.nextPoints > 1) /*|| (controller.selectedRocket.value - 1 < controller.rocketLevel.value!.lvl)*/
                                                        ? 100
                                                        : ((controller.rocketLevel.value!.points / controller.rocketLevel.value!.nextPoints) * 100).toStringAsFixed(1)}%",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                              ),
                            ),
                            timerWidget(),
                            SizedBox(height: 25.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15).r,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Image.asset(assetLink("iv_reward.png")),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Transform.translate(
                                      offset: Offset(0, -16.h),
                                      child: Container(
                                        // width: 120.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              assetLink("iv_rocket_title.png"),
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          context.l10n.reward,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                color: Color(0xffeefb5a),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    top: 40.h,
                                    bottom: 20.h,
                                    left: 10.w,
                                    right: 10.w,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              spacing: 10.w,
                                              children: [
                                                ...(controller.rocketsLevels
                                                            .firstWhereOrNull(
                                                              (r) =>
                                                                  r.lvl ==
                                                                  controller
                                                                      .selectedRocket
                                                                      .value,
                                                            )
                                                            ?.rewardItems ??
                                                        [])
                                                    .map((r) => rewardItem(r)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15).r,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Image.asset(assetLink("iv_reward.png")),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Transform.translate(
                                      offset: Offset(0, -16.h),
                                      child: Container(
                                        // width: 120.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              assetLink("iv_rocket_title.png"),
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          context.l10n.ranking,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                color: Color(0xffeefb5a),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    top: 30.h,
                                    bottom: 10.h,
                                    left: 10.w,
                                    right: 10.w,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Row(
                                                children: [
                                                  rocketTopItem(
                                                    2,
                                                    controller.rockets
                                                        .elementAtOrNull(1),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  rocketTopItem(
                                                    1,
                                                    controller.rockets
                                                        .elementAtOrNull(0),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  rocketTopItem(
                                                    3,
                                                    controller.rockets
                                                        .elementAtOrNull(2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ).r,
                                            child: Image.asset(
                                              assetLink("iv_rocket_top.png"),
                                              width: double.infinity,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25.h),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget rocketTopItem(int rank, UserModel? user) {
    return Expanded(
      child: Directionality(
        textDirection: Directionality.of(context),
        child: GestureDetector(
          onTap: () {
            if (user != null) {
              int index = widget.room.seats.indexWhere(
                (s) => s.user?.userId == user.userId,
              );
              SmallProfileBottomSheet.show(
                context: context,
                user: user,
                children: seatUserAction(
                  Get.context!,
                  widget.controller,
                  index == -1
                      ? SeatModel(
                          seatNumber: -1,
                          isHost: false,
                          percentageSize: 1,
                          user: user,
                        )
                      : widget.room.seats[index],
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Positioned.fill(
              //   top:rank != 1 ?  20.h : 0,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.vertical(top: Radius.circular(10).r),
              //     child: CachedImage(imageLink("iv_rocket_ranking_bj3.png"), type: ImageType.general,fit: BoxFit.cover,),
              //   ),
              // ),
              if (user != null)
                Positioned(
                  top: rank != 1 ? 20.h : 10.h,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileAvatar(
                        user: user,
                        radius: rank == 1 ? 25.r : 30.r,
                        assetCustomBorder: assetLink("iv_rocket_lv$rank.png"),
                        withScaleOut: rank == 1 ? 3.2 : 1.2,
                      ),
                      SizedBox(height: 5.h),
                      UserNameWidget(
                        user: user,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(color: Colors.white),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            MyMath.numberToShort(user.coins),
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: Colors.white),
                            maxLines: 1,
                          ),
                          SizedBox(width: 5),
                          Image.asset('assets/images/coin.png', width: 12.r),
                        ],
                      ),
                    ],
                  ),
                ),
              if (user == null)
                Positioned.fill(
                  top: rank != 1 ? 50.h : 10.h,
                  left: 0,
                  right: 0,
                  child: Image.asset(assetLink("iv_rocket_lv$rank.png")),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rewardItem(RockeRewardItemModel item) {
    return Stack(
      children: [
        Image.asset(assetLink("iv_rocket_reward_bj.png")),
        Positioned.fill(
          child: item.rewardType == RewardType.coin
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Expanded(
                      child: Image.asset(
                        "assets/images/coin.png",
                        width: 60.r,
                        height: 60.r,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      MyMath.numberToShort(item.coins),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                )
              : item.rewardType == RewardType.gift
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Expanded(child: AppImage(image: item.gift.giftImage)),
                    SizedBox(height: 20.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.gift.name,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                )
              : item.rewardType == RewardType.equipment
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Expanded(child: AppImage(image: item.equipments?.img)),
                    SizedBox(height: 20.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.equipments?.name ?? "",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                )
              : item.rewardType == RewardType.vip
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Expanded(
                      child: CachedImage(
                        item.vip?.icon ?? "",
                        type: ImageType.general,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${context.l10n.vip} ${item.vip?.num}",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                )
              : SizedBox(),
        ),
      ],
    );
  }

  Widget rocketItem(int id, String image, String name, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.showRocket.value = false;
        controller.selectedRocket.value = id;
        Future.delayed(Duration(seconds: 1), () {
          controller.showRocket.value = true;
        });
      },
      child: Stack(
        children: [
          if (isSelected) Image.asset(assetLink("iv_rocket_selection_bg.png")),
          Positioned(
            top: 10,
            right: 10,
            left: 10,
            bottom: 10,
            child: CachedImage(image, type: ImageType.general),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetLink("iv_rocket_not_selected.png")),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Text(
                  "lv.$id",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget timerWidget() {
    return Obx(() {
      int totalSeconds = controller.secounds.value;

      String hours = ((totalSeconds % 86400) ~/ 3600).toString().padLeft(
        2,
        "0",
      );
      String minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, "0");
      String seconds = (totalSeconds % 60).toString().padLeft(2, "0");

      return Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2.w,
          children: [
            timeWidget(context, hours),
            Text(
              ":",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            timeWidget(context, minutes),
            Text(
              ":",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            timeWidget(context, seconds),
          ],
        ),
      );
    });
  }

  Widget timeWidget(BuildContext context, String time) {
    return Column(
      children: [
        Container(
          width: Get.width * 0.1,
          height: Get.width * 0.1,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(assetLink("iv_rocket_countdown.png")),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
