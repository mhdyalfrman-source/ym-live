import 'package:flutter/material.dart';

class MyPopupMenuItem extends StatelessWidget {
  final String text;
  final IconData icon;
  const MyPopupMenuItem({required this.text, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(icon),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
