import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class HostManagementScreen extends StatefulWidget {
  final AgencyController controller;
  const HostManagementScreen({super.key, required this.controller});

  @override
  State<HostManagementScreen> createState() => _HostManagementScreenState();
}

class _HostManagementScreenState extends State<HostManagementScreen> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    widget.controller.agencyUsers.clear();
    widget.controller.agencyUsersPage = 1;
    widget.controller.hasMoreAgencyUsers.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getAgencyUsers();
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await widget.controller.getAgencyUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.hostManagement,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10).r,
        child: Obx(() {
          return ListView.separated(
            controller: scrollController,
            itemCount: widget.controller.agencyUsers.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 5.h);
            },
            itemBuilder: (context, index) {
              return CardWidget(
                end: AlignmentGeometry.topCenter,
                begin: AlignmentGeometry.bottomCenter,
                radius: 15.r,
                colorIndex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10).r,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfileAvatar(
                            openProfileType: OpenProfileType.full,
                            user: widget.controller.agencyUsers[index],
                            radius: 25.r,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                UserNameWidget(
                                  user: widget.controller.agencyUsers[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5.h),
                                UserIdWidget(
                                  user: widget.controller.agencyUsers[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     GestureDetector(
                          //       onTap: (){},
                          //       child: Icon(Icons.person_add_outlined,)
                          //     ),
                          //     SizedBox(height: 3.h,),
                          //     Text(context.l10n.admin,style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          //       fontWeight: FontWeight.bold
                          //     ),),
                          //   ],
                          // ),
                          SizedBox(width: 8.w),
                          if (widget.controller.agencyUsers[index].role !=
                              RoleEnum.owner)
                            GestureDetector(
                              onTap: () async {
                                await deleteMessage(
                                  title: context.l10n.confirm,
                                  content:
                                      "${context.l10n.kickUser} ${widget.controller.agencyUsers[index].name}",
                                  deleteButton: context.l10n.kickUser,
                                  cancelButton: context.l10n.cancel,
                                  onDelete: () async {
                                    Get.back();
                                    if (await widget.controller.acceptRequest(
                                      widget
                                          .controller
                                          .agencyUsers[index]
                                          .userId,
                                      0,
                                    )) {
                                      widget.controller.agencyUsers.removeAt(
                                        index,
                                      );
                                      done();
                                    }
                                  },
                                  onCancel: Get.back,
                                  onWillPop: true,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_outlined),
                                  SizedBox(height: 3.h),
                                  Text(
                                    context.l10n.delete,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget buildTitleWithNumber(String title, String number) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            number,
            style: Theme.of(
              context,
            ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
