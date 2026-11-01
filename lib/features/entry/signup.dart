import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/dropdown_button.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/entry/components/birthday_picker_widget.dart';
import 'package:tom_chat/features/entry/components/country_picker_widget.dart';
import 'package:tom_chat/features/entry/components/gender_selection_widget.dart';
import 'package:tom_chat/features/entry/controllers/entry_controller.dart';
import 'package:tom_chat/features/entry/login.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      withIcon: false,
      title: "",
      actions: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: PopupMenuWidget(
            mainAxisAlignment: MainAxisAlignment.center,
            iconColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15).r,
            textColor: Colors.black,
            selectedItem: (GetStorage().read("lang") ?? 'ar').toString(),
            onChanged: (v) async {
              // controller.activeLanguageCode.value = v!;
              GetStorage().write("lang", v);
            },
            items: [
              DropdownButtonModel(
                dropName: "AR",
                dropOrder: 0,
                dropAssetImage: "assets/images/icons8-iraq.png",
                dropValue: 'ar',
              ),
              DropdownButtonModel(
                dropName: "EN",
                dropOrder: 1,
                dropAssetImage: "assets/images/icons8-british-flag.png",
                dropValue: 'en',
              ),
            ],
          ),
        ),
      ],
      child: SignUp(),
    );
  }
}

class SignUp extends StatefulWidget {
  final PageController? pageController;
  const SignUp({super.key, this.pageController});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  EntryController controller = Get.find();
  GlobalKey<FormState> signupFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller.userName1Controller.text = StaticValue.userData.name;
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: "",
      child: Form(
        key: signupFormKey,
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: information(context),
        ),
      ),
    );
  }

  Widget information(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppLogo(width: 80.w),
          SizedBox(height: 15),
          loginChildren(context),
        ],
      ),
    );
  }

  Widget loginChildren(BuildContext context) {
    return CardWidget(
      colorIndex: 1,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Column(
          spacing: 12.h,
          children: [
            SizedBox(),
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
                        border: Border.all(color: Colors.white, width: 3.r),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: Offset(0, 1),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            (StaticValue.userData.avatar?.network ?? "") != ""
                            ? Image.network(
                                StaticValue.userData.avatar!.network!,
                                fit: BoxFit.cover,
                              )
                            : Obx(() {
                                return Image.file(
                                  controller.image.value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          Ionicons.person,
                                          size: 50.r,
                                          color: Colors.white54,
                                        ),
                                      ),
                                );
                              }),
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
                            color: Theme.of(context).colorScheme.secondary,
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
            if (!Platform.isIOS)
              InputField(
                maxLength: 100,
                isRequired: false,
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

            BirthdayPickerWidget(
              onChanged: (d, m, y) {
                controller.birthDay = d;
                controller.birthMonth = m;
                controller.birthYear = y;
              },
            ),
            GenderSelectionWidget(
              gender: controller.gender,
              onChanged: (key) {
                controller.gender.value = key;
              },
            ),

            CountryPickerWidget(
              onSelected: (country) {
                controller.selectedCountry.value = country.countryCode;
              },
            ),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: GeneralButton(
                  onPressed: controller.isGoogleLoading.value
                      ? null
                      : () async {
                          if (signupFormKey.currentState!.validate()) {
                            await controller.onCompleteAccount();
                          }
                        },
                  title: context.l10n.save,
                ),
              );
            }),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
