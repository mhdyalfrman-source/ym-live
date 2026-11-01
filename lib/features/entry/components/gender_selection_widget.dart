import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/lable.dart';
import 'package:tom_chat/l10n/l10n.dart';

class GenderSelectionWidget extends StatefulWidget {
  final Function(String) onChanged;
  final RxString gender;

  const GenderSelectionWidget({
    super.key,
    required this.onChanged,
    required this.gender,
  });

  @override
  State<GenderSelectionWidget> createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LableWidget(color: Colors.white70, text: context.l10n.type),
        Row(
          children: [
            Expanded(child: _genderCard("male", Icons.male, context.l10n.male)),
            SizedBox(width: 10.w),
            Expanded(
              child: _genderCard("female", Icons.female, context.l10n.fmale),
            ),
          ],
        ),
      ],
    );
  }

  Widget _genderCard(String key, IconData icon, String label) {
    return Obx(() {
      return GestureDetector(
        onTap: () {
          widget.onChanged(key);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.gender.value == key
                  ? AppColors.primaryDark
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.gender.value == key
                    ? AppColors.primaryDark
                    : Colors.grey.shade200,
                child: Icon(
                  icon,
                  color: widget.gender.value == key
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Text(label),
              const Spacer(),
              Icon(
                widget.gender.value == key
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: widget.gender.value == key
                    ? AppColors.primaryDark
                    : Colors.grey,
              ),
            ],
          ),
        ),
      );
    });
  }
}
