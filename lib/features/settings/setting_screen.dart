import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/helpers/secure_storage.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/agency_search_screen.dart';
import 'package:tom_chat/features/agency/manage_agency_screen.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/charge/recharge_coin_screen.dart';
import 'package:tom_chat/features/charge/recharge_diamond_screen.dart';
import 'package:tom_chat/features/levels/level_screen.dart';
import 'package:tom_chat/features/notifications/notification_settings_screen.dart';
import 'package:tom_chat/features/profile/components/gender_widget.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/profile/controllers/profile_controller.dart';
import 'package:tom_chat/features/profile/edit_profile_screen.dart';
import 'package:tom_chat/features/relations/controllers/relation_controller.dart';
import 'package:tom_chat/features/relations/relation_screen.dart';
import 'package:tom_chat/features/settings/change_password_screen.dart';
import 'package:tom_chat/features/settings/components/level_item.dart';
import 'package:tom_chat/features/settings/language_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/settings/components/setting_widget.dart';
import 'package:tom_chat/features/settings/switch_account_screen.dart';
import 'package:tom_chat/features/settings/controllers/setting_controller.dart';
import 'package:tom_chat/features/store/store_screen.dart';
import 'package:tom_chat/features/vip/vip_screen.dart';
import 'package:tom_chat/features/wallet/wallet_screen.dart';
import 'package:tom_chat/features/recharge_agency/recharge_agency_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/main.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SettingController controller;
  late HomeController homeController;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SettingController(forAdmin: false));
    if (!controller.forAdmin) {
      homeController = Get.find();
    }
    if (!Get.isRegistered<ProfileController>(
      tag: StaticValue.userData.userId.toString(),
    )) {
      profileController = Get.put(
        ProfileController(StaticValue.userData.userId),
        permanent: true,
        tag: StaticValue.userData.userId.toString(),
      );
    } else {
      profileController = Get.find<ProfileController>(
        tag: StaticValue.userData.userId.toString(),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await profileController.getUser(false);
      if (profileController.user.value != null) {
        homeController.user.value = profileController.user.value!;
      }
    });
  }

  Future<void> updateUserInHome() async {
    await profileController.getUser(false);
    if (profileController.user.value != null) {
      homeController.user.value = profileController.user.value!;
    }
  }

  String _currentLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'tr':
        return 'Türkçe';
      case 'id':
        return 'Bahasa Indonesia';
      case 'hi':
        return 'हिन्दी';
      case 'ur':
        return 'اردو';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10).r,
      child: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: 50.h),
              IntrinsicHeight(
                child: Obx(() {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 10.w),
                      ProfileAvatar(
                        openProfileType: OpenProfileType.full,
                        user: homeController.user.value,
                        radius: 30.r,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                UserNameWidget(
                                  width: 150.w,
                                  user: homeController.user.value,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(width: 5.w),
                                GenderWidget(user: homeController.user.value),
                              ],
                            ),
                            Row(
                              children: [
                                UserIdWidget(
                                  user: homeController.user.value,
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(width: 5.w),
                                GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: homeController.user.value.userId
                                            .toString(),
                                      ),
                                    );
                                    done();
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 15.r,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            LevelsWidget(
                              size: 13.r,
                              levels:
                                  homeController.user.value.levels?.levels ??
                                  [],
                              vip: null,
                              width: double.infinity,
                            ),
                            SizedBox(height: 3.h),
                            MedalsWidget(
                              size: 25.r,
                              vip: homeController.user.value.vip,
                              width: double.infinity,
                              medals: homeController.user.value.medals ?? [],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: () {
                            swipToPage(context, EditProfileScreen());
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 18.r,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 15.h),
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    itemWithNumber(
                      context.l10n.followers,
                      homeController.user.value.followersCount?.toString() ??
                          "0",
                      () {
                        swipToPage(
                          context,
                          RelationScreen(
                            userId: StaticValue.userData.userId,
                            title: context.l10n.followers,
                            type: RelationType.follower,
                          ),
                        );
                      },
                    ),
                    itemWithNumber(
                      context.l10n.iFollow,
                      homeController.user.value.followingCount?.toString() ??
                          "0",
                      () {
                        swipToPage(
                          context,
                          RelationScreen(
                            userId: StaticValue.userData.userId,
                            title: context.l10n.follow,
                            type: RelationType.following,
                          ),
                        );
                      },
                    ),
                    itemWithNumber(
                      context.l10n.visitors,
                      homeController.user.value.visitersCount?.toString() ??
                          "0",
                      () {
                        swipToPage(
                          context,
                          RelationScreen(
                            userId: StaticValue.userData.userId,
                            title: context.l10n.visitors,
                            type: RelationType.visitor,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
              SizedBox(height: 15.h),
              Obx(() {
                return CardWidget(
                  radius: 10.r,
                  colorIndex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(10).r,
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        GestureDetector(
                          onTap: () {
                            swipToPage(context, LevelScreen(typeIndex: 0));
                          },
                          child: LevelProgress(
                            current:
                                (homeController
                                            .user
                                            .value
                                            .levels
                                            ?.gifter
                                            .progress ??
                                        0)
                                    .toDouble(),
                            total:
                                (homeController
                                            .user
                                            .value
                                            .levels
                                            ?.gifter
                                            .nextLevelUp ??
                                        0)
                                    .toDouble(),
                            height: 16.h,
                            animationDuration: Duration(milliseconds: 700),
                            backgroundColor: Color(0xFFEBEEF2),
                            fillGradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF6DD3B0), Color(0xFF2AB27B)],
                            ),
                            borderRadius: 10,
                            showPercentage: true,
                            trailing: SizedBox(
                              width: 60.w,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.l10n.rich,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            showHandle: true,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {
                            swipToPage(context, LevelScreen(typeIndex: 1));
                          },
                          child: LevelProgress(
                            current:
                                (homeController
                                            .user
                                            .value
                                            .levels
                                            ?.anchor
                                            .progress ??
                                        0)
                                    .toDouble(),
                            total:
                                (homeController
                                            .user
                                            .value
                                            .levels
                                            ?.anchor
                                            .nextLevelUp ??
                                        0)
                                    .toDouble(),
                            height: 16.h,
                            animationDuration: Duration(milliseconds: 700),
                            backgroundColor: Color(0xFFEBEEF2),
                            fillGradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
                            ),
                            borderRadius: 10,
                            showPercentage: true,
                            trailing: SizedBox(
                              width: 60.w,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.l10n.gathib,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            showHandle: true,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        LevelProgress(
                          current:
                              (homeController
                                          .user
                                          .value
                                          .levels
                                          ?.charge
                                          .progress ??
                                      0)
                                  .toDouble(),
                          total:
                              (homeController
                                          .user
                                          .value
                                          .levels
                                          ?.charge
                                          .nextLevelUp ??
                                      0)
                                  .toDouble(),
                          height: 16.h,
                          animationDuration: Duration(milliseconds: 700),
                          backgroundColor: Color(0xFFEBEEF2),
                          fillGradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                          ),
                          borderRadius: 10,
                          showPercentage: true,
                          trailing: SizedBox(
                            width: 60.w,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.l10n.pay,
                                style: Theme.of(context).textTheme.displaySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          showHandle: true,
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 15.h),
              Row(
                children: [
                  SizedBox(width: 20.w),
                  iconWithTitle(
                    context.l10n.store,
                    "assets/images/SHOP.webp",
                    () async {
                      await swipToPage(context, StoreScreen());
                      updateUserInHome();
                    },
                  ),
                  iconWithTitle(
                    context.l10n.vip,
                    "assets/images/VIP.webp",
                    () async {
                      await swipToPage(context, VipScreen());
                      updateUserInHome();
                    },
                  ),
                  iconWithTitle(
                    homeController.agency.value != null
                        ? context.l10n.agency
                        : context.l10n.joinAgency,
                    "assets/images/BADGE.webp",
                    () async {
                      if (homeController.agency.value != null) {
                        swipToPage(
                          context,
                          ManageAgencyScreen(
                            id: homeController.agency.value?.id ?? 0,
                            userId: homeController.user.value.userId,
                          ),
                        );
                      } else {
                        if (homeController.agencyRequest.value != null) {
                          var res = await deleteMessage(
                            title: context.l10n.confirm,
                            content: context.l10n.youHaveSentJoin(
                              homeController.agencyRequest.value?.name ?? "",
                            ),
                            onDelete: () {
                              Get.back(result: true);
                            },
                            cancelButton: context.l10n.cancel,
                            deleteButton: context.l10n.continue0,
                            onCancel: Get.back,
                            onWillPop: true,
                          );
                          if (res is! bool) {
                            return;
                          }
                        }
                        swipToPage(context, AgencySearchScreen());
                      }
                    },
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
              SizedBox(height: 15.h),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5).r,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            context.l10n.wallet,
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                swipToPage(context, RechargeCoinScreen());
                              },
                              child: Container(
                                padding: EdgeInsets.all(5).r,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10).r,
                                  color: Color(0xfffff8c1),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/wallet.png",
                                      height: 40.r,
                                    ),
                                    SizedBox(width: 5.w),
                                    Expanded(
                                      child: Obx(() {
                                        return Column(
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                StaticValue.coins.value
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(
                                                      color: Color(0xFFf6d319),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            Text(
                                              context.l10n.coins,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(
                                                    color: Color(0xFFf6d319),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFFf6d319),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                swipToPage(context, RechargeDiamondScreen());
                              },
                              child: Container(
                                padding: EdgeInsets.all(5).r,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff524ffe),
                                      Color(0xff9361fe),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10).r,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/mas.png",
                                      height: 40.r,
                                    ),
                                    SizedBox(width: 5.w),
                                    Expanded(
                                      child: Obx(() {
                                        return Column(
                                          children: [
                                            Text(
                                              StaticValue.diamond.value
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(
                                                    color: Color(0xffed23f3),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              context.l10n.mas,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(
                                                    color: Color(0xffed23f3),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xffed23f3),
                                    ),
                                  ],
                                ),
                              ),
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
          Obx(
            () => homeController.user.value.rechargeAgencyId > 0
                ? SeetingWidget(
                    color: Colors.transparent,
                    title: context.l10n.rechargeAgencyTitle,
                    icon: Icons.storefront,
                    onTap: () =>
                        swipToPage(context, const RechargeAgencyScreen()),
                  )
                : const SizedBox.shrink(),
          ),
          SeetingWidget(
            color: Colors.transparent,
            image: "assets/svgs/wallet.svg",
            title: context.l10n.wallet,
            onTap: () {
              swipToPage(context, WalletScreen());
            },
          ),
          SeetingWidget(
            color: Colors.transparent,
            image: "assets/svgs/list.svg",
            title: context.l10n.policy,
            onTap: () {
              launchUrl(
                Uri.parse("http://104.207.90.135/yaumi/privacy_policy.html"),
                mode: LaunchMode.inAppWebView,
              );
            },
          ),
          SeetingWidget(
            color: Colors.transparent,
            icon: HugeIcons.strokeRoundedLanguageCircle,
            trailing: Text(
              _currentLanguageName(
                Localizations.localeOf(context).languageCode,
              ),
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w100,
              ),
            ),
            title: context.l10n.language,
            onTap: () {
              swipToPage(context, const LanguageSelectionScreen());
            },
          ),
          SeetingWidget(
            color: Colors.transparent,
            trailing: SizedBox(),
            icon: Icons.notifications_active_outlined,
            title: context.l10n.notificationSettings,
            onTap: () {
              swipToPage(context, const NotificationSettingsScreen());
            },
          ),
          SeetingWidget(
            color: Colors.transparent,
            trailing: SizedBox(),
            icon: Icons.password_outlined,
            title: context.l10n.changePassword,
            onTap: () {
              swipToPage(context, ChangePasswordScreen());
            },
          ),
          SeetingWidget(
            color: Colors.transparent,
            trailing: SizedBox(),
            icon: Icons.compare_arrows_rounded,
            title: context.l10n.switch_account,
            onTap: () {
              swipToPage(context, SwitchAccountScreen());
            },
          ),
          Obx(() {
            if (homeController.keepRoom.value == null) {
              return SeetingWidget(
                color: Colors.transparent,
                trailing: SizedBox(),
                image: "assets/svgs/logout.svg",
                title:
                    // (StaticValue.userData.userId != 0) ?
                    context.l10n.logout,
                //  : "signup".tr(),
                onTap: () {
                  deleteMessage(
                    cancelButton: context.l10n.cancel,
                    deleteButton: context.l10n.logout,
                    content: context.l10n.logoutMsg,
                    title: context.l10n.confirm,
                    onDelete: () async {
                      await logout();
                    },
                    onCancel: () {
                      Get.back();
                    },
                    onWillPop: true,
                  );
                },
              );
            }
            return SizedBox();
          }),
        ],
      ),
    );
  }

  Widget iconWithTitle(String title, String image, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Image.asset(image, width: 50.r),
            SizedBox(height: 10.h),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemWithNumber(String title, String number, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> logout() async {
  HomeController homeController = Get.find();
  waitMessage();
  await SecureUsersStore().deleteUserById(
    StaticValue.userData.userId.toString(),
  );
  homeController.resetAll();
  final signIn = GoogleSignIn.instance;
  await signIn.signOut();
  await FirebaseAuth.instance.signOut();
  final storage = FlutterSecureStorage();
  await storage.delete(key: "user");
  CallServerAPI.post("auth/logout", {});
  SocketManager.instance.disconnect();
  Get.offAll(() => SplashScreen(fromSettings: true));
}
