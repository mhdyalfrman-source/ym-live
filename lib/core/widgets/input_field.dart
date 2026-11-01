import 'package:tom_chat/core/widgets/lable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/l10n/l10n.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.isRequired,
    this.readOnly = false,
    this.withEnterText = true,
    this.withStar = true,
    this.isNumber = false,
    this.obscureText = false,
    this.withBorder = true,
    this.enabled = true,
    this.autoFocus = false,
    this.node,
    required this.keyboardType,
    required this.controller,
    this.label,
    this.aboveLabel,
    this.hint,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.maxLines,
    this.maxLength,
    this.suffix,
    this.prefix,
    this.validator,
    this.mouseCursor,
    this.textDirection,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final bool isRequired;
  final bool withStar;
  final bool? readOnly;
  final bool enabled;
  final bool isNumber;
  final bool obscureText;
  final bool withBorder;
  final bool autoFocus;
  final bool withEnterText;
  final FocusNode? node;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? label;
  final String? aboveLabel;
  final String? hint;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Function()? onEditingComplete;
  final Widget? suffix;
  final Widget? prefix;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final MouseCursor? mouseCursor;
  final TextStyle? style;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late FocusNode node;
  bool isFocus = false;
  @override
  void initState() {
    super.initState();
    node = widget.node ?? FocusNode();
    node.addListener(() {
      if (mounted) {
        setState(() {
          isFocus = node.hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.aboveLabel != null) ...[
          LableWidget(
            color: isFocus ? Colors.white : Colors.white70,
            text:
                widget.aboveLabel! +
                (widget.withStar && widget.isRequired ? " *" : ""),
          ),
        ],
        TextFormField(
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          autofocus: widget.autoFocus,
          onTapOutside: (v) {
            FocusManager.instance.primaryFocus?.unfocus();
            if (mounted) {
              setState(() {
                isFocus = false;
              });
            }
          },
          onEditingComplete: widget.onEditingComplete,
          onTap: widget.onTap,
          readOnly: widget.readOnly!,
          obscureText: widget.obscureText,
          onFieldSubmitted: widget.onFieldSubmitted,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          style: widget.style ?? Theme.of(context).textTheme.displaySmall!,
          textAlign: TextAlign.start,
          onChanged: widget.onChanged,
          focusNode: node,
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          cursorColor: Colors.white,
          decoration: decoration(context),
          validator: (v) {
            if (widget.isRequired) {
              if (v!.trim() == "") {
                return context.l10n.emptyValue;
              }
              if (widget.isNumber) {
                if (num.tryParse(v) == null) {
                  return context.l10n.errorNumberValue;
                }
              }
            }
            if (widget.validator != null) {
              return widget.validator!(v);
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration decoration(BuildContext context) {
    return InputDecoration(
      suffixIcon: widget.suffix,
      prefixIcon: widget.prefix,
      contentPadding: const EdgeInsets.all(10).r,
      counter: const SizedBox(),
      errorStyle:
          widget.style ??
          Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: Colors.white),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: widget.withBorder
            ? const BorderSide(color: AppColors.red)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(15).r,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: widget.withBorder
            ? BorderSide(color: AppColors.red.withOpacity(0.3))
            : BorderSide.none,
        borderRadius: BorderRadius.circular(15).r,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: widget.withBorder
            ? BorderSide(width: 1, color: Colors.white60)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(15).r,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: widget.withBorder
            ? BorderSide(color: Colors.white, width: 2.r)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(15).r,
      ),
      label: widget.label == null ? null : Text(widget.label!),
      labelStyle: Theme.of(
        context,
      ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
      hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      ),
      hintText: widget.hint == null
          ? null
          : (widget.withEnterText ? "${context.l10n.write} " : "") +
                widget.hint!,
    );
  }
}
