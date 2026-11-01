import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/core/theme/color.dart';

class PageTemplete extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final String? subtitle;
  final Color? backgroundColor;
  final bool withIcon;
  final bool centerTitle;
  final bool withSafeArea;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final Function()? onBack;
  const PageTemplete({
    super.key,
    required this.title,
    required this.child,
    this.withIcon = true,
    this.centerTitle = true,
    this.withSafeArea = true,
    this.actions = const [],
    this.bottom,
    this.subtitle,
    this.backgroundColor,
    this.onBack,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xfff1d5d0), Colors.white, Colors.white, Colors.white],
          begin: AlignmentGeometry.topRight,
          end: AlignmentGeometry.bottomLeft,
        ),
      ),
      child: SafeArea(
        bottom: withSafeArea,
        top: withSafeArea,
        child: Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          backgroundColor: Colors.transparent,
          appBar: (title == "")
              ? null
              : AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarIconBrightness: GetStorage().read("darkMode")
                        ? Brightness.light
                        : Brightness.dark, // For Android (dark icons)
                    statusBarBrightness: GetStorage().read("darkMode")
                        ? Brightness.dark
                        : Brightness.light, // For iOS (dark icons)
                  ),
                  forceMaterialTransparency: true,
                  actions: actions,
                  bottom: bottom,
                  leading: !withIcon
                      ? null
                      : IconButton(
                          onPressed: onBack ?? Get.back,
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20.r,
                            color: Colors.black,
                          ),
                        ),
                  title: Padding(
                    padding: EdgeInsets.all(10).r,
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 5.h),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.displaySmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  elevation: 0,
                  // forceMaterialTransparency: true,
                  centerTitle: centerTitle,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                ),
          body: Column(children: [Expanded(child: child)]),
        ),
      ),
    );
  }
}
