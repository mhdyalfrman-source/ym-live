import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/choose_image.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class RoomBackgroundBottomSheet extends StatefulWidget {
  final RoomController controller;
  const RoomBackgroundBottomSheet({super.key, required this.controller});

  @override
  State<RoomBackgroundBottomSheet> createState() =>
      _RoomBackgroundBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: RoomBackgroundBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _RoomBackgroundBottomSheetState extends State<RoomBackgroundBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getRoomBackgrounds();
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await widget.controller.getRoomBackgrounds();
      }
    });
  }

  String imagePath = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.8,
      child: CardWidget(
        radius: 15.r,
        colorIndex: 1,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              /// ------------------- Tabs -------------------
              TabBar(
                controller: tab,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                dividerColor: Colors.transparent,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: context.l10n.templetes),
                  Tab(text: context.l10n.chooseImageFromDevice),
                ],
              ),

              SizedBox(height: 15.h),

              /// ------------------- Tabs Content -------------------
              Expanded(
                child: TabBarView(
                  controller: tab,
                  children: [_buildTempletes(context), _buildChoose(context)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTempletes(BuildContext context) {
    return Obx(() {
      return MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        itemCount: widget.controller.roomBackgrounds.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          String url = widget.controller.roomBackgrounds[index].url ?? "";
          return GestureDetector(
            onTap: () {
              Get.back();
              widget.controller.updateRoomBgByPath(url);
            },
            child: SizedBox(
              height: 250.h,
              child: AppImage(image: ImageModel(network: url)),
            ),
          );
        },
      );
    });
  }

  Widget _buildChoose(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        ChooseImage(
          aboveTitle: context.l10n.roomBackground,
          color: Color(0x26FFFFFF),
          file: File(imagePath),
          onChanged: (v) {
            setState(() {
              imagePath = v;
            });
          },
          onCancel: () {
            setState(() {
              imagePath = "";
            });
          },
          height: Get.height / 3.h,
        ),
        Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          child: GeneralButton3(
            onPressed: () {
              Get.back();
              if (imagePath != "") {
                widget.controller.updateRoomBg(File(imagePath));
              }
            },
            title: context.l10n.save,
          ),
        ),
        Spacer(),
      ],
    );
  }
}
