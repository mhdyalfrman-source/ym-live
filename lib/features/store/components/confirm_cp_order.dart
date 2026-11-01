import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/store/controllers/store_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

showConfirmCPDialog(
  context,
  StoreController controller,
  UserModel user,
  bool isClose,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.all(10).r,
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.orderConfirmation,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              Text(
                isClose
                    ? context.l10n.closeCp(user.name)
                    : context.l10n.sendCpToFriend(
                        controller.items[controller.selectedItem.value].name,
                        user.name,
                      ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GeneralButton(
                      margin: 5,
                      onPressed: () async {
                        Get.back();
                        if (await controller.buyCPItem(
                          controller.items[controller.selectedItem.value],
                          user.userId,
                          false,
                        )) {
                          if (isClose) {
                            StaticValue.userData.cpLover = null;
                            Get.find<HomeController>().user.value.cpLover =
                                null;
                          }
                        }
                      },
                      colorIndex: 1,
                      title: context.l10n.confirm,
                    ),
                  ),
                  Expanded(
                    child: GeneralButton(
                      margin: 5,
                      onPressed: Get.back,
                      colorIndex: 1,
                      title: context.l10n.close,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
