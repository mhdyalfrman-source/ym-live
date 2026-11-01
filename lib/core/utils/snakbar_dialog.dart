import 'package:tom_chat/core/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/l10n/l10n.dart';

Future snakbarDialog({
  required String title,
  required int durationSecound,
  Color color = AppColors.red,
  Icon? icon,
  TextButton? mainButton,
}) async {
  icon ??= Icon(
    color == AppColors.red ? Icons.cancel_rounded : Icons.check,
    color: Colors.white,
    size: 30,
  );
  try {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.snackbar(
      "",
      "",
      isDismissible: true,
      messageText: SizedBox(),
      // messageText: Text(
      //     content,
      //     style: Theme.of(Get.overlayContext!)
      //         .textTheme
      //         .displaySmall!
      //         .copyWith(color: Colors.white)),
      titleText: Text(
        title,
        style: Theme.of(Get.overlayContext!).textTheme.displaySmall!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.start,
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      duration: Duration(seconds: durationSecound),
      maxWidth: 500,
      icon: IconButton(onPressed: Get.closeCurrentSnackbar, icon: icon),
      // margin: const EdgeInsets.only(bottom: 100)
    );
  } catch (e) {}
}

Future done({String? message, int duration = 3}) async {
  snakbarDialog(
    title: message ?? Get.context!.l10n.theOperatorIsDoneSeccessfuly,
    durationSecound: duration,
    color: AppColors.primaryDark,
    icon: Icon(Icons.check_circle, color: Colors.white, size: 30),
  );
}

Future error() async {
  await snakbarDialog(
    title: Get.context!.l10n.errorOcoredPleaseTryAgain,
    durationSecound: 5,
    icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 30),
  );
}

// deleteDialog({required BuildContext context,required String title,required String description,required IconData icon,required Function deleteEvent}) {
//   AwesomeDialog(
//     context: context,
//     animType: AnimType.leftSlide,
//     headerAnimationLoop: false,
//     dialogType: DialogType.question,
//     showCloseIcon: true,
//     title: title,
//     titleTextStyle: Theme.of(context).textTheme.displayLarge!.copyWith(color: Colors.black),
//     descTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.black),
//     btnOkColor: redColor,
//     btnCancelColor: headColor,
//     customHeader: FittedBox(
//       child: Icon(
//         icon,
//         color: headColor,
//         size: 150,
//       ),
//     ),
//     btnOkText: "delete".tr(),
//     btnCancelText: "cancel".tr(),
//     desc:
//         '$description',
//     btnOkOnPress: () {
//       deleteEvent();
//     },
//     btnCancelOnPress: (){
//     },
//     // btnOkIcon: Icons.check_circle,
//     onDismissCallback: (type) {
//     },
//     dialogBackgroundColor: Colors.white
//   ).show();
// }
