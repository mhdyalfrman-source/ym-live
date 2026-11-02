import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/search_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/store/backpack_screen.dart';
import 'package:tom_chat/features/store/components/confirm_cp_order.dart';
import 'package:tom_chat/features/store/components/confirm_order.dart';
import 'package:tom_chat/features/store/components/send_dialog.dart';
import 'package:tom_chat/features/store/controllers/store_controller.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class StoreScreen extends StatefulWidget {
  final int initialIndex;
  final UserModel? cp;
  const StoreScreen({super.key, this.initialIndex = 0, this.cp});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late StoreController controller;
  late HomeController homeController;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // tabController.addListener((){

    // });
    controller = Get.put(StoreController());
    homeController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedItem.value = -1;
      controller.selectedTab.value = widget.initialIndex;
      controller.fetchAllItems(widget.initialIndex).then((_) {
        if (widget.cp != null) {
          done(message: Get.context!.l10n.buyDeleteCart, duration: 5);
        }
      });
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllItems(controller.selectedTab.value);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialIndex,
      child: PageTemplete(
        title: context.l10n.store,
        actions: [
          IconButton(
            onPressed: () {
              controller.refershBackPack();
              swipToPage(
                context,
                BackpackScreen(
                  cp: widget.cp,
                  initialIndex: widget.initialIndex,
                ),
              );
            },
            icon: Icon(Ionicons.bag_outline, color: Colors.black),
          ),
        ],
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
              controller.fetchAllItems(index);
              controller.selectedTab.value = index;
              controller.selectedItem.value = -1;
              controller.items.refresh();
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
            final filtered = controller.items
                .asMap()
                .entries
                .where(
                  (entry) =>
                      entry.value.type.tabIndex == controller.selectedTab.value,
                )
                .toList();
            return Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: controller.selectedItem.value == -1 ? 0 : 100.h,
                  child: CardWidget(
                    width: double.infinity,
                    height: 100.h,
                    radius: 20.r,
                    colorIndex: 1,
                    child: controller.selectedItem.value == -1
                        ? SizedBox()
                        : AppImage(
                            image: controller
                                .items[controller.selectedItem.value]
                                .img,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),

                SizedBox(height: 10.h),

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
                          controller.selectedItem.value = originalIndex;
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CardWidget(
                              enable:
                                  controller.selectedItem.value ==
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
                                child: AppImage(
                                  image: item.img,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            SizedBox(height: 5.h),

                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${item.price?.lng}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Image.asset(
                                            "assets/images/coin.png",
                                            width: 15.r,
                                            height: 15.r,
                                          ),
                                        ],
                                      ),

                                      SizedBox(width: 5.w),

                                      Text(
                                        "/ ${item.days} ${context.l10n.day}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: GeneralButton(
                        onPressed:
                            controller.selectedItem.value == -1 ||
                                controller
                                        .items[controller.selectedItem.value]
                                        .type ==
                                    StoreType.special
                            ? null
                            : () {
                                showSendDialog(context, controller, false);
                              },
                        colorIndex: 1,
                        title: context.l10n.send,
                      ),
                    ),
                    Expanded(
                      child: GeneralButton(
                        onPressed: controller.selectedItem.value == -1
                            ? null
                            : () async {
                                if (controller
                                        .items[controller.selectedItem.value]
                                        .type ==
                                    StoreType.special) {
                                  if ([
                                    StoreTypeState.deleteCp,
                                    StoreTypeState.deleteFriend,
                                  ].contains(
                                    controller
                                        .items[controller.selectedItem.value]
                                        .typeState,
                                  )) {
                                    if (widget.cp != null &&
                                        controller
                                                .items[controller
                                                    .selectedItem
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
                                                .items[controller
                                                    .selectedItem
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
                                  showConfirmDialog(context, controller);
                                }
                              },
                        colorIndex: 1,
                        title: context.l10n.purchase,
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
