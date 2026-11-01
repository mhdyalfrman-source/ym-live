// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:showcaseview/showcaseview.dart';

// class ShowcaseWidget extends StatelessWidget {
//   final GlobalKey stepKey;
//   final String? title;
//   final String? description;
//   final BorderRadius? targetBorderRadius;
//   final Widget child;
//   const ShowcaseWidget({super.key, required this.stepKey, this.title, this.description, required this.child, this.targetBorderRadius});

//   @override
//   Widget build(BuildContext context) {
//     return Showcase(
//       tooltipBackgroundColor: Theme.of(context).cardColor,
//       targetBorderRadius: targetBorderRadius,
//       descriptionPadding: EdgeInsets.all(5).r,
//       titleTextStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
//         color: Theme.of(context).primaryColor,
//         fontWeight: FontWeight.bold
//       ),
//       descTextStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
//       ),
//       key: stepKey,
//       title: title,
//       description: description,
//       child: child
//     );
//   }
// }
