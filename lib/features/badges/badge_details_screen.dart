import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/components/badge_stages_widget.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class BadgeDetailsScreen extends StatefulWidget {
  final MedalModel medal;
  const BadgeDetailsScreen({super.key, required this.medal});

  @override
  State<BadgeDetailsScreen> createState() => _BadgeDetailsScreenState();
}

class _BadgeDetailsScreenState extends State<BadgeDetailsScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1F0E0E),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xff2A2622)),
          child: Stack(
            children: [
              Positioned.fill(
                top: -20,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/light.png",
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: Get.back,
                        ),
                      ],
                    ),

                    SizedBox(height: 15.h),
                    Text(
                      "${widget.medal.name} ${context.l10n.target} ${widget.medal.target}",
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Color(0xffFFF701),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 30.h),
                    CachedImage(
                      widget.medal.icon,
                      width: 120.w,
                      type: ImageType.store,
                    ),
                    SizedBox(height: 20.h),
                    if (!widget.medal.isAchieved)
                      RichText(
                        text: TextSpan(
                          text: "${widget.medal.progress}",
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Color(0xffFFF701),
                                fontWeight: FontWeight.bold,
                              ),
                          children: [
                            TextSpan(
                              text: "/${widget.medal.target}",
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 30.h),

                    Text(
                      context.l10n.attractionLevelReached(widget.medal.target),
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),

                    Spacer(),
                    if (widget.medal.levels.isNotEmpty)
                      BadgeStagesWidget(
                        medals: widget.medal.levels,
                        currentStage: 1,
                      ),

                    Spacer(flex: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
