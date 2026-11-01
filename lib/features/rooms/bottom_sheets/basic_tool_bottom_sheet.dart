import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/effect_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/mic_mode_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/music/music_screen.dart';
import 'package:tom_chat/features/rooms/red_box/bottom_sheets/treature_box_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/room_setting_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class BasicToolBottomSheet extends StatelessWidget {
  final RoomController controller;
  const BasicToolBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87.withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10).r,
          topRight: Radius.circular(10).r,
        ),
      ),
      child: Container(
        height: Get.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10).r,
            topRight: Radius.circular(10).r,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.all(10).r,
                child: Text(
                  context.l10n.basicTools,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                runSpacing: 15.h,
                children: [
                  settingItem(
                    context,
                    context.l10n.treasureBox,
                    Icons.abc,
                    () {
                      TreasureBoxBottomSheet.show(
                        context,
                        controller.room.value.id,
                      );
                    },
                    "assets/images/image_treasure_3.png",
                  ),
                  if ( /*controller.isMicOn.value == 2 && */ (controller
                              .currentUserIsHost
                              .value ||
                          controller.userRole.value == RoleEnum.admin) &&
                      controller.userInGust)
                    settingItem(
                      context,
                      context.l10n.music,
                      HugeIcons.strokeRoundedAppleMusic,
                      () {
                        Get.to(() => MusicScreen());
                      },
                    ),
                  if (controller.currentUserIsHost.value) ...[
                    settingItem(
                      context,
                      context.l10n.clear,
                      HugeIcons.strokeRoundedClean,
                      () {
                        Get.back();
                        CallServerAPI.post("live/clearChat", {
                          "rid": controller.room.value.id,
                          "clear": 1,
                        });
                      },
                    ),
                    // settingItem(context, "Close Message", HugeIcons.strokeRoundedMessageLock01, (){
                    //   Get.to(()=>MusicScreen());
                    // }),
                    settingItem(
                      context,
                      context.l10n.micMode,
                      HugeIcons.strokeRoundedMic01,
                      () {
                        Get.back();
                        MicModeBottomSheet.show(context, controller);
                      },
                    ),
                    settingItem(
                      context,
                      context.l10n.roomSettings,
                      HugeIcons.strokeRoundedSettings01,
                      () {
                        Get.back();
                        Get.bottomSheet(RoomSettingScreen());
                        // swipReplacementPage(context, RoomSettingScreen());
                      },
                    ),
                  ],
                  settingItem(
                    context,
                    context.l10n.effect,
                    HugeIcons.strokeRoundedEdit04,
                    () {
                      Get.bottomSheet(EffectBottomSheet());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingItem(
    BuildContext context,
    String name,
    IconData icon,
    Function() onTap, [
    String? image,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: Get.width / 4,
        child: Column(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade900,
              ),
              child: image != null ? Image.asset(image) : Icon(icon),
            ),
            SizedBox(height: 5.w),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: BasicToolBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}
