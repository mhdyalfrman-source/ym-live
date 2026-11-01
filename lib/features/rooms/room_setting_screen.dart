import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/block_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/change_password.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/change_room_name.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/room_background_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class RoomSettingScreen extends StatefulWidget {
  const RoomSettingScreen({super.key});

  @override
  State<RoomSettingScreen> createState() => _RoomSettingScreenState();
}

class _RoomSettingScreenState extends State<RoomSettingScreen> {
  RoomController controller = Get.put(RoomController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.roomSettings,

      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  if (controller.currentUserIsHost.value) ...[
                    buildSection(context, [
                      // buildTappableTile(context, 'Room portrait',(){}, hasTrailingWidget: true),
                      buildTappableTile(context, context.l10n.roomName, () {
                        changeRoomNameDialog(context, controller);
                      }),
                      buildTappableTile(
                        context,
                        context.l10n.roomBackground,
                        () async {
                          Get.back();
                          RoomBackgroundBottomSheet.show(context, controller);
                        },
                      ),
                      buildTappableTile(
                        context,
                        context.l10n.roomIcon,
                        () async {
                          String path = await openGallery();
                          Get.back();
                          if (path != "") {
                            controller.updateRoomIcon(File(path));
                          }
                        },
                      ),
                      buildTappableTile(
                        context,
                        context.l10n.password,
                        () async {
                          var res = await ChangePassword.show(context);
                          if (res is String) {
                            await controller.updateRoomPassword(res);
                          }
                        },
                        withDivider: false,
                      ),
                      Obx(
                        () => _buildSwitchTile(
                          context,
                          context.l10n.carizma,
                          controller.room.value.carizma == 1,
                          (v) async {
                            await controller.updateRoomCarizma(v ? 1 : 0);
                          },
                        ),
                      ),
                      Obx(() {
                        if (controller.room.value.carizma == 1) {
                          return buildTappableTile(
                            context,
                            context.l10n.resetCarizma,
                            () async {
                              Get.back();
                              await controller.resetRoomCarizma();
                            },
                            withDivider: false,
                          );
                        }
                        return SizedBox();
                      }),
                      buildTappableTile(
                        context,
                        context.l10n.blockList,
                        () async {
                          BlockListBottomSheet.show(context, controller);
                        },
                        withDivider: false,
                      ),
                      // buildTappableTile(context, 'Room Notice',(){}),
                    ]),
                  ],
                  // buildSection(
                  //   context,
                  //   [
                  //     buildTappableTile(context, 'Label',(){}),
                  //     buildTappableTile(context, 'Theme',(){}),
                  //     buildTappableTile(context, 'Room Decoration',(){}),
                  //   ],
                  // ),
                  buildSection(context, [
                    // Obx(() => _buildSwitchTile(
                    //   context,
                    //   context.l10n.showSvgaAndEntries,
                    //   controller.showSvga.value,
                    //   controller.toggleShowSvga,
                    // )),
                    // Obx(() => _buildSwitchTile(
                    //       context,
                    //       context.l10n.allowUsersToSendMessage,
                    //       controller.isMemberCanSendMessage.value,
                    //       controller.toggleMessageSetting,
                    //     )),
                    // Obx(() => _buildSwitchTile(
                    //       context,
                    //       'Room Password',
                    //       controller.isRoomPasswordEnabled.value,
                    //       controller.togglePasswordSetting,
                    //     )),
                  ]),
                  // buildSection(
                  //   context,
                  //   [
                  //     buildTappableTile(context, 'Manager',(){}),
                  //     buildTappableTile(context, 'Room Operate List',(){}),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(children: children),
    );
  }

  Widget buildTappableTile(
    BuildContext context,
    String title,
    Function()? onTap, {
    bool hasTrailingWidget = false,
    bool withDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: hasTrailingWidget
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الدائرة السوداء الصغيرة لـ "Room portrait"
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
          onTap: onTap,
        ),
        // فاصل بين عناصر القائمة
        if (withDivider)
          const Divider(
            height: 0,
            thickness: 0.5,
            indent: 16.0,
            endIndent: 16.0,
          ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              // activeColor: Colors.orange,
            ),
          ),
          onTap: () => onChanged(!value),
        ),
        // if (title != 'Room Password')
        //   const Divider(height: 0, thickness: 0.5, indent: 16.0, endIndent: 16.0),
      ],
    );
  }
}
