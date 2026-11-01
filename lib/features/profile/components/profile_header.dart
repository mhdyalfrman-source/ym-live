import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tom_chat/core/helpers/app_share_helper.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/profile/controllers/profile_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  final UserModel user;
  const ProfileHeader({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppImage(
            image: user.bg,
            height: Get.height * 0.4,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          PositionedDirectional(
            bottom: 0,
            start: 20,
            end: 20,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      ProfileAvatar(radius: 35.r, user: user),
                      if (user.cpLover != null) ...[
                        Image.asset(
                          "assets/images/cp_small_heart.png",
                          width: 20.r,
                        ),
                        ProfileAvatar(
                          radius: 30.r,
                          user: user.cpLover,
                          openProfileType: OpenProfileType.full,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 35.r,
                  child: MedalsWidget(
                    vip: null,
                    medals: user.medals ?? [],
                    width: double.infinity,
                    size: 35.r,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 20,
            start: 20,
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Colors.black.withValues(alpha: 0.8),
                ),
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              onPressed: Get.back,
              icon: Icon(Icons.arrow_back_ios_new),
            ),
          ),
          PositionedDirectional(
            top: 20,
            end: 20,
            child: Row(
              children: [
                IconButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                  tooltip: context.l10n.share,
                  onPressed: () async {
                    AppShareHelper share = AppShareHelper(
                      type: AppShareType.profile,
                      parameters: {ShareKeyType.uid: user.userId.toString()},
                    );
                    await SharePlus.instance.share(
                      ShareParams(
                        uri: Uri.parse(share.getShareUrl),
                        title: context.l10n.share,
                      ),
                    );
                  },
                  icon: Icon(HugeIcons.strokeRoundedShare05),
                ),
                if (user.userId == StaticValue.userData.userId)
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    onPressed: () async {
                      await controller.updateBG();
                    },
                    icon: Icon(HugeIcons.strokeRoundedEdit01),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
