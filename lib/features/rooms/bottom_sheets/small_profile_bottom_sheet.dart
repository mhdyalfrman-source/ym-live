import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/components/seat_user_action.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class SmallProfileBottomSheet extends StatefulWidget {
  final List<Widget>? children;
  final Widget? icon;
  final UserModel user;
  const SmallProfileBottomSheet({
    super.key,
    this.children,
    this.icon,
    required this.user,
  });

  @override
  State<SmallProfileBottomSheet> createState() =>
      _SmallProfileBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required UserModel user,
    List<Widget>? children,
    Widget? icon,
  }) async {
    await AppBottomSheet.show(
      context: context,
      child: SmallProfileBottomSheet(
        user: user,
        icon: icon,
        children: children,
      ),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _SmallProfileBottomSheetState extends State<SmallProfileBottomSheet> {
  Rx<UserModel> user = UserModel(userId: 0, name: "").obs;
  @override
  void initState() {
    super.initState();
    user.value = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CallServerAPI.post("user", {
        "touid": widget.user.userId,
      }, withMessage: false).then((res) {
        if (res.isNotEmpty && res["profile"] != null) {
          UserModel u = UserModel.fromMap(res["profile"]);
          user.update((val) {
            val?.vip = u.vip;
            val?.agency = u.agency;
            val?.medals = u.medals;
            val?.specialId = u.specialId;
            val?.country = u.country;
            val?.cpLover = u.cpLover;
            val?.cpLoveDate = u.cpLoveDate;
            val?.profileFrame = u.profileFrame;
            val?.avatar = u.avatar;
            val?.levels = u.levels;
            val?.relation = u.relation;
          });
        }
      });
    });
  }

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.7,
      child: Obx(() {
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: Get.height * 0.48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10).r,
                    topRight: Radius.circular(10).r,
                  ),
                ),
                padding: EdgeInsets.all(10).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: widget.icon ?? SizedBox(width: 50.r)),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              SizedBox(
                                height: user.value.profileFrame == null
                                    ? 10.h
                                    : 30.h,
                              ),
                              if (user.value.cpLover == null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (user.value.agency != null) ...[
                                      agencyWidget(),
                                      Spacer(),
                                    ],
                                    ProfileAvatar(
                                      openProfileType: OpenProfileType.full,
                                      user: user.value,
                                      radius: 40.r,
                                      fromRoom: true,
                                    ),
                                    if (user.value.agency != null) ...[
                                      Spacer(flex: 5),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: Get.back,
                            icon: Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    if (user.value.cpLover != null) ...[
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: 80.r,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (user.value.agency != null) ...[
                              agencyWidget(),
                              Spacer(),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ProfileAvatar(
                                  radius: 28.r,
                                  user: user.value,
                                  openProfileType: OpenProfileType.full,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/cp_small_heart.png",
                                      height: 25.r,
                                    ),
                                    if (user.value.cpLoveDate != null)
                                      Text(
                                        "${DateTime.now().difference(user.value.cpLoveDate!).inDays} ${context.l10n.day}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                  ],
                                ),
                                ProfileAvatar(
                                  radius: 22.r,
                                  user: user.value.cpLover,
                                  openProfileType: OpenProfileType.full,
                                ),
                              ],
                            ),
                            if (user.value.agency != null) ...[Spacer(flex: 5)],
                          ],
                        ),
                      ),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UserNameWidget(
                                    user: user.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  SizedBox(width: 5.w),
                                  if (user.value.type == 1) ...[
                                    Container(
                                      padding: EdgeInsets.all(2).r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.lightBlue,
                                      ),
                                      child: Icon(Icons.male, size: 18.r),
                                    ),
                                  ] else
                                    Container(
                                      padding: EdgeInsets.all(2).r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.pinkAccent,
                                      ),
                                      child: Icon(Icons.female, size: 18.r),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UserIdWidget(
                                    user: user.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(color: Colors.black),
                                  ),
                                  SizedBox(width: 5.w),
                                  Icon(
                                    Icons.copy,
                                    size: 15.r,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Center(
                                child: LevelsWidget(
                                  isCenter: true,
                                  levels: user.value.levels?.levels ?? [],
                                  vip: /*user.value.vip*/ null,
                                  width: double.infinity,
                                  size: 13.r,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Center(
                                child: MedalsWidget(
                                  vip: user.value.vip,
                                  width: double.infinity,
                                  size: 30.r,
                                  medals: user.value.medals ?? [],
                                  isCenter: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.children != null) ...[
                      SizedBox(height: 20.h),
                      Wrap(
                        spacing: 20.r,
                        runSpacing: 20.r,
                        children: [
                          ...widget.children!,
                          Obx(() {
                            if ([
                                  PersonRelation.follow,
                                  PersonRelation.followBack,
                                ].contains(user.value.relation) &&
                                widget.user.userId !=
                                    StaticValue.userData.userId) {
                              return UserOption(
                                onTap: () async {
                                  var response = await CallServerAPI.post(
                                    'user/attention',
                                    {'touid': user.value.userId, 'type': 1},
                                  );
                                  if (response.isNotEmpty) {
                                    PersonRelation newState = PersonRelation
                                        .values
                                        .firstWhere(
                                          (v) => v.name == response['done'],
                                        );
                                    user.update((val) {
                                      val?.relation = newState;
                                    });
                                  }
                                },
                                icon: Icons.favorite_outline,
                                label: user.value.relation.getLabel(context),
                              );
                            }
                            return SizedBox();
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: SizedBox(
                  height: Get.height * 0.7,
                  width: double.infinity,
                  child: AppImage(
                    image:
                        user.value.profileFrame ??
                        (ImageModel(
                          network: user.value.vip?.profileFrame ?? "",
                        )),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              height: Get.height * 0.22,
              child: GestureDetector(onTap: Get.back),
            ),
          ],
        );
      }),
    );
  }

  Widget agencyWidget() {
    return SizedBox(
      width: Get.width / 5,
      child: CardWidget(
        radius: 20.r,
        colorIndex: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5).r,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5).r,
                child: AppImage(
                  image: user.value.agency!.icon,
                  height: 20.r,
                  width: 20.r,
                ),
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return AutoScrollText(
                      width: c.maxWidth,
                      text: "${user.value.agency!.name}",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
