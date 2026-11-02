import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/helpers/secure_storage.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/controllers/profile_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  List<StoredUser> accounts = [];
  ProfileController controller = Get.put(
    ProfileController(StaticValue.userData.userId),
    tag: StaticValue.userData.userId.toString(),
  );
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.changePassword,
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10).r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardWidget(
                colorIndex: 1,
                radius: 15.r,
                child: Padding(
                  padding: EdgeInsets.all(10).r,
                  child: Column(
                    spacing: 15.h,
                    children: [
                      InputField(
                        maxLength: 100,
                        isRequired: true,
                        obscureText: !controller.showPassword.value,
                        prefix: Icon(
                          Ionicons.lock_closed_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        suffix: IconButton(
                          onPressed: () {
                            controller.showPassword.value =
                                !controller.showPassword.value;
                          },
                          icon: Icon(
                            controller.showPassword.value
                                ? Ionicons.eye
                                : Ionicons.eye_off,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        controller: controller.userPassword,
                        // hint: "emailAddressOrPhoneNumber",
                        hint: context.l10n.password,
                        aboveLabel: context.l10n.password,
                      ),
                      InputField(
                        maxLength: 100,
                        isRequired: true,
                        obscureText: !controller.showPassword2.value,
                        prefix: Icon(
                          Ionicons.lock_closed_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        suffix: IconButton(
                          onPressed: () {
                            controller.showPassword2.value =
                                !controller.showPassword2.value;
                          },
                          icon: Icon(
                            controller.showPassword2.value
                                ? Ionicons.eye
                                : Ionicons.eye_off,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        controller: controller.userPassword2,
                        hint: context.l10n.repeatedPassword,
                        aboveLabel: context.l10n.repeatedPassword,
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: GeneralButton3(
                    color: AppColors.primaryDark,
                    fontColor: Colors.white,
                    onPressed: controller.updateLoading.value
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              await controller.savePassword();
                            }
                          },
                    title: context.l10n.save,
                  ),
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAccountOption(
    BuildContext context, {
    required Widget avatar,
    required Widget trailing,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          avatar,
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
