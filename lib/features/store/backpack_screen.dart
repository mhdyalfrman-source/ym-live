import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/search_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/store/components/confirm_cp_order.dart';
import 'package:tom_chat/features/store/components/send_dialog.dart';
import 'package:tom_chat/features/store/controllers/store_controller.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class BackpackScreen extends StatefulWidget {
  final int initialIndex;
  final UserModel? cp;
  const BackpackScreen({super.key, this.initialIndex = 0, this.cp});

  @override
  State<BackpackScreen> createState() => _BackpackScreenState();
}

class _BackpackScreenState extends State<BackpackScreen> {
  late StoreController controller;
  late HomeController homeController;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    controller = Get.put(StoreController());
    homeController = Get.find();
    controller.selectedBackpackTab.value = widget.initialIndex;
    controller.selectedBackpackItem.value = -1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllBackPackItems(widget.initialIndex);
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllBackPackItems(
          controller.selectedBackpackTab.value,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialIndex,
      child: PageTemplete(
        title: context.l10n.backpack,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, AppBar().preferredSize.height),
          child: TabBar(
            dividerColor: Colors.transparent,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
            onTap: (index) {
              controller.fetchAllBackPackItems(index);
              controller.selectedBackpackTab.value = index;
              controller.selectedBackpackItem.value = -1;
              controller.backPackItems.refresh();
            },
            tabs: [
              Tab(text: context.l10n.frames),
              Tab(text: context.l10n.bubles),
              Tab(text: context.l10n.entries),
              Tab(text: context.l10n.profileFrame),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10).r,
          child: Obx(() {
            final filtered = controller.backPackItems
                .asMap()
                .entries
                .where(
                  (entry) =>
                      entry.value.type.tabIndex ==
                      controller.selectedBackpackTab.value,
                )
                .toList();
            return Column(
              children: [
                Expanded(
                  child: MasonryGridView.count(
                    controller: scrollController,
                    crossAxisCount: 3,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final originalIndex = filtered[i].key;
                      final item = filtered[i].value;

                      return GestureDetector(
                        onTap: () {
                          controller.selectedBackpackItem.value = originalIndex;
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CardWidget(
                              enable:
                                  controller.selectedBackpackItem.value ==
                                  originalIndex,
                              colorIndex: 1,
                              radius: 15,
                              height: 80.h,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffFFDDBC),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.all(1).r,
                                child: AppImage(image: item.img),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Center(
                              child: Text(
                                item.name,
                                style: Theme.of(context).textTheme.labelSmall!
                                    .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if ((item.expiredAt ?? 0) > 0)
                              Center(
                                child: Text(
                                  "${DateTime.fromMillisecondsSinceEpoch(item.expiredAt! * 1000).difference(DateTime.now()).inDays} ${context.l10n.day}",
                                  style: Theme.of(context).textTheme.labelSmall!
                                      .copyWith(color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GeneralButton(
                        onPressed:
                            controller.selectedBackpackItem.value != -1 &&
                                controller
                                        .backPackItems[controller
                                            .selectedBackpackItem
                                            .value]
                                        .active ==
                                    0
                            ? () async {
                                if (controller
                                        .backPackItems[controller
                                            .selectedBackpackItem
                                            .value]
                                        .type ==
                                    StoreType.special) {
                                  if ([
                                    StoreTypeState.deleteCp,
                                    StoreTypeState.deleteFriend,
                                  ].contains(
                                    controller
                                        .backPackItems[controller
                                            .selectedBackpackItem
                                            .value]
                                        .typeState,
                                  )) {
                                    if (widget.cp != null &&
                                        controller
                                                .backPackItems[controller
                                                    .selectedBackpackItem
                                                    .value]
                                                .typeState ==
                                            StoreTypeState.deleteFriend) {
                                      showConfirmCPDialog(
                                        context,
                                        controller,
                                        widget.cp!,
                                        true,
                                      );
                                    } else if (homeController
                                                .user
                                                .value
                                                .cpLover !=
                                            null &&
                                        controller
                                                .backPackItems[controller
                                                    .selectedBackpackItem
                                                    .value]
                                                .typeState ==
                                            StoreTypeState.deleteCp) {
                                      showConfirmCPDialog(
                                        context,
                                        controller,
                                        homeController.user.value.cpLover!,
                                        true,
                                      );
                                    } else {
                                      done(message: context.l10n.thereAreNoCp);
                                    }
                                  } else {
                                    var res = await swipToPage(
                                      context,
                                      SearchScreen(
                                        initialIndex: 1,
                                        withSelect: true,
                                      ),
                                    );
                                    if (res is UserModel &&
                                        res.userId !=
                                            StaticValue.userData.userId) {
                                      showConfirmCPDialog(
                                        context,
                                        controller,
                                        res,
                                        false,
                                      );
                                    }
                                  }
                                } else {
                                  controller.activeItem(
                                    controller.backPackItems[controller
                                        .selectedBackpackItem
                                        .value],
                                    true,
                                  );
                                }
                              }
                            : null,
                        colorIndex: 1,
                        title: context.l10n.wear,
                      ),
                    ),
                    Expanded(
                      child: GeneralButton(
                        onPressed:
                            controller.selectedBackpackItem.value != -1 &&
                                controller
                                        .backPackItems[controller
                                            .selectedBackpackItem
                                            .value]
                                        .active ==
                                    1
                            ? () {
                                if (controller
                                        .backPackItems[controller
                                            .selectedBackpackItem
                                            .value]
                                        .type ==
                                    StoreType.special) {
                                  return;
                                }
                                controller.activeItem(
                                  controller.backPackItems[controller
                                      .selectedBackpackItem
                                      .value],
                                  false,
                                );
                              }
                            : null,
                        colorIndex: 1,
                        title: context.l10n.takeOff,
                      ),
                    ),
                    if (homeController.user.value.vipShareItem)
                      Expanded(
                        child: GeneralButton(
                          onPressed: controller.selectedBackpackItem.value != -1
                              ? () {
                                  showSendDialog(context, controller, true);
                                }
                              : null,
                          colorIndex: 1,
                          title: context.l10n.send,
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
