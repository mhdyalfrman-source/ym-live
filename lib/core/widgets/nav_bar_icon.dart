import 'package:flutter/material.dart';

class NavBarIcon extends StatelessWidget {
  final String? tooltip;
  final IconData icon;
  final void Function()? iconEvent;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? shadowColor;
  const NavBarIcon({
    super.key,
    this.tooltip,
    required this.icon,
    this.iconEvent,
    required this.backgroundColor,
    required this.foregroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        boxShadow: shadowColor == null
            ? null
            : [
                BoxShadow(
                  color: shadowColor!.withOpacity(0.5),
                  // offset: Offset(1,-1),
                  spreadRadius: 3,
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: shadowColor!,
                  offset: Offset(-1, 1),
                  spreadRadius: -2,
                  blurRadius: 3,
                ),
              ],
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        tooltip: tooltip,
        splashRadius: 15,
        hoverColor: null,
        splashColor: foregroundColor.withOpacity(0.5),
        highlightColor: null,
        onPressed: iconEvent,
        icon: Icon(icon, color: foregroundColor),
        color: foregroundColor,
      ),
    );
  }
}

class NavBarIconWidget extends StatelessWidget {
  final String? tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? shadowColor;
  const NavBarIconWidget({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        boxShadow: shadowColor == null
            ? null
            : [
                BoxShadow(
                  color: shadowColor!.withOpacity(0.5),
                  //offset: Offset(1,2),
                  spreadRadius: 3,
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: shadowColor!,
                  offset: const Offset(-3, -4),
                  spreadRadius: -2,
                  blurRadius: 10,
                ),
              ],
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: foregroundColor),
      ),
    );
  }
}
