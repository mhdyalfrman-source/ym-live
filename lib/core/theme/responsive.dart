import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons_plus/ionicons_plus.dart';

class Responsive {
  static Size size(BuildContext context) => MediaQuery.of(context).size;

  static Alignment center(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Alignment.centerLeft
      : Alignment.centerRight;

  static Alignment centerReverse(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Alignment.centerRight
      : Alignment.centerLeft;

  static Alignment top(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Alignment.topLeft
      : Alignment.topRight;

  static Alignment bottom(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Alignment.bottomLeft
      : Alignment.bottomRight;

  static IconData backIcon(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Ionicons.arrow_back
      : Ionicons.arrow_forward;

  static IconData forwardIcon(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en'
      ? Icons.arrow_back_ios_new
      : Icons.arrow_forward_ios;
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
}
