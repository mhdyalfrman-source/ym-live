import 'package:flutter/material.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ProfileGifts extends StatelessWidget {
  final UserModel user;
  const ProfileGifts({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            context.l10n.gifts,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (user.giftsList != null && user.giftsList!.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            itemCount: user.giftsList!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final gift = user.giftsList![index];
              return AppImage(image: ImageModel(network: gift.img ?? ""));
            },
          )
        else
          Center(
            child: Text(
              context.l10n.thereAreNoGifts,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: Colors.black),
            ),
          ),
      ],
    );
  }
}
