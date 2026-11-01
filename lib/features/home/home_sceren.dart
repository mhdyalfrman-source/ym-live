import 'dart:async';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/core/helpers/app_share_helper.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/chat/chat_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/posts/post_screen.dart';
import 'package:tom_chat/features/settings/setting_screen.dart';
import 'package:tom_chat/features/home/components/btm_nav_item.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/notifications/controllers/notification_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class HomeSceren extends StatefulWidget {
  final bool comeFromEntry;
  const HomeSceren({super.key, required this.comeFromEntry});

  @override
  State<HomeSceren> createState() => _HomeScerenState();
}

class _HomeScerenState extends State<HomeSceren> {
  late HomeController controller;
  @override
  void initState() {
    super.initState();
    String local = Get.locale?.languageCode ?? "ar";
    StaticValue.language = local;
    controller = Get.put(HomeController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.selectedPage.value = 0;
      controller.user.value = StaticValue.userData.copyWith();
      controller.agency.value = StaticValue.agency;
      controller.agencyRequest.value = StaticValue.agencyRequest;
      StaticValue.coins.value = MyMath.toInt(controller.user.value.coins);
      StaticValue.diamond.value = MyMath.toInt(controller.user.value.diamond);
      controller.fetchAll();
      Get.put(NotificationController()).refreshUnreadCount();
      controller.showAppGifts.value = true;
    });
    if (StaticValue.fromNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // swipToPage(context, UserNotificationScreen());
        StaticValue.fromNote = false;
      });
    }
    // if (StaticValue.examCode != "") {
    //     await controller.joinToExamByClick(ExamModel(examCode: StaticValue.examCode), true);
    //     StaticValue.examCode = "";
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.activeLanguageCode.value = Localizations.localeOf(
        context,
      ).languageCode;
      try {
        final appLinks = AppLinks();
        appLinks.uriLinkStream.listen((uri) async {
          AppShareHelper shareLink = AppShareHelper.fromShareUrl(uri);
          await shareLink.handelRoutes();
        });
      } on FormatException {
        // عرض رسالة أو تجاهل
      }
    });
  }

  storeStepKey() {
    if (controller.selectedPage.value == 0) {
      GetStorage().write("show_home_steps", false);
    }
  }

  bool canPop = false;
  Timer? _resetTimer;

  void _enablePopFor2s() {
    setState(() => canPop = true);

    done(message: context.l10n.clickAginToExit, duration: 2);

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => canPop = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _enablePopFor2s();
      },
      child: Obx(() {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final navTheme = theme.bottomNavigationBarTheme;
        final navSurface = navTheme.backgroundColor ?? theme.primaryColorLight;
        final navBackgroundColor = Color.lerp(
          navSurface,
          theme.primaryColor,
          isDarkMode ? 0.08 : 0.03,
        )!.withValues(alpha: isDarkMode ? 0.72 : 0.84);
        final navBorderColor = Color.lerp(
          navSurface,
          theme.dividerColor,
          isDarkMode ? 0.18 : 0.1,
        )!.withValues(alpha: isDarkMode ? 0.22 : 0.16);
        return Scaffold(
          // backgroundColor: Theme.of(context).cardColor,
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation, secondaryAnimation) =>
                SharedAxisTransition(
                  fillColor: Colors.white,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
            child: controller.selectedPage.value == 0
                ? MainScreen()
                : controller.selectedPage.value == 1
                //     ? (controller.selectedTeacher.value == 0
                ? ChatScreen(
                    withAllChats: true,
                    withHeader: true,
                    withNotification: true,
                  )
                //         : TeacherExamsScreen())
                : controller.selectedPage.value == 2
                ? PostsScreen()
                : controller.selectedPage.value == 3
                ? PageTemplete(
                    backgroundColor: Theme.of(context).cardColor,
                    withIcon: false,
                    title: "",
                    child: SettingScreen(),
                  )
                : Center(child: Text("Home Screen")),
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xff8B2C1D),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: navBorderColor),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: BtmNavItem(
                              title: context.l10n.rooms,
                              image: "assets/images/room1.webp",
                              activeimage: "assets/images/room2.webp",
                              onTap: () async {
                                controller.onTap(0);
                              },
                              selectedIndex: controller.selectedPage.value,
                              currentIndex: 0,
                            ),
                          ),
                          Expanded(
                            child: BtmNavItem(
                              title: context.l10n.chats,
                              image: "assets/images/chat1.webp",
                              activeimage: "assets/images/chat2.webp",
                              onTap: () async {
                                controller.onTap(1);
                              },
                              selectedIndex: controller.selectedPage.value,
                              currentIndex: 1,
                            ),
                          ),
                          Expanded(
                            child: BtmNavItem(
                              title: context.l10n.explore,
                              image: "assets/images/fetch1.webp",
                              activeimage: "assets/images/fetch2.webp",
                              onTap: () async {
                                controller.onTap(2);
                              },
                              selectedIndex: controller.selectedPage.value,
                              currentIndex: 2,
                            ),
                          ),
                          Expanded(
                            child: BtmNavItem(
                              title: context.l10n.mine,
                              image: "assets/images/person1.webp",
                              activeimage: "assets/images/person2.webp",
                              onTap: () async {
                                controller.onTap(3);
                              },
                              selectedIndex: controller.selectedPage.value,
                              currentIndex: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
    // });
  }
}
