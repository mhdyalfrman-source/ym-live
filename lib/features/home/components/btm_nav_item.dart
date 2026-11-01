import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BtmNavItem extends StatelessWidget {
  const BtmNavItem({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.selectedIndex,
    required this.image,
    required this.activeimage,
    required this.title,
  });

  final int currentIndex;
  final Function() onTap;
  final int selectedIndex;
  final String image;
  final String activeimage;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final isSelected = selectedIndex == currentIndex;
    final activeColor = Color(0xffE65100);
    final inactiveColor =
        navTheme.unselectedItemColor ?? theme.primaryColorDark;
    final transparentColor = activeColor.withValues(alpha: 0);
    final indicatorColor = activeColor.withValues(alpha: 0.12);
    final selectedBorderColor = activeColor.withValues(alpha: 0.18);

    return Material(
      color: transparentColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: activeColor.withValues(alpha: 0.08),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected ? indicatorColor : transparentColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? selectedBorderColor : transparentColor,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 10.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.08 : 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isSelected ? 1 : 0.68,
                  child: Image.asset(
                    isSelected ? activeimage : image,
                    height: 28.r,
                    width: 28.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                height: 16.h,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
