import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
    required this.isHorizontal,
  });

  final bool isActive;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(bottom: 2),
      duration: const Duration(milliseconds: 200),
      width: isHorizontal ? (isActive ? 20 : 0) : 4,
      height: !isHorizontal ? (isActive ? 20 : 0) : 4,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
