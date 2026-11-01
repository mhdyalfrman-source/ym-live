import 'package:flutter/material.dart';
import 'package:tom_chat/core/widgets/lable.dart';
import 'package:tom_chat/l10n/l10n.dart';

class BirthdayPickerWidget extends StatefulWidget {
  final Function(int? day, int? month, int? year) onChanged;

  const BirthdayPickerWidget({super.key, required this.onChanged});

  @override
  State<BirthdayPickerWidget> createState() => _BirthdayPickerWidgetState();
}

class _BirthdayPickerWidgetState extends State<BirthdayPickerWidget> {
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  bool isDateValid = true;

  List<int> days = List.generate(31, (i) => i + 1);
  List<int> months = List.generate(12, (i) => i + 1);
  List<int> years = List.generate(
    100,
    (i) => DateTime.now().year - i,
  ); // آخر 100 سنة

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LableWidget(color: Colors.white70, text: context.l10n.birthday),
        Row(
          children: [
            Expanded(
              child: _buildPicker(days, context.l10n.day, (v) {
                selectedDay = v;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPicker(months, context.l10n.month, (v) {
                selectedMonth = v;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPicker(years, context.l10n.year, (v) {
                selectedYear = v;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPicker(List<int> items, String hint, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      iconEnabledColor: Colors.white,
      hint: Text(hint),
      items: items
          .map((v) => DropdownMenuItem(value: v, child: Text(v.toString())))
          .toList(),
      onChanged: (v) {
        setState(() {
          onChanged(v);
          widget.onChanged(selectedDay, selectedMonth, selectedYear);
        });
      },
    );
  }
}
