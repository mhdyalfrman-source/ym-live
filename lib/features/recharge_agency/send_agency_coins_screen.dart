import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class SendAgencyCoinsScreen extends StatelessWidget {
  final RechargeAgencyController controller;

  const SendAgencyCoinsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: !controller.busy.value,
      child: PageTemplete(
        title: context.l10n.agencySendCoinsTitle,
        child: Form(
          key: controller.transferForm,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.failed.value)
                Text(context.l10n.agencyOperationFailed),
              CardWidget(
                radius: 15.r, 
                colorIndex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0).r,
                  child: Column(
                    children: [
                      for (final field in [
                        (controller.recipient, context.l10n.userID),
                        (controller.coins, context.l10n.agencyCoinAmount),
                      ]) ...[
                        InputField(
                          isRequired: true,
                          isNumber: true,
                          keyboardType: TextInputType.number,
                          controller: field.$1,
                          enabled: !controller.busy.value,
                          aboveLabel: field.$2,
                          maxLength: 15,
                          validator: (value) =>
                              controller.isPositiveInteger(value ?? '')
                              ? null
                              : context.l10n.agencyPositiveInteger,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ), 
              ),
              SizedBox(height: 10.h,),
              GeneralButton(
                title: context.l10n.send,
                colorIndex: 1,
                onPressed: controller.busy.value
                    ? null
                    : () async {
                        if (controller.transferForm.currentState?.validate() !=
                            true) {
                          return;
                        }
                        if (await controller.sendCoins() && context.mounted) {
                          Get.back(result: true);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
