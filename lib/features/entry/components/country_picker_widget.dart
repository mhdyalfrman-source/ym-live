import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:tom_chat/core/widgets/lable.dart';
import 'package:tom_chat/l10n/l10n.dart';

class CountryPickerWidget extends StatefulWidget {
  final Function(Country country) onSelected;
  final String? selectedCountry;

  const CountryPickerWidget({
    super.key,
    required this.onSelected,
    this.selectedCountry,
  });

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  Country? selectedCountry;
  @override
  void initState() {
    super.initState();
    if (widget.selectedCountry != null) {
      selectedCountry = CountryService().findByCode(widget.selectedCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LableWidget(color: Colors.white70, text: context.l10n.country),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              exclude: ["IL"],

              countryListTheme: CountryListThemeData(
                textStyle: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
                inputDecoration: InputDecoration(
                  hintText: context.l10n.search,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  hintStyle: Theme.of(context).textTheme.labelMedium,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country;
                });
                widget.onSelected(country);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                selectedCountry == null
                    ? const Icon(Icons.flag_outlined, color: Colors.grey)
                    : Text(
                        selectedCountry!.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCountry?.name ?? context.l10n.selectCountry,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedCountry == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
