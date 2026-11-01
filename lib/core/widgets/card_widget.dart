import 'package:flutter/material.dart';
import 'package:tom_chat/core/theme/color.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final double radius;
  final int colorIndex;
  final bool enable;
  final double? width;
  final double? height;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BoxShape shape;
  const CardWidget({
    super.key,
    required this.child,
    required this.radius,
    this.width,
    this.height,
    required this.colorIndex,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.shape = BoxShape.rectangle,
    this.enable = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: !enable
            ? null
            : LinearGradient(
                colors: colors[colorIndex],
                begin: begin,
                end: end,
              ),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
