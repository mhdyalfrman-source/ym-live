import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.only(top: 100, bottom: 80, left: 20, right: 20).r,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50).r,
        ),
        surfaceTintColor: Theme.of(context).primaryColorLight,
        color: Theme.of(context).primaryColorLight,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(
            25,
          ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom).r,
          child: child,
        ),
      ),
    );
  }
}
