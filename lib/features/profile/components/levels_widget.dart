import 'package:flutter/material.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class LevelsWidget extends StatelessWidget {
  final List<LevelModel?> levels;
  final VipModel? vip;
  final double size;
  final double width;
  final bool scrollable;
  final bool isCenter;

  const LevelsWidget({
    super.key,
    required this.levels,
    required this.vip,
    required this.width,
    this.size = 50,
    this.scrollable = true,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final achievedMedals = levels.where((m) => m?.icon != null).toList();

    if (achievedMedals.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget vipWidget = AppImage(
      progressIndicatorBuilder: (_, __, ___) => SizedBox(),
      image: ImageModel(network: vip?.icon),
      width: size * 2,
      height: size * 2,
      fit: BoxFit.cover,
    );

    return scrollable
        ? SizedBox(
            height: vip?.icon != null ? null : size,
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
                        image: ImageModel(network: m!.icon),
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
            spacing: 8,
            runSpacing: 8,
            children: [
              vipWidget,
              ...achievedMedals.map(
                (m) => AppImage(
                  progressIndicatorBuilder: (_, __, ___) => SizedBox(),
                  image: ImageModel(network: m!.icon),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
  }
}
