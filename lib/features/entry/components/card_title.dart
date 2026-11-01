import 'package:flutter/material.dart';

class CardTitle extends StatelessWidget {
  const CardTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
        color: Theme.of(context).dividerColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CardTitle2 extends StatelessWidget {
  const CardTitle2({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).dividerColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
