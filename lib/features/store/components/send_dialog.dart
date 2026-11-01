import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/store/controllers/store_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

showSendDialog(context, StoreController controller, bool fromBackpack) {
  TextEditingController textController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25).r,
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.userID,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              InputField(
                isRequired: false,
                withEnterText: false,
                keyboardType: TextInputType.number,
                controller: textController,
                hint: context.l10n.userID,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: GeneralButton(
                      onPressed: () async {
                        int id = MyMath.toInt(textController.text);
                        if (id == 0) {
                          snakbarDialog(
                            title: context.l10n.wrongId,
                            durationSecound: 5,
                          );
                          return;
                        }
                        Get.back();
                        if (fromBackpack) {
                          controller.sendItem(
                            controller.backPackItems[controller
                                .selectedBackpackItem
                                .value],
                            id,
                          );
                        } else {
                          controller.buyItem(
                            controller.items[controller.selectedItem.value],
                            id,
                          );
                        }
                      },
                      colorIndex: 1,
                      title: context.l10n.send,
                    ),
                  ),
                  Expanded(
                    child: GeneralButton(
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
