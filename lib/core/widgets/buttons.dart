import 'package:flutter/material.dart';
import 'package:tom_chat/core/theme/color.dart';

class GeneralButton extends StatefulWidget {
  final Function()? onPressed;
  final Color? color;
  final String title;
  final int colorIndex;
  final EdgeInsetsGeometry padding;
  final double margin;
  final double borderRadius;
  final Alignment begin;
  final Alignment end;

  const GeneralButton({
    super.key,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.onPressed,
    required this.title,
    this.padding = const EdgeInsets.all(13),
    this.margin = 20,
    this.borderRadius = 30,
    this.color,
    this.colorIndex = 0,
  });

  @override
  State<GeneralButton> createState() => _GeneralButtonState();
}

class _GeneralButtonState extends State<GeneralButton> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.margin),
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.color != null || widget.onPressed == null
            ? null
            : LinearGradient(
                begin: widget.begin,
                end: widget.end,
                colors: colors[widget.colorIndex],
              ),
        color: widget.onPressed == null
            ? Colors.black38
            : (widget.color ?? Theme.of(context).primaryColor),
      ),
      child: InkWell(
        onTap: widget.onPressed == null || isClick
            ? null
            : () async {
                setState(() {
                  isClick = true;
                });
                await widget.onPressed!();
                if (mounted) {
                  setState(() {
                    isClick = false;
                  });
                }
              },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.title,
            maxLines: 1,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class GeneralButton2 extends StatefulWidget {
  final Function()? onPressed;
  final String title;
  final EdgeInsetsGeometry padding;
  final double margin;
  final double borderRadius;
  final Color? color;
  const GeneralButton2({
    super.key,
    required this.onPressed,
    required this.title,
    this.padding = const EdgeInsets.all(13),
    this.margin = 20,
    this.borderRadius = 10,
    this.color,
  });

  @override
  State<GeneralButton2> createState() => _GeneralButton2State();
}

class _GeneralButton2State extends State<GeneralButton2> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.margin),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, 0),
          padding: widget.padding,
          backgroundColor: Theme.of(context).primaryColorLight,
          surfaceTintColor: Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        onPressed: widget.onPressed == null || isClick
            ? null
            : () async {
                setState(() {
                  isClick = true;
                });
                await widget.onPressed!();
                if (mounted) {
                  setState(() {
                    isClick = false;
                  });
                }
              },
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.color ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class GeneralButton3 extends StatefulWidget {
  final Function()? onPressed;
  final String title;
  final EdgeInsetsGeometry padding;
  final double margin;
  final double borderRadius;
  final Color? color;
  final Color? fontColor;
  final Widget? icon;
  const GeneralButton3({
    super.key,
    required this.onPressed,
    required this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    this.margin = 20,
    this.borderRadius = 10,
    this.color,
    this.fontColor,
    this.icon,
  });

  @override
  State<GeneralButton3> createState() => _GeneralButton3State();
}

class _GeneralButton3State extends State<GeneralButton3> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.margin),
      child: ElevatedButton.icon(
        icon: widget.icon,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, 0),
          padding: widget.padding,
          backgroundColor: widget.color ?? Theme.of(context).primaryColorLight,
          surfaceTintColor: widget.color ?? Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        onPressed: widget.onPressed == null || isClick
            ? null
            : () async {
                setState(() {
                  isClick = true;
                });
                await widget.onPressed!();
                if (mounted) {
                  setState(() {
                    isClick = false;
                  });
                }
              },
        label: Text(
          widget.title,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.fontColor ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class IconButtonWidget extends StatefulWidget {
  final Function()? onPressed;
  final Widget icon;
  final ButtonStyle? style;
  final String? tooltip;
  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    this.style,
    this.tooltip,
  });

  @override
  State<IconButtonWidget> createState() => _IconButtonWidgetState();
}

class _IconButtonWidgetState extends State<IconButtonWidget> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.onPressed == null || isClick
          ? null
          : () async {
              setState(() {
                isClick = true;
              });
              await widget.onPressed!();
              if (mounted) {
                setState(() {
                  isClick = false;
                });
              }
            },
      icon: widget.icon,
      style: widget.style,
    );
  }
}
