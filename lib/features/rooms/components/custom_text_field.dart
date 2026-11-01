import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool obscureText;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextAlign? alignment;
  final Widget? upperWidget;

  const CustomTextField({
    super.key,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.controller,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor = const Color(0xFFF8F9FA),
    this.borderColor,
    this.borderRadius = 8.0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.validator,
    this.onTap,
    this.obscureText = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.alignment,
    this.upperWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style:
                labelStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => SizedBox(),
          textAlign: alignment ?? TextAlign.start,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          minLines: minLines ?? 1,
          maxLines:
              maxLines ?? (keyboardType == TextInputType.multiline ? null : 1),
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          obscureText: obscureText,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          style:
              textStyle ?? const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                hintStyle ?? TextStyle(color: Colors.grey[600], fontSize: 16),
            filled: true,
            fillColor: fillColor,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: borderColor != null
                  ? BorderSide(color: borderColor!)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: borderColor != null
                  ? BorderSide(color: borderColor!)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: contentPadding,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
