import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/gifts/gift_grid_widget.dart';
import 'package:tom_chat/features/rooms/gifts/lucky_win_on_gift_box.dart';
import 'package:tom_chat/features/rooms/gifts/send_gift_button_widget.dart';
import 'package:tom_chat/features/rooms/gifts/user_level_bar.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class LiveRoomSendGiftBottomSheet extends StatefulWidget {
  final RoomController controller;
  final Function(GiftModel) onSend;
  final RoomModel room;
  final UserModel? selectedGust;
  final UserModel? currentUser;
  final Function(UserModel)? onSwitchAccount;
  final Color? barrierColor;
  const LiveRoomSendGiftBottomSheet({
    super.key,
    this.selectedGust,
    this.currentUser,
    this.onSwitchAccount,
    this.barrierColor,
    required this.room,
    required this.controller,
    required this.onSend,
  });

  @override
  State<LiveRoomSendGiftBottomSheet> createState() =>
      _LiveRoomSendGiftBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController giftsController,
    Function(GiftModel) onSend,
    RoomModel room, [
    UserModel? selectedGust,
    UserModel? currentUser,
    Function(UserModel)? onSwitchAccount,
    Color? barrierColor,
  ]) async {
    giftsController.isBottomSheetOpen.value = true;
    giftsController.fetchGifts();
    giftsController.luckyWins.clear();
    await showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => LiveRoomSendGiftBottomSheet(
        controller: giftsController,
        selectedGust: selectedGust,
        onSwitchAccount: onSwitchAccount,
        onSend: onSend,
        barrierColor: barrierColor,
        currentUser: currentUser,
        room: room,
      ),
    );
    giftsController.isBottomSheetOpen.value = false;
    return;
  }
}

class _LiveRoomSendGiftBottomSheetState
    extends State<LiveRoomSendGiftBottomSheet> {
  int _selectedGiftIndex = -1;
  int _selectedTab = 0;
  GiftType selectedType = GiftType.gift;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LuckyWinOnGiftBox(controller: widget.controller),
        SizedBox(height: 10.h),
        Container(
          height: Get.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => UserLevelBar(
                  selectedGiftIndex: _selectedGiftIndex,
                  controller: widget.controller,
                  inCombo: widget.controller.comboGift.value != null,
                ),
              ),
              Divider(color: theme.colorScheme.surface.withOpacity(0.3)),
              Obx(() {
                List<GiftType> giftsType = widget.controller.gifts
                    .map((g) => g.type)
                    .toList();
                giftsType.sort((a, b) => a.index.compareTo(b.index));
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20.w,
                    children: [
                      SizedBox(),
                      ...giftsType.toSet().map((i) => _buildTab(i, context)),
                      SizedBox(),
                    ],
                  ),
                );
              }),
              SizedBox(height: 10.h),
              Expanded(
                child: Obx(() {
                  return GiftGridWidget(
                    homeController: Get.find<HomeController>(),
                    gifts: widget.controller.gifts
                        .where((g) => g.type == selectedType)
                        .toList()
                        .obs,
                    selectedGiftIndex: _selectedGiftIndex,
                    giftsController: widget.controller,
                    initialComboCount: widget.controller.comboGift.value?.count,
                    onGiftSelected: (index) {
                      setState(() {
                        _selectedGiftIndex = index;
                      });
                    },
                    onGiftSent: (gift) async {
                      // widget.onSend(gift);
                      await widget.controller.sendGift(
                        completed: true,
                        gift: gift,
                      );
                    },
                    onGiftCompleted: (count) async {
                      await widget.controller.sendGift(completed: true);
                    },
                    onGiftIncreased: () async {
                      await widget.controller.increaseComboCount();
                    },
                    scrollable: false,
                  );
                }),
              ),
              SendGiftButtonWidget(
                theme: theme,
                onTabTap: (index) {
                  setState(() {
                    _selectedTab = index;
                    _selectedGiftIndex = -1;
                  });
                },
                selectedTab: _selectedTab,
                giftsController: widget.controller,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(GiftType type, BuildContext context) {
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
          if (type == GiftType.backPack)
            Icon(Ionicons.bag_outline, size: 20.r)
          else
            Text(
              type.getLocalization(context),
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
