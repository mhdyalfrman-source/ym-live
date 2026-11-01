import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/dropdown_button.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  late WalletController controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller = Get.put(WalletController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      resizeToAvoidBottomInset: false,
      title: context.l10n.add_account,
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(10).r,
              child: CardWidget(
                radius: 10.r,
                colorIndex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 15.h),
                      Obx(() {
                        return DropdownButtonWidget(
                          title: context.l10n.type,
                          hint: context.l10n.type,
                          selectedItem: controller.accountTypeId.value,
                          items: controller.cashData.value!.paymentTypes!.map((
                            v,
                          ) {
                            return DropdownButtonModel(
                              dropName: v.name,
                              dropNetworkImage: v.icon,
                              dropOrder: 0,
                              dropValue: v.id,
                            );
                          }).toList(),
                          onChanged: (v) {
                            controller.accountTypeId.value = MyMath.toInt(v);
                          },
                        );
                      }),
                      SizedBox(height: 15.h),
                      InputField(
                        keyboardType: TextInputType.text,
                        isRequired: true,
                        aboveLabel: context.l10n.name,
                        controller: controller.accountName,
                        hint: context.l10n.name,
                      ),
                      SizedBox(height: 15.h),
                      InputField(
                        keyboardType: TextInputType.text,
                        isRequired: true,
                        aboveLabel: context.l10n.accountNumber,
                        controller: controller.accountNumber,
                        hint: context.l10n.accountNumber,
                      ),
                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: GeneralButton3(
              color: AppColors.primaryDark,
              fontColor: Colors.white,
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await controller.saveAccount();
                }
              },
              title: context.l10n.save,
            ),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}
