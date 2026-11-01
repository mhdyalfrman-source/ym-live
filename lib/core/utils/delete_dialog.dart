import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';

Future deleteMessage({
  required String title,
  required String? content,
  required Function() onDelete,
  required Function() onCancel,
  required bool onWillPop,
  String resonText = "",
  String deleteButton = "Delete",
  String cancelButton = "Cancel",
  Color? color = AppColors.red,
}) async {
  return await Get.defaultDialog<bool>(
    titleStyle: Theme.of(Get.overlayContext!).textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      // color: Colors.black
    ),
    title: title,
    titlePadding: const EdgeInsets.only(top: 30),
    contentPadding: EdgeInsets.zero,
    custom: SizedBox(),
    // onCancel: ()=>Get.back(result:false),
    onWillPop: () async => onWillPop,

    // onConfirm:()async {
    //   Get.back(result:true);
    // } ,
    actions: [
      Column(
        children: [
          Divider(height: 0),
          SizedBox(
            height: 50.h,
            width: 600.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDelete,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        deleteButton,
                        maxLines: 1,
                        style: Theme.of(Get.context!).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                VerticalDivider(width: 2),
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cancelButton,
                        maxLines: 1,
                        style: Theme.of(Get.context!).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
    radius: 20,
    onCustom: () {},
    content: Column(
      children: [
        if ((content ?? "") != "")
          Text(
            content!,
            textAlign: TextAlign.center,
            style: Theme.of(Get.overlayContext!).textTheme.titleMedium!
                .copyWith(
                  // color: Colors.black
                ),
          ),

        // SizedBox(
        //   width: double.infinity,
        //   child: GeneralButton(
        //     padding: EdgeInsets.all(15).r,
        //     color: color,
        //     onPressed: () async {
        //       await onDelete();
        //     }, title: deleteButton!),
        // ),
        // const SizedBox(height: 10,),
        // SizedBox(
        //   width: double.infinity,
        //   child: GeneralButton2(
        //     padding: EdgeInsets.all(15).r,
        //     color: Theme.of(Get.overlayContext!).textTheme.headlineLarge!.color,
        //     onPressed:() {
        //         onCancel();
        //       }, title: "ignore".tr()),
        // )
      ],
    ),
    backgroundColor: Theme.of(
      Get.overlayContext!,
    ).scaffoldBackgroundColor, //cardColor
  );
}
