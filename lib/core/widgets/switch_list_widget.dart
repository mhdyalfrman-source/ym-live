import 'package:flutter/material.dart';

class SwitchListTileWidget extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final String title;
  final String? subTitle;

  const SwitchListTileWidget({
    required this.title,
    this.subTitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Theme.of(context).scaffoldBackgroundColor, //cardColor
      child: SwitchListTile(
        contentPadding: const EdgeInsets.all(10),
        activeColor: Theme.of(context).primaryColor,
        activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
        // inactiveTrackColor: Colors.grey,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.displaySmall!),
        ),
        subtitle: subTitle != null
            ? Text(
                subTitle!,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w200),
              )
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
