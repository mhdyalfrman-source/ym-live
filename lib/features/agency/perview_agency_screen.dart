import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class PerviewAgencyScreen extends StatefulWidget {
  final AgencyController controller;
  const PerviewAgencyScreen({super.key, required this.controller});

  @override
  State<PerviewAgencyScreen> createState() => _PerviewAgencyScreenState();
}

class _PerviewAgencyScreenState extends State<PerviewAgencyScreen> {
  @override
  Widget build(BuildContext context) {
    bool isOwner =
        widget.controller.agency.value!.uid ==
        StaticValue
            .userData
            .userId; //[RoleEnum.owner].contains(controller.currentAgencyUser.value?.role);
    return PageTemplete(
      title: context.l10n.agency,
      child: Padding(
        padding: EdgeInsets.all(10).r,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CardWidget(
                radius: 10.r,
                colorIndex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.h),
                    ProfileAvatar(
                      radius: 60.r,
                      user: UserModel(
                        userId: 0,
                        name: "",
                        avatar: widget.controller.agency.value!.icon,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    if (isOwner)
                      GeneralButton3(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ).r,
                        borderRadius: 30.r,
                        fontColor: Colors.black,
                        color: Colors.grey.shade200,
                        onPressed: () {},
                        title: context.l10n.changePicture,
                      ),
                    SizedBox(height: 15.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.h),
            buildTitleDescCard(
              context.l10n.agencyName,
              widget.controller.agency.value!.name ?? "",
            ),
            SizedBox(height: 10.h),
            buildTitleDescCard(
              context.l10n.agencyNotice,
              widget.controller.agency.value!.notice ?? "",
            ),
            SizedBox(height: 10.h),
            buildTitleDescCard(
              context.l10n.agencyId,
              widget.controller.agency.value!.id.toString(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: widget.controller.agency.value!.id.toString(),
                    ),
                  );
                },
                child: Icon(HugeIcons.strokeRoundedCopy01, size: 15.r),
              ),
            ),
            SizedBox(height: 10.h),
            // buildTitleDescCard(context.l10n.agencyOwner, widget.controller.agency.value!.user?.name??""),
            // SizedBox(height: 10.h),
            buildTitleDescCard(
              context.l10n.ownerId,
              widget.controller.agency.value!.uid.toString(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: widget.controller.agency.value!.uid.toString(),
                    ),
                  );
                },
                child: Icon(HugeIcons.strokeRoundedCopy01, size: 15.r),
              ),
            ),
            SizedBox(height: 10.h),
            // buildTitleDescCard(context.l10n.hostCounts, "100"),
            // SizedBox(height: 10.h),
            buildTitleDescCard(
              context.l10n.createDate,
              widget.controller.agency.value!.createAt ?? "",
            ),
            // SizedBox(height: 10.h),
            // buildTitleDescCard(context.l10n.notics, "Say Hi",Icon(HugeIcons.strokeRoundedEdit02,size: 15.r,)),
          ],
        ),
      ),
    );
  }

  Widget buildTitleDescCard(
    String title,
    String description, [
    Widget icon = const SizedBox(),
  ]) {
    return CardWidget(
      radius: 20.r,
      colorIndex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15).r,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                title,
                style: Theme.of(context).textTheme.displaySmall!,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                description,
                style: Theme.of(context).textTheme.displaySmall!,
              ),
            ),
            SizedBox(width: 3.w),
            icon,
          ],
        ),
      ),
    );
  }
}
