import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/games/game_viewer2.dart';

import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/home/components/banner_items.dart';
import 'package:tom_chat/features/home/components/room_item.dart';
import 'package:tom_chat/features/home/components/user_card.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/new_room_screen.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/features/tops/cp_tops_screen.dart';
import 'package:tom_chat/features/tops/tops_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/statics_values.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Timer timer;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (t) async {
      if (controller.banners.length > 1 &&
          controller.mainSelectedScreen.value == 1) {
        if (controller.adsPageIndex.value == controller.banners.length - 1) {
          controller.adsPageIndex.value = 0;
          controller.adsController.animateToPage(
            controller.adsPageIndex.value,
            duration: Duration(milliseconds: 500),
            curve: Easing.legacy,
          );
        } else {
          controller.adsPageIndex.value++;
          controller.adsController.animateToPage(
            controller.adsPageIndex.value,
            duration: Duration(milliseconds: 500),
            curve: Easing.legacy,
          );
        }
      }
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        if (controller.mainSelectedScreen.value == 1) {
          await controller.fetchAllLives();
        } else {
          await controller.fetchAllFollowerLives();
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    scrollController.dispose();
    super.dispose();
  }

  HomeController controller = Get.find();
  // ProjectController projectController = Get.put(ProjectController());
  // OrderController orderController = Get.put(OrderController());

  List colors = [Color(0xffE5FF00), Color(0xff00FF22), Color(0xff00C8FF)];
  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: "",
      child: RefreshIndicator(
        onRefresh: () async {
          if (controller.mainSelectedScreen.value == 1) {
            controller.livePage = 0;
            await controller.fetchAllLives();
          } else {
            controller.followerLivePage = 0;
            await controller.fetchAllFollowerLives();
          }
        },
        color: AppColors.primaryDark,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserCard(controller: controller),
                  Obx(() {
                    return PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (child, animation, secondaryAnimation) =>
                              SharedAxisTransition(
                                fillColor: Colors.transparent,
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              ),
                      child: controller.mainSelectedScreen.value == 1
                          ? Padding(
                              padding: const EdgeInsets.all(10).r,
                              child: Column(
                                children: [
                                  if (controller.banners.isNotEmpty) ...[
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      height: 100.h,
                                      width: double.infinity,
                                      child: PageView(
                                        onPageChanged: (v) {
                                          controller.adsPageIndex.value = v;
                                        },
                                        controller: controller.adsController,
                                        children: controller.banners
                                            .map(
                                              (b) => bannerItem(
                                                context: context,
                                                banner: b,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    // NavigatorDots(
                                    //   onTap: (index){
                                    //     controller.adsPageIndex.value = index;
                                    //     controller.adsController.animateToPage(index,duration: Duration(milliseconds: 500),curve: Easing.legacy);
                                    //   },
                                    //   width: 17,
                                    //   controller: controller.adsController,curentIndex: controller.adsPageIndex.value, length: controller.banners.length),
                                    // const SizedBox(height: 10,),
                                  ],
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: GestureDetector(
                                  //         onTap: (){
                                  //           swipToPage(context, TopsScreen());
                                  //         },
                                  //         child: Container(
                                  //           height: 70.h,
                                  //           decoration: BoxDecoration(
                                  //             image: DecorationImage(image: AssetImage("assets/images/button1.png"))
                                  //           ),
                                  //           padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  //           child: Row(
                                  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  //             children: [
                                  //               Text(context.l10n.order,style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                                  //               Image.asset("assets/images/order.png",width: 50.h,)
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: 10.w,),
                                  //     Expanded(
                                  //       child: GestureDetector(
                                  //         onTap: (){
                                  //           swipToPage(context, CPTopsScreen());
                                  //         },
                                  //         child: Container(
                                  //           height: 70.h,
                                  //           decoration: BoxDecoration(
                                  //             image: DecorationImage(image: AssetImage("assets/images/button2.png",))
                                  //           ),
                                  //           padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  //           child: Row(
                                  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  //             children: [
                                  //               Text(context.l10n.cp,style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                                  //               Image.asset("assets/images/cp.png",width: 50.h,)
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  SizedBox(height: 15.h),
                                  MasonryGridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12.h,
                                    crossAxisSpacing: 12.w,
                                    itemCount: controller.popularLives.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemBuilder: (context, index) {
                                      return RoomItem(
                                        border: index > 2
                                            ? ""
                                            : "assets/images/border${index == 0
                                                  ? "1"
                                                  : index == 1
                                                  ? "2"
                                                  : "3"}.png",
                                        room: controller.popularLives[index],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 65.h),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(10).r,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (controller.room.value == null) {
                                        Get.to(() => NewRoomScreen());
                                      } else {
                                        swipToPage(
                                          context,
                                          RoomScreen(
                                            withSetup:
                                                controller.keepRoom.value ==
                                                null,
                                            creatorId:
                                                StaticValue.userData.userId,
                                            roomId: controller.room.value!.id,
                                          ),
                                        );
                                      }
                                    },
                                    child: CardWidget(
                                      colorIndex: 1,
                                      radius: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        height: 80.h,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (controller.room.value == null)
                                              Image.asset(
                                                "assets/images/new_room.png",
                                                width: 50.r,
                                              )
                                            else
                                              ClipOval(
                                                child: SizedBox(
                                                  width: 50.r,
                                                  height: 50.r,
                                                  child:
                                                      controller
                                                              .room
                                                              .value!
                                                              .icon
                                                              ?.network ==
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                15,
                                                              ).r,
                                                          child: Image.asset(
                                                            "assets/images/logo.png",
                                                            fit: BoxFit.contain,
                                                          ),
                                                        )
                                                      : AppImage(
                                                          image: ImageModel(
                                                            network: controller
                                                                .room
                                                                .value!
                                                                .icon!
                                                                .network!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            Text(
                                              controller.room.value == null
                                                  ? context.l10n.createRoom
                                                  : controller
                                                        .room
                                                        .value!
                                                        .title,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.displayMedium,
                                            ),
                                            SizedBox(),
                                          ],
                                        ),
                                        // child: PageView(
                                        //   onPageChanged: (v){
                                        //     controller.adsPageIndex.value = v;
                                        //   },
                                        //   controller: controller.adsController,
                                        //   children:
                                        //   controller.banners.map((b)=>bannerItem(context: context, banner: b.value)).toList()
                                        // ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  DefaultTabController(
                                    initialIndex: controller.selectedTab.value,
                                    length: 2,
                                    child: TabWidget(
                                      onTap: (index) {
                                        controller.selectedTab.value = index;
                                      },
                                      tabs: [
                                        context.l10n.ifollow,
                                        context.l10n.last,
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  MasonryGridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12.h,
                                    crossAxisSpacing: 12.w,
                                    itemCount: controller.selectedTab.value == 0
                                        ? controller.followingLives.length
                                        : controller.lastLives.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemBuilder: (context, index) {
                                      if (controller.selectedTab.value == 0) {
                                        return RoomItem(
                                          room:
                                              controller.followingLives[index],
                                        );
                                      } else {
                                        return RoomItem(
                                          room: controller.lastLives[index],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(10).copyWith(top: 25).r,
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TabWidget extends StatelessWidget {
  const TabWidget({
    super.key,
    required this.tabs,
    required this.onTap,
    this.height,
  });

  final List<String> tabs;
  final Function(int) onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      height: height,
      radius: 30.r,
      colorIndex: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20).r,
        child: TabBar(
          onTap: onTap,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: EdgeInsets.symmetric(horizontal: 10).r,
          labelPadding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30).r,
          ),
          indicatorColor: Theme.of(context).primaryColor,
          dividerColor: Colors.transparent,
          labelStyle: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(color: Colors.white),
          unselectedLabelStyle: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(color: Colors.white),
          tabs: [...tabs.map((t) => Tab(child: Text(t)))],
        ),
      ),
    );
  }
}

class TabWidget3 extends StatelessWidget {
  const TabWidget3({
    super.key,
    required this.tabs,
    required this.onTap,
    this.height,
  });

  final List<String> tabs;
  final Function(int) onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 10).r,
      labelPadding: EdgeInsets.zero,
      indicatorPadding: EdgeInsets.zero,
      indicatorColor: Theme.of(context).primaryColor,
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: AppColors.primaryDark),
        borderRadius: BorderRadius.circular(100), // control padding
      ),
      labelStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: Theme.of(
        context,
      ).textTheme.displaySmall!.copyWith(color: Colors.black87),
      tabs: [...tabs.map((t) => Tab(child: Text(t)))],
    );
  }
}

class TabWidget2 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<String> tabs;
  final Color color;
  const TabWidget2({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20.w,
      children: [
        ...tabs.asMap().entries.map((i) => _buildTab(i.value, i.key, context)),
      ],
    );
  }

  Widget _buildTab(String text, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 17,
              height: 0,
              fontWeight: selectedIndex == index
                  ? FontWeight.bold
                  : FontWeight.bold,
            ),
          ),
          if (selectedIndex == index)
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 4.r,
              width: 30.r,
            ),
        ],
      ),
    );
  }
}

class MainItem extends StatelessWidget {
  const MainItem({
    super.key,
    required this.context,
    required this.title,
    required this.svg,
    required this.width,
    required this.height,
    required this.onTap,
    required this.enabled,
    this.color,
  });

  final BuildContext context;
  final String title;
  final String svg;
  final double width;
  final Color? color;
  final double height;
  final Function()? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        // decoration: BoxDecoration(
        // color: color,
        // border: Border.all(color: !enabled ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,width: 2),
        // borderRadius: BorderRadius.circular(20).r
        // ),
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(10).r,
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Image.asset(svg, width: width / 2),
                Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: !enabled
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
