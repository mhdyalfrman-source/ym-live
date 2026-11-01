import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class UserIdWidget extends StatelessWidget {
  final UserModel? user;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double? size;
  const UserIdWidget({
    super.key,
    required this.user,
    required this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (user?.specialId != null) {
      return Row(
        children: [
          Text(
            (user?.specialId?.val ?? "").toString(),
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          ),
          SizedBox(width: 5.w),
          AppImage(
            image: ImageModel(network: user?.specialId?.img),
            height: size ?? 30.r,
            width: size ?? 30.r,
          ),
        ],
      );
    }
    return Text(
      context.l10n.id(user?.userId ?? ""),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
