import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/features/profile/profile_screen.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/small_profile_bottom_sheet.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

import 'app_image.dart';

enum OpenProfileType { small, full, none }

class ProfileAvatar extends StatelessWidget {
  final UserModel? user;
  final double? radius;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final OpenProfileType openProfileType;
  final String? customBorder;
  final String? assetCustomBorder;
  final double? withScaleOut;
  final EdgeInsetsGeometry? padding;
  final Function()? onTap;
  final bool fromRoom;

  const ProfileAvatar({
    super.key,
    required this.user,
    this.radius,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.customBorder,
    this.assetCustomBorder,
    this.withScaleOut,
    this.padding,
    this.fromRoom = false,
    this.fit = BoxFit.cover,
    this.openProfileType = OpenProfileType.none,
  }) : assert(
         radius != null || (width != null && height != null),
         'Either radius OR width & height must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    final avatar = user?.avatar;
    Widget child;

    final double w = radius != null ? radius! * 2 : width!;
    final double h = radius != null ? radius! * 2 : height!;

    if (avatar == null || (avatar.network?.isEmpty ?? true)) {
      child = _buildFallback(w, h);
    } else {
      child = AppImage(image: avatar, width: w, height: h, fit: fit);
    }

    String? frame =
        (assetCustomBorder ?? customBorder) ??
        (user?.avatar?.frame ?? user?.vip?.frame);

    bool hasAvatar = (frame ?? "") != "";
    return GestureDetector(
      onTap:
          onTap ??
          (openProfileType == OpenProfileType.none || (user?.userId ?? 0) == 0
              ? null
              : () {
                  if (openProfileType == OpenProfileType.full) {
                    swipToPage(
                      context,
                      ProfileScreen(id: user!.userId, fromRoom: fromRoom),
                    );
                  } else {
                    SmallProfileBottomSheet.show(context: context, user: user!);
                  }
                }),
      child: SizedBox(
        height: h + (hasAvatar && radius == null ? (h / 10).h : 0),
        width: w,
        child: Stack(
          children: [
            if (user != null)
              Positioned.fill(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: hasAvatar && radius == null ? (h / 10).h : 0,
                    ),
                    padding: hasAvatar && radius != null && padding == null
                        ? EdgeInsets.all((h / 10).h)
                        : padding,
                    child: radius != null
                        ? ClipOval(child: child)
                        : ClipRRect(
                            borderRadius:
                                borderRadius ?? BorderRadius.circular(12),
                            child: child,
                          ),
                  ),
                ),
              ),
            if ((user?.profileFrame ?? "") != "" &&
                radius == null &&
                customBorder == null)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, h * 0.15 * -1),
                  child: AppImage(
                    progressIndicatorBuilder: (_, __, ___) => SizedBox(),
                    image: user!.profileFrame!,
                  ),
                ),
              ),
            if (hasAvatar && (radius != null || customBorder != null))
              Positioned.fill(
                child: Transform.scale(
                  scale: withScaleOut != null
                      ? withScaleOut!
                      : customBorder != null
                      ? 2.5
                      : 1.4,
                  child: IgnorePointer(
                    child: assetCustomBorder != null
                        ? AppImage(
                            progressIndicatorBuilder: (_, __, ___) =>
                                SizedBox(),
                            image: ImageModel(asset: assetCustomBorder),
                            // fit: BoxFit.fill,
                          )
                        : customBorder != null
                        ? SvgaViwer(assetsSvga: customBorder!)
                        : AppImage(
                            progressIndicatorBuilder: (_, __, ___) =>
                                SizedBox(),
                            image: ImageModel(network: frame),
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(double w, double h) {
    final icon = SvgPicture.asset(
      "assets/svgs/avatar.svg",
      width: (radius ?? (w / 2)),
      height: (radius ?? (w / 2)),
      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );

    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade400,
      child: Center(child: icon),
    );
  }
}
