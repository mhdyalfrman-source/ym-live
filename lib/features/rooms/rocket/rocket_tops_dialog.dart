import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/small_profile_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RocketTopsDialog extends StatefulWidget {
  final RoomController controller;
  final List<UserModel> top3;
  final List<UserModel> tops;
  final List<RockeRewardItemModel> rewards;
  const RocketTopsDialog({
    super.key,
    required this.top3,
    required this.tops,
    required this.controller,
    required this.rewards,
  });

  @override
  State<RocketTopsDialog> createState() => RocketTopsDialogState();

  static void show(
    BuildContext context,
    RoomController controller,
    List<UserModel> top3,
    List<UserModel> tops,
    List<RockeRewardItemModel> rewards,
  ) {
    showDialog(
      context: context,
      builder: (context) => RocketTopsDialog(
        top3: top3,
        controller: controller,
        tops: tops,
        rewards: rewards,
      ),
    );
  }
}

class RocketTopsDialogState extends State<RocketTopsDialog> {
  String assetLink(String name) {
    return "assets/images/rocket/$name";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        height: Get.height * 0.4,
        child: Stack(
          children: [
            Image.asset(assetLink("iv_reward.png"), fit: BoxFit.cover),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(0, -14.h),
                child: Container(
                  // width: 120.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(assetLink("iv_rocket_title.png")),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.win,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Color(0xffeefb5a),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: Get.width / 10,
              left: Get.width * 0.1,
              right: Get.width * 0.1,
              bottom: 20.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      children: [
                        ...widget.top3.asMap().entries.map(
                          (u) => rocketTop3Item(u.value),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      runSpacing: 5,
                      spacing: 5,
                      children: [
                        ...widget.tops.asMap().entries.map(
                          (u) => rocketTopItem(
                            u.value,
                            widget.rewards.elementAtOrNull(u.key),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rocketTop3Item(UserModel? user) {
    return SizedBox(
      width: Get.width * 0.15,
      child: GestureDetector(
        onTap: () {
          if (user != null) {
            SmallProfileBottomSheet.show(context: context, user: user);
          }
        },
        child: Column(
          children: [
            ProfileAvatar(user: user, radius: 30.r),
            SizedBox(height: 5.h),
            Text(
              user?.name ?? "",
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: Colors.white),
              maxLines: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MyMath.numberToShort(user?.coins ?? 0),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                  maxLines: 1,
                ),
                SizedBox(width: 5),
                Image.asset('assets/images/coin.png', width: 12.r),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rocketTopItem(UserModel? user, RockeRewardItemModel? item) {
    return SizedBox(
      width: Get.width * 0.15,
      child: GestureDetector(
        onTap: () {
          if (user != null) {
            SmallProfileBottomSheet.show(context: context, user: user);
          }
        },
        child: Column(
          children: [
            ProfileAvatar(user: user, radius: 30.r),
            SizedBox(height: 5.h),
            Text(
              user?.name ?? "",
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: Colors.white),
              maxLines: 1,
            ),
            if (item?.rewardType == RewardType.coin)
              Center(
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/coin.png",
                      width: 12.r,
                      height: 12.r,
                    ),
                    Expanded(
                      child: Text(
                        MyMath.numberToShort(item!.coins),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else if (item?.rewardType == RewardType.gift)
              Row(
                children: [
                  AppImage(
                    image: item!.gift.giftImage,
                    width: 20.r,
                    height: 20.r,
                  ),
                  Expanded(
                    child: FittedBox(
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
                  ),
                ],
              )
            else if (item?.rewardType == RewardType.equipment)
              Row(
                children: [
                  AppImage(
                    image: item!.equipments?.img,
                    width: 20.r,
                    height: 20.r,
                  ),
                  Expanded(
                    child: Column(
                      children: [
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "${item.lng} ${context.l10n.days}",
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (item?.rewardType == RewardType.vip)
              Row(
                children: [
                  CachedImage(
                    item!.vip?.icon ?? "",
                    type: ImageType.general,
                    width: 20.r,
                    height: 20.r,
                  ),
                  Expanded(
                    child: Column(
                      children: [
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "${item.lng} ${context.l10n.days}",
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
