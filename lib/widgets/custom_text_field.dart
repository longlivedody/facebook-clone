import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final InputDecoration? decoration;

  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixIconTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final TextStyle? style;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.onSuffixIconTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final InputDecorationTheme themeInputDecorationTheme =
        theme.inputDecorationTheme;

    final InputDecoration componentDefaultDecoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return colorScheme.primary;
        }
        if (states.contains(MaterialState.error)) {
          return colorScheme.error;
        }
        return colorScheme.onSurfaceVariant;
      }),
      suffixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return colorScheme.primary;
        }
        if (states.contains(MaterialState.error)) {
          return colorScheme.error;
        }
        return colorScheme.onSurfaceVariant;
      }),
    );

    final InputDecoration effectiveDecoration =
        (decoration ?? componentDefaultDecoration)
            .applyDefaults(themeInputDecorationTheme)
            .copyWith(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      onPressed: onSuffixIconTap,
                      icon: Icon(suffixIcon),
                    )
                  : null,
            );

    final TextStyle? themeTextStyle = theme.textTheme.bodyLarge;
    final TextStyle effectiveTextStyle =
        (themeTextStyle ?? const TextStyle()).merge(style);

    return TextFormField(
      controller: controller,
      decoration: effectiveDecoration,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      style: effectiveTextStyle,
    );
  }
}
