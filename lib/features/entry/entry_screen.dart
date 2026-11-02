import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/theme/color.dart' show colors;
import 'package:tom_chat/core/widgets/input_field.dart';

import 'package:tom_chat/features/entry/controllers/entry_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EntryScreen extends StatefulWidget {
  final UserModel? userByDevice;
  final int initialPage;
  const EntryScreen({super.key, this.userByDevice, this.initialPage = 1});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late EntryController controller;
  int pageIndex = 0;
  @override
  void initState() {
    pageIndex = widget.initialPage;
    controller = Get.put(EntryController());
    super.initState();
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_flash_bg.gif',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              height: Get.height * 0.2,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SizedBox(
                  //   width: Get.width * 0.7,
                  //   child: GestureDetector(
                  //     onTap: ()async{
                  //       await controller.onSignInWithGoogle();
                  //     },
                  //     child: signupButton(context,"assets/svgs/google.svg",context.l10n.google,0)
                  //   ),
                  // ),
                  // Spacer(),
                  // BlurConsentBox(
                  //   height: 70,
                  //   blurSigma: 8,
                  //   overlayColor: Colors.black.withOpacity(0.35),
                  //   initialValue: controller.policyRead.value,
                  //   onChanged: (checked) {
                  //     controller.policyRead.value = checked;
                  //   },
                  //   onPolicyTap: () {

                  //   },
                  // ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              left: 10,
              right: 10,
              child: Form(
                key: formKey,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: EdgeInsets.all(10).r,
                          margin: EdgeInsets.all(15).r,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10.h),
                              Text(
                                context.l10n.login,
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 20.h),
                              InputField(
                                maxLength: 100,
                                isRequired: true,
                                prefix: Icon(Ionicons.person_outline),
                                keyboardType: TextInputType.number,
                                controller: controller.userId,
                                // hint: "emailAddressOrPhoneNumber",
                                hint: context.l10n.userID,
                                aboveLabel: context.l10n.userID,
                              ),
                              SizedBox(height: 10.h),
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
                              SizedBox(height: 20.h),
                              SizedBox(
                                width: Get.width * 0.7,
                                height: 45.h,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (formKey.currentState!.validate()) {
                                      await controller.onSignInWithId();
                                    }
                                  },
                                  child: signupButton(
                                    context,
                                    "",
                                    context.l10n.login,
                                    0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              SizedBox(
                                width: Get.width * 0.7,
                                child: GestureDetector(
                                  onTap: () async {
                                    await controller.onSignInWithGoogle();
                                  },
                                  child: signupButton(
                                    context,
                                    "assets/svgs/google.svg",
                                    context.l10n.google,
                                    0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              BlurConsentBox(
                                height: 70,
                                blurSigma: 8,
                                overlayColor: Colors.black.withOpacity(0.35),
                                initialValue: controller.policyRead.value,
                                onChanged: (checked) {
                                  controller.policyRead.value = checked;
                                },
                                onPolicyTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container signupButton(
  BuildContext context,
  String image,
  String title,
  int index,
) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10).r,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(30).r,
      gradient: LinearGradient(
        colors: colors[1],
        begin: index == 0
            ? AlignmentGeometry.centerLeft
            : AlignmentGeometry.centerRight,
        end: index == 0
            ? AlignmentGeometry.centerRight
            : AlignmentGeometry.centerLeft,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8.w),
        if (image.isNotEmpty)
          SvgPicture.asset(
            image,
            width: 35.r,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        SizedBox(width: 5.w),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 5.w),
      ],
    ),
  );
}

class BlurConsentBox extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onPolicyTap;
  final double width;
  final double height;
  final double borderRadius;
  final double blurSigma;
  final Color overlayColor;
  final EdgeInsets padding;

  const BlurConsentBox({
    super.key,
    this.initialValue = false,
    this.onChanged,
    this.onPolicyTap,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 12,
    this.blurSigma = 6.0,
    this.overlayColor = const Color.fromRGBO(255, 255, 255, 0.15),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  State<BlurConsentBox> createState() => _BlurConsentBoxState();
}

class _BlurConsentBoxState extends State<BlurConsentBox> {
  late bool _checked;
  late TapGestureRecognizer _policyRecognizer;

  @override
  void initState() {
    super.initState();
    _checked = widget.initialValue;
    _policyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.onPolicyTap != null) widget.onPolicyTap!();
        launchUrl(
          Uri.parse("http://104.207.90.135/yaumi/privacy_policy.html"),
          mode: LaunchMode.inAppWebView,
        );
      };
  }

  @override
  void dispose() {
    _policyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we respect RTL for Arabic
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            // padding: widget.padding,
            decoration: BoxDecoration(
              // color: widget.overlayColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Checkbox(
                    value: _checked,
                    onChanged: (v) {
                      setState(() => _checked = v ?? false);
                      if (widget.onChanged != null) widget.onChanged!(_checked);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Text with tappable "سياسة الاستخدام"
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: context.l10n.readPolcy,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: context.l10n.policy,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                          recognizer: _policyRecognizer,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
