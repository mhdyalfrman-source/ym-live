import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/theme/color.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int coins;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Image.asset(
                    'assets/images/image_treasure.png',
                    height: 36.w,
                    width: 36.w,
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 45.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : Colors.grey[100],
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(11.r),
                  bottomEnd: Radius.circular(11.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/coin.png", height: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    coins.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
