import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/store/components/category_dialogs.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ProfileEntries extends StatelessWidget {
  final UserModel user;
  const ProfileEntries({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            context.l10n.entries,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (user.entryList != null && user.entryList!.isNotEmpty)
          Wrap(
            children: [
              ...user.entryList!.map((t) {
                return GestureDetector(
                  onTap: () {
                    showPropDialog(context, t);
                  },
                  child: AppImage(image: t.img, width: Get.width / 5),
                );
              }),
            ],
          )
        else
          Center(
            child: Text(
              context.l10n.thereAreNoEntries,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: Colors.black),
            ),
          ),
      ],
    );
  }
}
