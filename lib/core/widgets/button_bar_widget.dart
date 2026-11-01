import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonBarWidget extends StatelessWidget {
  final List<ButtonModel> allButtons;
  const ButtonBarWidget({required this.allButtons, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 10).r,
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5).r,
      height: AppBar().preferredSize.height,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allButtons.length,
        primary: false,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ButtonWidget(button: allButtons[index]),
              SizedBox(width: 10.w),
            ],
          );
        },
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final ButtonModel button;
  const ButtonWidget({super.key, required this.button});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: button.onPressed,
      icon: button.icon == null
          ? null
          : Icon(button.icon, color: button.foregroundColor),
      label: Text(
        button.title,
        style: Theme.of(
          context,
        ).textTheme.displaySmall!.copyWith(color: button.foregroundColor),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: button.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: button.borderColor),
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
    );
  }
}

class ButtonModel {
  String title;
  void Function()? onPressed;
  Color backgroundColor;
  Color foregroundColor;
  Color borderColor;
  IconData? icon;
  double? width;

  ButtonModel({
    this.icon,
    required this.title,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.width,
    required this.borderColor,
  });
}
