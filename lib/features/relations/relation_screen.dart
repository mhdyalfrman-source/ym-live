import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/follow_button.dart';
import 'package:tom_chat/features/profile/components/gender_widget.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/relations/controllers/relation_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RelationScreen extends StatefulWidget {
  final String title;
  final RelationType type;
  final int userId;
  const RelationScreen({
    super.key,
    required this.title,
    required this.type,
    required this.userId,
  });

  @override
  State<RelationScreen> createState() => _RelationScreenState();
}

class _RelationScreenState extends State<RelationScreen> {
  ScrollController scrollController = ScrollController();
  late RelationController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.put(RelationController());
    controller.relations.clear();
    controller.relationPage.value = 1;
    controller.hasMoreNotification.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllNotification(widget.userId, widget.type);
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllNotification(widget.userId, widget.type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: widget.title,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Obx(() {
          if (controller.relationPage.value > 1 &&
              controller.relations.isEmpty) {
            return Center(
              child: Text(
                context.l10n.thereAreNoDataYet,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(color: Colors.black),
              ),
            );
          }
          if (widget.type == RelationType.visitor) {
            return GroupedListView<UserModel, String>(
              controller: scrollController,
              elements: controller.relations,
              groupBy: (user) {
                DateTime d = user.visitAt!;
                return "${d.year}-${d.month}-${d.day}";
              },
              groupSeparatorBuilder: (String date) => Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              indexedItemBuilder: (ctx, user, index) {
                return userItem(index);
              },
              itemComparator: (a, b) =>
                  b.visitAt!.compareTo(a.visitAt!), // ترتيب تنازلي
              order: GroupedListOrder.DESC, // الأحدث أولاً
            );
          }
          return ListView.builder(
            controller: scrollController,
            itemCount: controller.relations.length,
            itemBuilder: (context, index) {
              return userItem(index);
            },
          );
        }),
      ),
    );
  }

  Widget userItem(int userIndex) {
    UserModel user = controller.relations[userIndex];
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          ProfileAvatar(
            user: user,
            radius: 22.r,
            openProfileType: OpenProfileType.full,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          return UserNameWidget(
                            textAlign: TextAlign.start,
                            width: c.maxWidth,
                            user: user,
                            style: Theme.of(context).textTheme.displaySmall!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GenderWidget(user: user),
                    SizedBox(width: 2.w),
                    Text(
                      user.isOnline == 1
                          ? context.l10n.online
                          : context.l10n.offline,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: user.isOnline == 1
                            ? AppColors.blueColor
                            : AppColors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                UserIdWidget(
                  user: user,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: Colors.black),
                ),
                MedalsWidget(
                  medals: user.medals ?? [],
                  vip: user.vip,
                  width: double.infinity,
                  size: 20.r,
                ),
              ],
            ),
          ),
          FollowButton(
            width: 60.w,
            showFriendsButton: false,
            user: user,
            relation: user.relation,
            callBack: (r) {
              if (r != null) {
                controller.relations[userIndex].relation = r;
                controller.relations.refresh();
              }
            },
          ),
        ],
      ),
    );
  }
}
