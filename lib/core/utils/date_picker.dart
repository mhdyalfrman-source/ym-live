import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

Future<List<DateTime>?> selectFromToDate({
  required BuildContext context,
  required DateTime firesDate,
  required DateTime lastDate,
  OmniDateTimePickerType type = OmniDateTimePickerType.dateAndTime,
}) async {
  List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
    context: context,
    startInitialDate: firesDate,
    startFirstDate: DateTime(2023),
    startLastDate: DateTime.now().add(const Duration(days: 3652)),
    endInitialDate: lastDate,
    endFirstDate: DateTime(2024),
    endLastDate: DateTime.now().add(const Duration(days: 3652)),
    is24HourMode: false,
    isShowSeconds: false,
    minutesInterval: 1,
    secondsInterval: 1,
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    // constraints: BoxConstraints(
    //   maxWidth: Responsive.isMobile(context)? double.infinity : 350,
    //   maxHeight: 650,
    // ),
    type: type,
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1.drive(Tween(begin: 0, end: 1)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    // selectableDayPredicate: (dateTime) {
    //   // Disable 25th Feb 2023
    //   if (dateTime == DateTime(2023, 2, 25)) {
    //     return false;
    //   } else {
    //     return true;
    //   }
    // },
  );
  return dateTimeList;
}

Future<DateTime> selectDate({
  required DateTime date,
  required BuildContext context,
  required DateTime firesDate,
  required DateTime lastDate,
}) async {
  try {
    DateTime selectedDate = date;
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firesDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (selected != null && selected != date) {
      selectedDate = selected;
    }
    return selectedDate;
  } catch (e) {
    return DateTime.now();
  }
}

Future<TimeOfDay> selectTime(
  BuildContext context,
  TimeOfDay selectedTime,
) async {
  try {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (selected != null && selected != selectedTime) {
      selectedTime = selected;
    }
    return selectedTime;
  } catch (e) {
    return TimeOfDay.now();
  }
}
