import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData iconData;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final VisualDensity? visualDensity;
  final ButtonStyle? style;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.iconColor,
    this.iconSize,
    this.tooltip,
    this.padding = const EdgeInsets.all(12.0),
    this.constraints,
    this.visualDensity,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconButtonTheme = theme.iconButtonTheme;
    final overallIconTheme = IconTheme.of(context);

    // Determine effective icon color
    Color? finalIconColor = iconColor;
    if (finalIconColor == null) {
      final Set<MaterialState> enabledStates = {};

      final Color? themeButtonIconColor =
          iconButtonTheme.style?.iconColor?.resolve(enabledStates);

      if (themeButtonIconColor != null) {
        finalIconColor = themeButtonIconColor;
      } else if (overallIconTheme.color != null) {
        finalIconColor = overallIconTheme.color;
      } else {
        final AppBarTheme appBarTheme = AppBarTheme.of(context);
        if (appBarTheme.actionsIconTheme?.color != null) {
          finalIconColor = appBarTheme.actionsIconTheme!.color;
        } else if (appBarTheme.iconTheme?.color != null) {
          finalIconColor = appBarTheme.iconTheme!.color;
        } else {
          finalIconColor = colorScheme.onSurface;
        }
      }
    }

    // Determine effective icon size
    final double? themeIconSize = iconButtonTheme.style?.iconSize?.resolve({});
    final double effectiveIconSize =
        iconSize ?? themeIconSize ?? overallIconTheme.size ?? 24.0;

    return IconButton(
      icon: Icon(
        iconData,
        color: finalIconColor,
        size: effectiveIconSize,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: padding,
      constraints: constraints,
      visualDensity: visualDensity,
      style: style ?? iconButtonTheme.style,
    );
  }
}
