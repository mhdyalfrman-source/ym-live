// ignore_for_file: must_be_immutable

import 'package:tom_chat/core/widgets/lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/date_picker.dart';

class DateWidget extends StatelessWidget {
  final String dateTitle;
  final String timeTitle;
  final DateWidgetType type;
  DateTime date;
  Duration? duration;
  final Function(DateTime)? onDateChange;
  DateWidget({
    super.key,
    required this.dateTitle,
    this.type = DateWidgetType.DATE_AND_TIME,
    required this.date,
    this.onDateChange,
    required this.timeTitle,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (type == DateWidgetType.DATE_AND_TIME || type == DateWidgetType.DATE)
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dateTitle != "") ...[LableWidget(text: dateTitle)],
                GestureDetector(
                  onTap: onDateChange != null
                      ? () async {
                          DateTime newDate = await selectDate(
                            date: date,
                            context: context,
                            firesDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              duration ?? Duration(seconds: 1),
                            ),
                          );
                          date = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            date.hour,
                            date.minute,
                          );
                          onDateChange!(date);
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10).r,
                    // margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/date.svg",
                          width: 25.r,
                          height: 25.r,
                          colorFilter: ColorFilter.mode(
                            AppColors.gray100,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(date),
                            style: Theme.of(context).textTheme.displaySmall!
                                .copyWith(fontFamily: "cairo"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 5),
        if (type == DateWidgetType.DATE_AND_TIME || type == DateWidgetType.TIME)
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (timeTitle != "") LableWidget(text: timeTitle),
                GestureDetector(
                  onTap: onDateChange != null
                      ? () async {
                          final newDate = await selectTime(
                            context,
                            TimeOfDay(hour: date.hour, minute: date.minute),
                          );
                          date = DateTime.parse(
                            "${DateFormat('yyyy-MM-dd').format(date)} ${newDate.hour < 10 ? "0" : ""}${newDate.hour}:${newDate.minute < 10 ? "0" : ""}${newDate.minute}",
                          );
                          onDateChange!(date);
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10).r,
                    // margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/svgs/time.svg",
                          width: 25.r,
                          height: 25.r,
                          colorFilter: ColorFilter.mode(
                            AppColors.gray100,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat('hh:mm a').format(date),
                            style: Theme.of(context).textTheme.displaySmall!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

enum DateWidgetType { DATE_AND_TIME, DATE, TIME }
