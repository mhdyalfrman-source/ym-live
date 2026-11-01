import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/emoji_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class EmojiBottomSheet extends StatefulWidget {
  final HomeController homeController;
  final RoomController controller;
  const EmojiBottomSheet({
    super.key,
    required this.controller,
    required this.homeController,
  });

  @override
  State<EmojiBottomSheet> createState() => _EmojiBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: EmojiBottomSheet(
        controller: controller,
        homeController: Get.find<HomeController>(),
      ),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _EmojiBottomSheetState extends State<EmojiBottomSheet> {
  int selectedType = 0;
  @override
  Widget build(BuildContext context) {
    List<EmojiModel> emojies = widget.controller.emojies.where((e) {
      if (selectedType == 1) {
        return e.vip > 0;
      }
      return e.vip == 0;
    }).toList();
    return SizedBox(
      height: Get.height * 0.4,
      child: CardWidget(
        radius: 15.r,
        colorIndex: 1,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Row(
                spacing: 20.w,
                children: [
                  SizedBox(),
                  _buildTab(context, 0, context.l10n.all),
                  _buildTab(context, 1, context.l10n.vip),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: MasonryGridView.count(
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 6,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  itemCount: emojies.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (selectedType == 1 &&
                            emojies[index].vip >
                                (widget.homeController.user.value.vip?.id ??
                                    0) /*|| !widget.homeController.user.value.vipCustomEmoji*/ ) {
                          return;
                        }
                        Get.back();
                        CallServerAPI.post("live/sendEmoji", {
                          "name": emojies[index].icon,
                          "seat": widget
                              .controller
                              .room
                              .value
                              .seats[widget.controller.userGustIndex]
                              .seatNumber,
                          "rid": widget.controller.room.value.id,
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            // decoration: BoxDecoration(
                            // border: Border.all(color: Colors.white70,width: 1),
                            // borderRadius: BorderRadius.circular(5).r
                            // ),
                            child: CachedImage(
                              emojies[index].icon,
                              type: ImageType.profile,
                            ),
                          ),
                          if (emojies[index].vip > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10).r,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200.withOpacity(
                                        0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(10).r,
                                    ),
                                    child: Text(
                                      "${context.l10n.vip} ${emojies[index].vip}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            // color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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

  Widget _buildTab(BuildContext context, int type, String text) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Column(
        spacing: 5.h,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: selectedType == type
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          if (selectedType == type)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 2.r,
              width: 30.r,
            ),
        ],
      ),
    );
  }
}
