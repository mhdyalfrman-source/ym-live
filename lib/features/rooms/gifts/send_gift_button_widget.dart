import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class SendGiftButtonWidget extends StatelessWidget {
  final ThemeData theme;
  final Function(int) onTabTap;
  final int selectedTab;
  final RoomController giftsController;

  const SendGiftButtonWidget({
    super.key,
    required this.theme,
    required this.onTabTap,
    required this.selectedTab,
    required this.giftsController,
  });

  @override
  Widget build(BuildContext context) {
    List<String> tabTitles = ["Gifts"];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 4),
            // ...tabTitles.map((title) => Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 8),
            //       child: GestureDetector(
            //         onTap: () {
            //           onTabTap(tabTitles.indexOf(title));
            //         },
            //         child: Text(
            //           title,
            //           style: theme.textTheme.titleMedium?.copyWith(
            //             fontWeight: selectedTab == tabTitles.indexOf(title)
            //                 ? FontWeight.w800
            //                 : FontWeight.w500,
            //             color: selectedTab == tabTitles.indexOf(title)
            //                 ? Colors.white70
            //                 : Colors.white24,
            //           ),
            //         ),
            //       ),
            //     )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xff222222),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Obx(() {
                return PopupMenuButton<int>(
                  onSelected: (v) {
                    giftsController.selctedCompo.value = v;
                  },
                  child: Row(
                    children: [
                      Text(
                        "${giftsController.selctedCompo.value}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Icon(Icons.arrow_drop_up, size: 14.r),
                    ],
                  ),
                  itemBuilder: (contetx) {
                    return [
                      ...giftsController.comoItems.map(
                        (c) =>
                            PopupMenuItem(value: c, child: Text(c.toString())),
                      ),
                    ];
                  },
                );
              }),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                giftsController.recharge();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xff222222),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/images/coin.png', width: 16.r),
                    const SizedBox(width: 4),
                    Obx(
                      () => Text(
                        StaticValue.coins.value == 0
                            ? context.l10n.recharged
                            : '${StaticValue.coins.value}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.surface.withOpacity(0.5),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
