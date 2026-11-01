import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';

class BadgeStagesWidget extends StatelessWidget {
  final List<MedalModel> medals;
  final int currentStage;
  final double size;

  const BadgeStagesWidget({
    super.key,
    required this.medals,
    required this.currentStage,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size * 2,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: medals.length,
        separatorBuilder: (_, __) => Container(
          height: size * 2,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ).copyWith(bottom: size - 5.r),
          child: Center(
            child: Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: Image.asset("assets/images/tow_arrow.png", width: 30.r),
            ),
          ),
        ),
        itemBuilder: (context, index) {
          bool isActive = index <= currentStage;
          return Column(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.amber : Colors.grey.shade600,
                    width: isActive ? 3 : 1.5,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                  ],
                ),
                child: CachedImage(
                  medals[index].icon,
                  fit: BoxFit.cover,
                  type: ImageType.store,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                medals[index].name,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
