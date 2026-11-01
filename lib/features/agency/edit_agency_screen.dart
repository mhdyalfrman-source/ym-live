import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/agency/controllers/agency_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';

class EditAgencyScreen extends StatefulWidget {
  final AgencyController controller;
  const EditAgencyScreen({super.key, required this.controller});

  @override
  State<EditAgencyScreen> createState() => _EditAgencyScreenState();
}

class _EditAgencyScreenState extends State<EditAgencyScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    widget.controller.loading.value = false;
    widget.controller.agencyNameController.text =
        widget.controller.agency.value?.name ?? "";
    widget.controller.noteCotroller.text =
        widget.controller.agency.value?.notice ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.editInfo,
      child: Obx(() {
        if (widget.controller.loading.value ||
            widget.controller.agency.value == null) {
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
                                    child:
                                        widget.controller.image.value.path != ""
                                        ? Image.file(
                                            widget.controller.image.value,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                                      child: Icon(
                                                        Ionicons.person,
                                                        size: 50.r,
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                          )
                                        : AppImage(
                                            image: widget
                                                .controller
                                                .agency
                                                .value!
                                                .icon,
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
                                          widget.controller.image.value = File(
                                            path,
                                          );
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
                            controller: widget.controller.agencyNameController,
                            // hint: "emailAddressOrPhoneNumber",
                            hint: context.l10n.agencyName,
                            aboveLabel: context.l10n.agencyName,
                            validator: (v) {
                              if ((v?.length ?? 0) < 4) {
                                return context.l10n.nameMustBeMoreThan3;
                              }
                              return null;
                            },
                          ),

                          // BirthdayPickerWidget(
                          //   onChanged: (d, m, y) {
                          //     widget.controller.birthDay = d;
                          //     widget.controller.birthMonth = m;
                          //     widget.controller.birthYear = y;
                          //   },
                          // ),
                          InputField(
                            maxLength: 300,
                            maxLines: 4,
                            isRequired: true,
                            prefix: Icon(Ionicons.pencil),
                            keyboardType: TextInputType.text,
                            controller: widget.controller.noteCotroller,
                            // hint: "emailAddressOrPhoneNumber",
                            hint: context.l10n.notics,
                            aboveLabel: context.l10n.notics,
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
                  onPressed: widget.controller.updateLoading.value
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            await widget.controller.onEditAgency();
                          }
                        },
                  title: context.l10n.save,
                ),
              ),
              SizedBox(),
            ],
          ),
        );
      }),
    );
  }
}
