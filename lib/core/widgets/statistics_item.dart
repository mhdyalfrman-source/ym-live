import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsItem extends StatelessWidget {
  final String title;
  final double number;
  final Color? color;
  final Function()? onTap;
  const StatisticsItem({
    super.key,
    required this.title,
    required this.number,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Card(
          elevation: 5,
          color: color ?? Theme.of(context).primaryColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall!.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      number.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   width: 50.h,
              //   height: 50.h,
              //   padding: EdgeInsets.all(8.h),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Colors.white
              //   ),
              //   child: SvgPicture.asset("assets/svgs/chart.svg",colorFilter: ColorFilter.mode(color??Theme.of(context).primaryColor, BlendMode.srcIn) ,),
              // ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
