import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/entry/components/country_picker_widget.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/controllers/profile_controller.dart';
import 'package:tom_chat/features/settings/setting_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.put(
    ProfileController(StaticValue.userData.userId),
    tag: StaticValue.userData.userId.toString(),
  );
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    controller.user.value = Get.find<HomeController>().user.value;
    controller.loading.value = false;
    controller.selectedCountry.value = controller.user.value?.country ?? "YE";
    controller.userName1Controller.text = controller.user.value?.name ?? "";
    controller.contentCotroller.text = controller.user.value?.comment ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.editInfo,
      child: Obx(() {
        if (controller.loading.value || controller.user.value == null) {
          return const Center(
            child: CupertinoActivityIndicator(color: AppColors.primaryDark),
          );
        }

        return Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: CardWidget(
                    colorIndex: 1,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(10).r,
                      child: Column(
                        spacing: 8.h,
                        children: [
                          SizedBox(
                            height: 120.r,
                            width: 120.r,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3.r,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: controller.image.value.path != ""
                                          ? Image.file(
                                              controller.image.value,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Center(
                                                    child: Icon(
                                                      Ionicons.person,
                                                      size: 50.r,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                            )
                                          : AppImage(
                                              image: controller
                                                      .user
                                                      .value!
                                                      .avatar,
                                              fit: BoxFit.cover,
                                              errorWidget: Center(
                                                    child: Icon(
                                                      Ionicons.person,
                                                      size: 50.r,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        String path = await openGallery();
                                        if (path != "") {
                                          controller.image.value = File(path);
                                        }
                                      },
                                      icon: Icon(Icons.image_outlined),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InputField(
                            maxLength: 100,
                            isRequired: true,
                            prefix: Icon(Ionicons.person_outline),
                            keyboardType: TextInputType.text,
                            controller: controller.userName1Controller,
                            // hint: "emailAddressOrPhoneNumber",
                            hint: context.l10n.name,
                            aboveLabel: context.l10n.name,
                            validator: (v) {
                              if ((v?.length ?? 0) < 4) {
                                return context.l10n.nameMustBeMoreThan3;
                              }
                              return null;
                            },
                          ),

                          // BirthdayPickerWidget(
                          //   onChanged: (d, m, y) {
                          //     controller.birthDay = d;
                          //     controller.birthMonth = m;
                          //     controller.birthYear = y;
                          //   },
                          // ),
                          CountryPickerWidget(
                            onSelected: (country) {
                              controller.selectedCountry.value =
                                  country.countryCode;
                            },
                            selectedCountry: controller.selectedCountry.value,
                          ),

                          InputField(
                            maxLength: 300,
                            maxLines: 4,
                            isRequired: true,
                            prefix: Icon(Ionicons.pencil),
                            keyboardType: TextInputType.text,
                            controller: controller.contentCotroller,
                            // hint: "emailAddressOrPhoneNumber",
                            hint: context.l10n.state,
                            aboveLabel: context.l10n.state,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: GeneralButton(
                  onPressed: controller.updateLoading.value
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            await controller.onEditAccount();
                          }
                        },
                  title: context.l10n.save,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: GeneralButton(
                  color: AppColors.red,
                  onPressed: controller.updateLoading.value
                      ? null
                      : () async {
                          deleteMessage(
                            deleteButton: context.l10n.delete,
                            cancelButton: context.l10n.cancel,
                            title: context.l10n.deleteAccountMsg,
                            content: context.l10n.deleteAccountDesc,
                            onDelete: () async {
                              await CallServerAPI.post(
                                "auth/deleteAccount",
                                {},
                              );
                              await logout();
                            },
                            onCancel: () {
                              Get.back();
                            },
                            onWillPop: true,
                          );
                        },
                  title: context.l10n.deleteAccount,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }
}
