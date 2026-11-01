import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ProfileMedals extends StatelessWidget {
  final UserModel user;
  const ProfileMedals({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.medals == null) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            context.l10n.medals,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (user.medals != null && user.medals!.isNotEmpty)
          Wrap(
            children: [
              ...user.medals!.map((t) {
                return AppImage(
                  image: ImageModel(network: t.icon),
                  width: Get.width / 5,
                );
              }),
            ],
          )
        else
          Center(
            child: Text(
              context.l10n.thereAreNoMedalsYet,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: Colors.black),
            ),
          ),
      ],
    );
  }
}
