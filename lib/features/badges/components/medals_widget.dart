import 'package:flutter/material.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class MedalsWidget extends StatelessWidget {
  final List<MedalModel> medals;
  final VipModel? vip;
  final double size;
  final double width;
  final bool scrollable;
  final bool isCenter;

  const MedalsWidget({
    super.key,
    required this.medals,
    required this.vip,
    required this.width,
    this.size = 50,
    this.scrollable = true,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final achievedMedals = medals.where((m) => m.isAchieved).toList();

    if (achievedMedals.isEmpty && vip == null) {
      return const SizedBox.shrink();
    }

    Widget vipWidget = AppImage(
      progressIndicatorBuilder: (_, __, ___) => SizedBox(),
      image: ImageModel(network: vip?.icon),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    return scrollable
        ? SizedBox(
            height: size,
            width: width,
            child: Container(
              alignment: isCenter ? Alignment.center : null,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (vip != null) ...[vipWidget],
                    ...achievedMedals.map(
                      (m) => AppImage(
                        progressIndicatorBuilder: (_, __, ___) =>
                            const SizedBox(),
                        image: ImageModel(network: m.icon),
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Wrap(
            children: [
              vipWidget,
              ...achievedMedals.map(
                (m) => AppImage(
                  progressIndicatorBuilder: (_, __, ___) => SizedBox(),
                  image: ImageModel(network: m.icon),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
  }
}
