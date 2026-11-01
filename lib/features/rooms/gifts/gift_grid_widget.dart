import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'gift_item_widget.dart';

class GiftGridWidget extends StatelessWidget {
  final List<GiftModel> gifts;
  final int selectedGiftIndex;
  final RoomController giftsController;
  final HomeController homeController;
  final Function(int) onGiftSelected;
  final Function(GiftModel) onGiftSent;
  final Function(int) onGiftCompleted;
  final Function() onGiftIncreased;
  final int? initialComboCount;
  final bool scrollable;

  const GiftGridWidget({
    super.key,
    required this.gifts,
    required this.selectedGiftIndex,
    required this.giftsController,
    required this.homeController,
    required this.onGiftSelected,
    required this.onGiftSent,
    required this.onGiftCompleted,
    required this.onGiftIncreased,
    this.initialComboCount,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: scrollable ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        return buildGiftItem(index);
      },
    );
  }

  Widget buildGiftItem(int index) {
    return Obx(
      () => GiftItemWidget(
        userHasVip: homeController.user.value.vipCustomGift,
        isLocked: false,
        requiredLevel: null,
        isSelected: selectedGiftIndex == index,
        isCombo: giftsController.comboGift.value?.id == gifts[index].id,
        initialComboCount: initialComboCount ?? 1,
        onSelect: () {
          onGiftSelected(index);
          giftsController.removeComboGift();
        },
        onSend: () async{
          giftsController.setComboGift(gifts[index]);
          await onGiftSent(gifts[index]);
        },
        onComplete: (int count) async {
          await giftsController.sendGift(completed: true);
          onGiftCompleted(count);
        },
        onIncrease: () async {
          onGiftIncreased();
        },
        giftModel: gifts[index],
      ),
    );
  }
}
