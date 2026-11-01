import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/agency/perview_agency_screen.dart';
import 'package:tom_chat/features/posts/components/post_item.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/features/profile/components/follow_button.dart';
import 'package:tom_chat/features/profile/components/gender_widget.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/profile_entries.dart';
import 'package:tom_chat/features/profile/components/profile_frams.dart';
import 'package:tom_chat/features/profile/components/profile_gifts.dart';
import 'package:tom_chat/features/profile/components/profile_header.dart';
import 'package:tom_chat/features/profile/components/profile_medals.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/relations/controllers/relation_controller.dart';
import 'package:tom_chat/features/relations/relation_screen.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/features/store/store_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';
import 'controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  final int id;
  final bool fromRoom;
  const ProfileScreen({super.key, required this.id, this.fromRoom = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;
  PostController postController = PostController();
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProfileController>(tag: widget.id.toString())) {
      controller = Get.put(
        ProfileController(widget.id),
        permanent: true,
        tag: widget.id.toString(),
      );
    } else {
      controller = Get.find<ProfileController>(tag: widget.id.toString());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetAllForUser();
    });
  }

  ScrollController? ctrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        primary: false,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // For iOS (dark icons)
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Obx(() {
              if (controller.loading.value || controller.user.value == null) {
                return const Center(child: CupertinoActivityIndicator());
              }

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: ProfileHeader(
                        user: controller.user.value!,
                        controller: controller,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xfff1d5d0),
                              Colors.white,
                              Colors.white,
                              Colors.white,
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10).r,
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10.h),
                                        Row(
                                          children: [
                                            UserNameWidget(
                                              user: controller.user.value,
                                              // gradient: LinearGradient(
                                              //   colors: colors[1],
                                              // ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            SizedBox(width: 5.w),
                                            GenderWidget(
                                              user: controller.user.value!,
                                            ),
                                            if ((controller
                                                            .user
                                                            .value
                                                            ?.onlineRid ??
                                                        0) !=
                                                    0 &&
                                                !widget.fromRoom &&
                                                controller.user.value!.userId !=
                                                    StaticValue
                                                        .userData
                                                        .userId) ...[
                                              const Spacer(),
                                              GeneralButton3(
                                                onPressed: () {
                                                  swipReplacementPage(
                                                    context,
                                                    RoomScreen(
                                                      creatorId: controller
                                                          .user
                                                          .value!
                                                          .userId,
                                                      roomId: controller
                                                          .user
                                                          .value!
                                                          .onlineRid!,
                                                    ),
                                                  );
                                                },
                                                title: "LIVE",
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        Row(
                                          children: [
                                            UserIdWidget(
                                              user: controller.user.value!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    color: Colors.black,
                                                  ),
                                            ),
                                            // SizedBox(width: 10.w),
                                            // Text(
                                            //   controller.user.value?.state == 1 ? "online" : "offline",
                                            //   style: Theme.of(context)
                                            //       .textTheme
                                            //       .displaySmall!
                                            //       .copyWith(color: Colors.blue),
                                            // ),
                                          ],
                                        ),
                                        SizedBox(height: 3.h),
                                        LevelsWidget(
                                          size: 13.r,
                                          levels:
                                              controller
                                                  .user
                                                  .value
                                                  ?.levels
                                                  ?.levels ??
                                              [],
                                          vip: controller.user.value?.vip,
                                          width: double.infinity,
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          controller.user.value?.comment ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.h),

                              /// الإحصائيات (المعجبين - المتابعة - الزوار)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  itemWithNumber(
                                    context.l10n.followers,
                                    controller.user.value?.followersCount
                                            ?.toString() ??
                                        "",
                                    () {
                                      if (controller.user.value?.userId ==
                                          StaticValue.userData.userId) {
                                        swipToPage(
                                          context,
                                          RelationScreen(
                                            userId: widget.id,
                                            type: RelationType.follower,
                                            title: context.l10n.followers,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  itemWithNumber(
                                    context.l10n.follow,
                                    controller.user.value?.followingCount
                                            ?.toString() ??
                                        "",
                                    () {
                                      if (controller.user.value?.userId ==
                                          StaticValue.userData.userId) {
                                        swipToPage(
                                          context,
                                          RelationScreen(
                                            userId: widget.id,
                                            type: RelationType.following,
                                            title: context.l10n.following,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  itemWithNumber(
                                    context.l10n.visitors,
                                    controller.user.value?.visitersCount
                                            ?.toString() ??
                                        "",
                                    () {
                                      if (controller.user.value?.userId ==
                                          StaticValue.userData.userId) {
                                        swipToPage(
                                          context,
                                          RelationScreen(
                                            userId: widget.id,
                                            type: RelationType.visitor,
                                            title: context.l10n.visitors,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),

                              if (controller.user.value?.cpLover != null) ...[
                                SizedBox(height: 15.h),
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/cp_small_bg.png",
                                      ),
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 100.r,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ProfileAvatar(
                                        radius: 30.r,
                                        user: controller.user.value!,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/images/cp_heart.png",
                                            height: 30.r,
                                          ),
                                          if (controller
                                                  .user
                                                  .value!
                                                  .cpLoveDate !=
                                              null)
                                            Text(
                                              "${DateTime.now().difference(controller.user.value!.cpLoveDate!).inDays} ${context.l10n.day}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                        ],
                                      ),
                                      if (controller.user.value!.cpLover !=
                                          null)
                                        ProfileAvatar(
                                          radius: 30.r,
                                          user: controller.user.value!.cpLover,
                                          openProfileType: OpenProfileType.full,
                                        )
                                      else ...[
                                        if (controller.user.value!.userId ==
                                            StaticValue.userData.userId)
                                          GestureDetector(
                                            onTap: () {
                                              swipToPage(
                                                context,
                                                StoreScreen(initialIndex: 4),
                                              );
                                            },
                                            child: SizedBox(
                                              width: 60.r,
                                              height: 60.r,
                                              child: CardWidget(
                                                shape: BoxShape.circle,
                                                radius: 0,
                                                colorIndex: 1,
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 30.r,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              // if(controller.user.value!.cpList.isNotEmpty)...[
                              // SizedBox(height: 15.h),
                              // Align(
                              //   alignment: AlignmentDirectional.centerStart,
                              //   child: Text(context.l10n.friends,style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              //     color: Colors.black,
                              //     fontWeight: FontWeight.bold
                              //   ),),
                              // ),
                              // SizedBox(height: 5.h),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 5).r,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       ...[
                              //         ...controller.user.value!.cpList,
                              //         ...List.generate(
                              //           (3 - controller.user.value!.cpList.length).clamp(0, 3),
                              //           (_) => UserModel(userId: 0, name: ""),
                              //         ),
                              //       ].map((cp){
                              //         return SizedBox(
                              //           width: Get.width * 0.29,
                              //           height: Get.width * 0.25,
                              //           child: Container(
                              //             decoration: BoxDecoration(
                              //               borderRadius: BorderRadius.circular(15.r),
                              //               color: Colors.black12
                              //             ),
                              //             child: Stack(
                              //             children: [
                              //               Padding(
                              //                 padding: EdgeInsets.all(5).r,
                              //                 child: cp.userId == 0 ?
                              //                 Center(child: IconButton(onPressed: (){
                              //                   swipToPage(context, StoreScreen(initialIndex: 4,));
                              //                 }, icon: Icon(Icons.add)),) :
                              //                 GestureDetector(
                              //                   onTap: (){
                              //                     if(controller.user.value?.userId != cp.userId){
                              //                       swipToPage(context, ProfileScreen(id: cp.userId));
                              //                     }
                              //                   },
                              //                   child: Center(
                              //                     child: Column(
                              //                       mainAxisAlignment: MainAxisAlignment.center,
                              //                       crossAxisAlignment: CrossAxisAlignment.center,
                              //                       children: [
                              //                         ProfileAvatar(user: cp,radius: 20.r,),
                              //                         SizedBox(height: 5.h,),
                              //                         UserNameWidget(
                              //                           width: Get.width * 0.25,
                              //                           user: cp, style: Theme.of(context).textTheme.labelMedium)
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //               if(cp.userId != 0 && StaticValue.userData.userId == controller.user.value?.userId)
                              //               Positioned(
                              //                 top: 5.h,
                              //                 right: 5.w,
                              //                 child: InkWell(
                              //                   onTap: (){
                              //                     swipReplacementPage(context, StoreScreen(initialIndex: 4,cp: cp,));
                              //                   },
                              //                   child: Icon(Icons.close)
                              //                 ),
                              //               )
                              //             ],
                              //           )),
                              //         );
                              //       })
                              //     ],
                              //   ),
                              // ),

                              // ],
                              if (controller.user.value?.agency != null) ...[
                                SizedBox(height: 15.h),
                                GestureDetector(
                                  onTap: () {
                                    AgencyController agencyController = Get.put(
                                      AgencyController(),
                                    );
                                    agencyController.agency.value =
                                        controller.user.value!.agency;
                                    swipToPage(
                                      context,
                                      PerviewAgencyScreen(
                                        controller: agencyController,
                                      ),
                                    );
                                  },
                                  child: CardWidget(
                                    radius: 10.r,
                                    colorIndex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10).r,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ).r,
                                            child: AppImage(
                                              image: controller
                                                  .user
                                                  .value!
                                                  .agency!
                                                  .icon,
                                              height: 60.r,
                                              width: 60.r,
                                            ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5.h),
                                                Text(
                                                  "${context.l10n.agencyName} : ${controller.user.value!.agency!.name}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                  context.l10n.id(
                                                    controller
                                                        .user
                                                        .value!
                                                        .agency!
                                                        .id,
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10.w),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: 15.h),
                              if (controller.user.value!.userId !=
                                  StaticValue.userData.userId) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: FollowButton(
                                        width: double.infinity,
                                        showFriendsButton: true,
                                        user: controller.user.value!,
                                        relation:
                                            controller.user.value!.relation,
                                        callBack: (r) {
                                          if (r != null) {
                                            controller.user.update((val) {
                                              val?.relation = r;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    if (controller.user.value?.relation ==
                                            PersonRelation.friends ||
                                        StaticValue.userData.vip != null) ...[
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: FollowButton(
                                          width: double.infinity,
                                          showFriendsButton: false,
                                          user: controller.user.value!,
                                          relation: PersonRelation.friends,
                                          callBack: (r) {
                                            if (r != null) {
                                              controller.user.update((val) {
                                                val?.relation = r;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 15.h),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverSafeAreaDelegate(context),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          indicatorColor: AppColors.primaryDark,
                          labelColor: Theme.of(context).colorScheme.onSurface,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                          dividerColor: Colors.transparent,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            Tab(icon: Text(context.l10n.data)),
                            Tab(icon: Text(context.l10n.moments)),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 7.h),
                        height: 8.h,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ProfileMedals(user: controller.user.value!),
                          // const Divider(thickness: 1, color: Colors.transparent),
                          ProfileFrams(user: controller.user.value!),
                          const Divider(
                            thickness: 1,
                            color: Colors.transparent,
                          ),
                          ProfileEntries(user: controller.user.value!),
                          const Divider(
                            thickness: 1,
                            color: Colors.transparent,
                          ),
                          ProfileGifts(user: controller.user.value!),
                          const Divider(
                            thickness: 1,
                            color: Colors.transparent,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Obx(() {
                      if (controller.posts.isEmpty) {
                        return Center(
                          child: Text(
                            context.l10n.noPostsFound,
                            style: Theme.of(context).textTheme.displayMedium!
                                .copyWith(color: Colors.black),
                          ),
                        );
                      }

                      return Builder(
                        builder: (context) {
                          if (ctrl == null) {
                            ctrl = PrimaryScrollController.of(context);
                            ctrl!.addListener(() async {
                              if (!ctrl!.hasClients) return;
                              final pos = ctrl!.position;
                              if (pos.pixels > 0 &&
                                  (pos.maxScrollExtent - pos.pixels) == 0) {
                                await controller.fetchAllPosts();
                              }
                            });
                          }
                          return ListView.builder(
                            controller: ctrl,
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.posts.length,
                            itemBuilder: (context, index) {
                              final post = controller.posts[index];
                              return PostItem(
                                post: post,
                                index: index,
                                controller: postController,
                              );
                            },
                          );
                        },
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
          IgnorePointer(
            child: Obx(() {
              if (controller.activeEntry.value != null) {
                return SafeArea(
                  top: false,
                  child: SvgaViwer(
                    fit: BoxFit.cover,
                    networkSvga:
                        controller.activeEntry.value!.animation.network!,
                    repeated: false,
                    count: 1,
                    onFinish: () async {
                      controller.activeEntry.value = null;
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }

  Widget itemWithNumber(String title, String number, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _SliverSafeAreaDelegate extends SliverPersistentHeaderDelegate {
  final BuildContext context;

  _SliverSafeAreaDelegate(this.context);

  @override
  double get minExtent => MediaQuery.of(context).padding.top;

  @override
  double get maxExtent => MediaQuery.of(context).padding.top;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Theme.of(context).colorScheme.surface);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
