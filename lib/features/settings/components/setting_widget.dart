import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';

class SeetingWidget extends StatelessWidget {
  final IconData? icon;
  final Color? iconBackground;
  final Widget? trailing;
  final String title;
  final String? subtitle;
  final Color? color;
  final double elevation;
  final String image;
  final Function()? onTap;
  const SeetingWidget({
    super.key,
    this.icon,
    this.iconBackground,
    required this.title,
    this.subtitle,
    this.image = "",
    this.onTap,
    this.trailing,
    this.elevation = 0.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).cardColor,
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5).r,
        // visualDensity: VisualDensity.compact,
        onTap: onTap,
        leading: CardWidget(
          shape: BoxShape.circle,
          colorIndex: 1,
          radius: 10,
          // decoration: BoxDecoration(
          //   color: Theme.of(context).cardColor,
          //   shape: BoxShape.circle
          // ),
          child: Padding(
            padding: EdgeInsets.all(8).r,
            child: image == ""
                ? Icon(icon, color: Colors.white, size: 25.r)
                : SvgPicture.asset(
                    image,
                    width: 25.r,
                    height: 25.r,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Colors.black,
            fontFamily: "cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w100,
                ),
              ),
        trailing:
            trailing ??
            Icon(
              Directionality.of(context) == TextDirection.ltr
                  ? Ionicons.chevron_forward_outline
                  : Ionicons.chevron_back_outline,
              color: Theme.of(context).dividerColor,
            ),
      ),
    );
  }
}

// class SeetingWidget extends StatelessWidget {
//   final IconData icon;
//   final Color? iconBackground;
//   final String title;
//   final String? subtitle;
//   final String image;
//   final Function()? onTap;
//   const SeetingWidget({super.key, required this.icon, this.iconBackground, required this.title, this.subtitle, this.image = "", this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         margin: EdgeInsets.zero,
//         color: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0.0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//         child: ListTile(
//           visualDensity: VisualDensity.compact,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           onTap: onTap,
//           leading: image == ""? Icon(
//             icon,
//             size: 28.r,
//             color: Theme.of(context).colorScheme.secondaryContainer,
//           ):Image.asset(image),
//           title: Text(title, style: Theme.of(context).textTheme.displaySmall!.copyWith(
//             color: Theme.of(context).colorScheme.secondaryContainer,fontWeight: FontWeight.bold)),
//           trailing: subtitle == null ? null : Text(subtitle!, style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.secondaryContainer,fontWeight: FontWeight.bold))
//         ),
//       );
//   }
// }

Widget settingItem2({
  IconData? icon,
  Color? iconBackground,
  Color color = Colors.white,
  required String title,
  String? subtitle,
  String image = "",
  double elevation = 0.0,
  Function()? onTap,
}) {
  bool isClick = false;
  return StatefulBuilder(
    builder: (context, setState) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        color: Theme.of(context).primaryColorLight,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            vertical: subtitle == null ? 10 : 4,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: onTap == null || isClick
              ? null
              : () async {
                  setState(() {
                    isClick = true;
                  });
                  await onTap();
                  setState(() {
                    isClick = false;
                  });
                },
          trailing: onTap != null
              ? Icon(
                  Directionality.of(context) == TextDirection.ltr
                      ? Ionicons.chevron_forward_outline
                      : Ionicons.chevron_back_outline,
                )
              : null,
          leading: SizedBox(
            width: 45,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: iconBackground,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: image == ""
                    ? Icon(icon, color: color)
                    : SvgPicture.asset(
                        image,
                        height: 20,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
              ),
            ),
          ),
          title: Text(title, style: Theme.of(context).textTheme.displaySmall),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
        ),
      );
    },
  );
}
