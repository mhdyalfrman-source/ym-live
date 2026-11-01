import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ProfileFrams extends StatelessWidget {
  final UserModel user;
  const ProfileFrams({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            context.l10n.frames,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (user.frameList != null && user.frameList!.isNotEmpty)
          Wrap(
            children: [
              ...user.frameList!.map((t) {
                return AppImage(image: t.img, width: Get.width / 5);
              }),
            ],
          )
        else
          Center(
            child: Text(
              context.l10n.thereAreNoFrams,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: Colors.black),
            ),
          ),
      ],
    );
  }
}
