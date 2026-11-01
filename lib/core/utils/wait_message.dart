import 'dart:async';

import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/core/widgets/card_widget.dart';

waitMessage([int messageTime = 20]) {
  GeneralController controller = Get.find();

  if (controller.currentDialog != "WAIT") {
    int i = 1;
    Timer.periodic(Duration(seconds: 1), (t) {
      if (i >= messageTime) {
        t.cancel();
        if (controller.currentDialog == "WAIT") {
          Get.back();
          controller.currentDialog = "";
        }
      }
      if (controller.currentDialog != "WAIT") {
        t.cancel();
      }
      i++;
    });
    opendDialogWithName(
      name: "WAIT",
      context: Get.context!,

      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      useSafeArea: false,
      useRootNavigator: true,

      builder: (context) {
        return Center(
          child: SizedBox(
            width: 40.r,
            height: 40.r,
            child: CardWidget(
              colorIndex: 1,
              radius: 5.r,
              child: Center(
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 15.r,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
