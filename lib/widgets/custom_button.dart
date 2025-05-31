import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final ButtonStyle? themeButtonStyle = theme.elevatedButtonTheme.style;

    final ButtonStyle componentDefaultStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return colorScheme.primary.withOpacity(0.8);
        } else if (states.contains(MaterialState.disabled)) {
          return colorScheme.onSurface.withOpacity(0.12);
        }
        return colorScheme.primary;
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return colorScheme.onSurface.withOpacity(0.38);
        }
        return colorScheme.onPrimary;
      }),
      padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
      textStyle: MaterialStatePropertyAll<TextStyle?>(
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      shape: MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      elevation: MaterialStateProperty.resolveWith<double?>((states) {
        if (states.contains(MaterialState.pressed)) return 2.0;
        if (states.contains(MaterialState.disabled)) return 0.0;
        return 2.0;
      }),
      minimumSize:
          const MaterialStatePropertyAll<Size>(Size(double.infinity, 48)),
    );

    final ButtonStyle effectiveStyle = (themeButtonStyle ?? const ButtonStyle())
        .merge(componentDefaultStyle)
        .merge(style);

    TextStyle? labelTextStyle = textStyle;
    if (labelTextStyle == null) {
      final MaterialStateProperty<TextStyle?>? styleTextStyleProp =
          effectiveStyle.textStyle;
      if (styleTextStyleProp is MaterialStatePropertyAll<TextStyle?>) {
        labelTextStyle = styleTextStyleProp.value;
      } else if (styleTextStyleProp != null) {
        labelTextStyle = styleTextStyleProp.resolve({});
      }
    }

    labelTextStyle ??= theme.textTheme.labelLarge;

    return ElevatedButton(
      onPressed: onPressed,
      style: effectiveStyle,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: effectiveStyle.foregroundColor?.resolve({}),
              ),
              child: icon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(text, style: labelTextStyle),
        ],
      ),
    );
  }
}
