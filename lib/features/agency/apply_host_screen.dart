import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ApplyHostScreen extends StatefulWidget {
  final AgencyController controller;
  const ApplyHostScreen({super.key, required this.controller});

  @override
  State<ApplyHostScreen> createState() => _ApplyHostScreenState();
}

class _ApplyHostScreenState extends State<ApplyHostScreen> {
  ScrollController scrollController = ScrollController();
  int index = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.agencyRequests.clear();
    widget.controller.agencyRequestsPage = 1;
    widget.controller.hasMoreAgencyRequests.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getAgencyRequest();
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        if (index == 0) {
          await widget.controller.getAgencyRequest();
        } else {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.applyHost,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10).r,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Obx(() {
              List<UserModel> users = index == 0
                  ? widget.controller.agencyRequests
                  : widget.controller.agencyQuit;
              return Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 5.h);
                  },
                  itemBuilder: (context, index) {
                    return CardWidget(
                      radius: 15.r,
                      colorIndex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(10).r,
                        child: Row(
                          children: [
                            ProfileAvatar(
                              openProfileType: OpenProfileType.full,
                              radius: 25.r,
                              user: users[index],
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  UserNameWidget(
                                    user: users[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.h),
                                  UserIdWidget(
                                    user: users[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (index == 0) {
                                  bool res = await widget.controller
                                      .acceptRequest(users[index].userId, 9);
                                  if (res) {
                                    widget.controller.agencyRequests.removeAt(
                                      index,
                                    );
                                    widget.controller.agencyRequests.refresh();
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.check_circle,
                                color: AppColors.blueColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (index == 0) {
                                  deleteMessage(
                                    deleteButton: context.l10n.reject,
                                    cancelButton: context.l10n.cancel,
                                    title: context.l10n.confirm,
                                    content: "",
                                    onDelete: () async {
                                      Get.back();
                                      bool res = await widget.controller
                                          .acceptRequest(
                                            users[index].userId,
                                            2,
                                          );
                                      if (res) {
                                        widget.controller.agencyRequests
                                            .removeAt(index);
                                        widget.controller.agencyRequests
                                            .refresh();
                                      }
                                    },
                                    onCancel: Get.back,
                                    onWillPop: true,
                                  );
                                }
                              },
                              icon: Icon(Icons.cancel),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
