import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/controllers/storage_Service.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class RoomItem extends StatelessWidget {
  final String border;
  final RoomModel room;
  const RoomItem({super.key, required this.room, this.border = ""});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RoomModel? keep = Get.find<HomeController>().keepRoom.value;
        if (keep == null || room.id == keep.id) {
          if (keep != null) {
            Get.find<HomeController>().keepRoom.value = null;
          } else {
            RoomStorageService().addRoom(room);
          }
          swipToPage(
            context,
            RoomScreen(
              creatorId: room.uid,
              roomId: room.id,
              withSetup: keep == null,
            ),
          );
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0).r,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10,
                  ).r, // لو تحتاج زوايا دائرية
                  child: Container(
                    width: double.infinity,
                    height: 150.h, // هنا الحجم الثابت للصورة
                    color: Colors.grey.shade200, // خلفية لو الصورة فاضية
                    child: room.icon?.network == null
                        ? AppImage(image: room.owner!.avatar, fit: BoxFit.cover)
                        : AppImage(
                            image: ImageModel(network: room.icon!.network!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              if (border != "")
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.05,
                    child: Image.asset(border),
                  ),
                ),
              PositionedDirectional(
                top: 12.h,
                end: 12.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10).r,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 6,
                      ).r,
                      child: Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedUser,
                            color: Colors.white,
                            size: 12.r,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            room.usersCount.toString(),
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                SizedBox(width: 10),
                Text(
                  CountryService()
                          .findByCode(room.country ?? "YE")
                          ?.flagEmoji ??
                      "",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return AutoScrollText(
                        width: c.maxWidth,
                        text: room.title,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
