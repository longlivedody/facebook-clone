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
    final ButtonStyle? themeButtonStyle = Theme.of(
      context,
    ).elevatedButtonTheme.style;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final ButtonStyle componentDefaultStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withAlpha(
            80,
          ); // Use primary color from theme
        } else if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withAlpha(12);
        }
        return colorScheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withAlpha(38);
        }
        return colorScheme.onPrimary;
      }),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(
        Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      elevation: WidgetStateProperty.resolveWith<double?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) return 2.0;
        if (states.contains(WidgetState.disabled)) return 0.0;
        return 4.0; // Default elevation
      }),
    );

    final ButtonStyle effectiveStyle = (themeButtonStyle ?? const ButtonStyle())
        .merge(componentDefaultStyle)
        .merge(style);

    TextStyle? labelTextStyle = textStyle;
    if (labelTextStyle == null) {
      final WidgetStateProperty<TextStyle?>? styleTextStyleProp =
          effectiveStyle.textStyle;
      if (styleTextStyleProp is WidgetStatePropertyAll<TextStyle?>) {
        labelTextStyle = styleTextStyleProp.value;
      } else if (styleTextStyleProp != null) {
        labelTextStyle = styleTextStyleProp.resolve({});
      }
    }

    labelTextStyle ??= Theme.of(context).textTheme.labelLarge;

    return ElevatedButton(
      onPressed: onPressed,
      style: effectiveStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
