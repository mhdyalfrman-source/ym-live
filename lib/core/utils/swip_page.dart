import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/core/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

Future openDialogOrBottomSheet(widget) async {
  return await showModalBottomSheet(
    context: Get.context!,
    builder: (context) {
      return widget;
    },
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Future openDialogOrNewRoute(widget, [bool canPop = false]) async {
  if (Responsive.isDesktop(Get.context!)) {
    return await showDialog(
      context: Get.context!,
      builder: (context) {
        return PopScope(
          canPop: canPop,
          // onWillPop: () async => false,
          child: Dialog(child: widget),
        );
      },
    );
  } else {
    return await swipToPage(Get.context!, widget);
    // to back to last open page
  }
}

swipToPage(BuildContext context, Widget page) async {
  final routeName = '/${page.runtimeType}';
  GeneralController controller = Get.find();
  if (controller.currentDialog == "WAIT") {
    Get.back();
    controller.currentDialog = '${page.runtimeType}';
  }
  return await Get.to(
    () => page,
    transition: Transition.cupertino,
    routeName: routeName,
    preventDuplicates: false,
  );
}

swipReplacementPage(BuildContext context, Widget page) async {
  final routeName = '/${page.runtimeType}';
  GeneralController controller = Get.find();
  if (controller.currentDialog == "WAIT") {
    Get.back();
    controller.currentDialog = '${page.runtimeType}';
  }
  return await Get.off(
    () => page,
    transition: Transition.cupertino,
    routeName: routeName,
    preventDuplicates: false,
  );
}

animatedMovePageView(PageController pageController, index) async {
  await pageController.animateToPage(
    index,
    duration: Duration(milliseconds: 200),
    curve: Easing.standard,
  );
}

Future openDialog(BuildContext context, widget, [bool canPop = false]) async {
  showDialog(
    context: context,
    builder: (context) {
      return PopScope(
        canPop: canPop,
        // onWillPop: () async => false,
        child: Dialog(child: widget),
      );
    },
  );
}

Future openBottomSheet(context, widget) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return widget;
    },
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Future opendDialogWithName({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  required String name,

  bool barrierDismissible = false,
  Color? barrierColor,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) async {
  GeneralController controller = Get.find();
  controller.currentDialog = name;

  return await showDialog(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  ).whenComplete(() {
    controller.currentDialog = "";
  });
}
