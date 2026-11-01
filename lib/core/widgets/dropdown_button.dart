import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/l10n/l10n.dart';

class DropdownButtonWidget<T> extends StatelessWidget {
  const DropdownButtonWidget({
    super.key,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.menuMaxHeight,
    this.selectedItem,
    required this.items,
    required this.title,
    this.hint,
  });

  final bool? readOnly;
  final String title;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final double? menuMaxHeight;
  final String? hint;
  final T? selectedItem;
  final List<DropdownButtonModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != "") ...[LableWidget(text: "$title :")],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60),
            // color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15).r,
            // border: Border.all(color: Colors.white70)
          ),
          child: DropdownButton<T>(
            iconEnabledColor: Colors.white70,
            hint: hint != null
                ? Text(
                    "${context.l10n.plsChoose} $hint",
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall!.copyWith(color: Colors.white70),
                  )
                : null,
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e.dropValue,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        e.dropName!,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: readOnly! ? null : onChanged,
            // icon: SizedBox(),
            isExpanded: true,
            underline: SizedBox(),
            onTap: onTap,
            menuMaxHeight: menuMaxHeight,
            value: selectedItem,
            dropdownColor: Theme.of(
              context,
            ).scaffoldBackgroundColor, //cardColor
          ),
        ),
      ],
    );
  }
}

class PopupMenuWidget<T> extends StatelessWidget {
  const PopupMenuWidget({
    super.key,
    this.readOnly = false,
    this.withText = true,
    this.isImage = false,
    this.onChanged,
    this.onTap,
    this.icon,
    this.menuMaxHeight,
    this.selectedItem,
    required this.items,
    this.textColor,
    this.iconColor,
    this.padding = EdgeInsets.zero,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  });

  final bool? readOnly;
  final bool withText;
  final bool isImage;
  final Color? textColor;
  final Color? iconColor;
  final Widget? icon;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final double? menuMaxHeight;
  final EdgeInsets padding;
  final T? selectedItem;
  final List<DropdownButtonModel> items;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return items
            .map(
              (e) => PopupMenuItem<T>(
                value: e.dropValue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.dropName!,
                      style: Theme.of(context).textTheme.displaySmall!,
                    ),
                    if (e.dropAssetImage != null)
                      Image.asset(e.dropAssetImage!, width: 50),
                    if (e.dropNetworkImage != null)
                      CachedImage(
                        e.dropNetworkImage!,
                        width: 50,
                        type: ImageType.general,
                      ),
                  ],
                ),
              ),
            )
            .toList();
      },
      icon: icon,
      iconColor: iconColor,
      color: Theme.of(context).primaryColorLight,
      surfaceTintColor: Theme.of(context).primaryColorLight,
      onOpened: onTap,
      onSelected: onChanged,
      tooltip: "",
      initialValue: selectedItem,
    );
  }
}

class DropdownButtonModel {
  int? dropOrder;
  String? dropName;
  String? dropAssetImage;
  String? dropNetworkImage;
  IconData? dropIcon;
  dynamic dropValue;
  DropdownButtonModel({
    this.dropName,
    this.dropOrder,
    this.dropValue,
    this.dropAssetImage,
    this.dropNetworkImage,
  });
}
