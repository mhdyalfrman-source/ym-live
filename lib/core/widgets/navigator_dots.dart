import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigatorDots extends StatelessWidget {
  const NavigatorDots({
    super.key,
    required this.controller,
    required this.length,
    required this.curentIndex,
    required this.onTap,
    this.width = 22,
  });

  final PageController controller;
  final int length;
  final int curentIndex;
  final double width;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ((width + 10) * length).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            length,
            (index) => InkWell(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                margin: index == curentIndex
                    ? null
                    : EdgeInsets.symmetric(horizontal: 5).r,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: index == curentIndex ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(5).r,
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: (index == curentIndex ? width : width / 2).r,
                    height: 10.r,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
