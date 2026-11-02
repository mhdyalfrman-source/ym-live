import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/apply_host_screen.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/agency/edit_agency_screen.dart';
import 'package:tom_chat/features/agency/perview_agency_screen.dart';
import 'package:tom_chat/features/agency/host_management_screen.dart';
import 'package:tom_chat/features/home/components/room_item.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class ManageAgencyScreen extends StatefulWidget {
  final int id;
  final int userId;
  const ManageAgencyScreen({super.key, required this.id, required this.userId});

  @override
  State<ManageAgencyScreen> createState() => _ManageAgencyScreenState();
}

class _ManageAgencyScreenState extends State<ManageAgencyScreen> {
  late AgencyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AgencyController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyAgency(widget.id, widget.userId);
      controller.getMyAgencyRooms(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.agency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10).r,
        child: Obx(() {
          if (controller.agency.value == null) {
            return SizedBox();
          }
          bool isOwner =
              controller.agency.value!.uid ==
              StaticValue
                  .userData
                  .userId; //[RoleEnum.owner].contains(controller.currentAgencyUser.value?.role);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardWidget(
                  radius: 15.r,
                  colorIndex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15).r,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ProfileAvatar(
                              width: 50.r,
                              height: 50.r,
                              borderRadius: BorderRadius.circular(10),
                              user: UserModel(
                                userId: 0,
                                name: "",
                                avatar: controller.agency.value!.icon,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.agency.value!.name ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5.h),
                                  Row(
                                    children: [
                                      Text(
                                        "${context.l10n.agencyId} : ${controller.agency.value!.id}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(color: Colors.white70),
                                      ),
                                      SizedBox(width: 5.w),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: controller.agency.value!.id
                                                  .toString(),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Ionicons.copy_outline,
                                          color: Colors.white70,
                                          size: 18.r,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                swipToPage(
                                  context,
                                  PerviewAgencyScreen(controller: controller),
                                );
                              },
                              icon: Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        if (isOwner) ...[
                          Divider(color: Colors.white70),
                          SizedBox(height: 5.h),
                          GeneralButton3(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.black,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ).r,
                            borderRadius: 30.r,
                            fontColor: Colors.black,
                            color: Colors.grey.shade200,
                            onPressed: () {
                              swipToPage(
                                context,
                                EditAgencyScreen(controller: controller),
                              );
                            },
                            title: context.l10n.editFile,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isOwner) ...[
                  SizedBox(height: 15.h),
                  CardWidget(
                    radius: 15.r,
                    colorIndex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10).r,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.hostManagement,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: (){},
                              //   child: Icon(Icons.arrow_forward_ios)
                              // )
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            children: [
                              // Expanded(
                              //   child: buildCounterItem(
                              //     number: 200,
                              //     title: context.l10n.hostCounts,
                              //     buttonTitle: context.l10n.inviteHost,
                              //     icon: Icons.inbox_outlined,
                              //     onPressed: (){}
                              //   )
                              // ),
                              // SizedBox(width: 5.w,),
                              Expanded(
                                child: buildCounterItem(
                                  number: 25,
                                  title: context.l10n.activeHost,
                                  buttonTitle: context.l10n.hostOrder,
                                  icon: Icons.notifications_outlined,
                                  onPressed: () {
                                    swipToPage(
                                      context,
                                      ApplyHostScreen(controller: controller),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                child: buildCounterItem(
                                  number: 2,
                                  title: context.l10n.newHost,
                                  buttonTitle: context.l10n.manage,
                                  icon: Icons.inbox_outlined,
                                  onPressed: () {
                                    swipToPage(
                                      context,
                                      HostManagementScreen(
                                        controller: controller,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  context.l10n.agencyRoom,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5.h),
                MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  itemCount: controller.agencyRooms.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return RoomItem(room: controller.agencyRooms[index]);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildCounterItem({
    required double number,
    required String title,
    required String buttonTitle,
    required IconData icon,
    Function()? onPressed,
  }) {
    return Column(
      children: [
        // Text(number.toStringAsFixed(0),style: Theme.of(context).textTheme.displayMedium!.copyWith(
        //   fontWeight: FontWeight.bold
        // ),),
        // SizedBox(height: 5.h,),
        // FittedBox(
        //   fit: BoxFit.scaleDown,
        //   child: Text(title,style: Theme.of(context).textTheme.displaySmall!,)),
        // SizedBox(height: 10.h,),
        SizedBox(
          width: double.infinity,
          child: GeneralButton3(
            margin: 3.w,
            onPressed: onPressed,
            title: buttonTitle,
            borderRadius: 30.r,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
            color: Colors.grey.shade200,
            fontColor: Colors.black,
            icon: Icon(icon, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
