import 'package:flutter/material.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/models/banner_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:url_launcher/url_launcher.dart';

Widget bannerItem({
  required BuildContext context,
  required BannerModel banner,
}) {
  return GestureDetector(
    onTap: () {
      if (banner.url.isNotEmpty) {
        launchUrl(Uri.parse(banner.url), mode: LaunchMode.externalApplication);
      }
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.transparent,
      child: AppImage(
        image: ImageModel(network: banner.img),
        fit: BoxFit.cover,
      ),
    ),
  );
}
