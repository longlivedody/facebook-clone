import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData iconData;
  final Color? iconColor; // If provided, this will OVERRIDE theme colors
  final double? iconSize;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final VisualDensity? visualDensity;
  final ButtonStyle? style; // To allow using IconButtonTheme

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.iconColor,
    this.iconSize,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
    this.constraints,
    this.visualDensity,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconThemeData overallIconTheme = IconTheme.of(
      context,
    ); // General IconTheme
    final IconButtonThemeData iconButtonTheme = theme.iconButtonTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    // Determine effective icon color:
    // Priority:
    // 1. `this.iconColor` (if explicitly passed to CustomIconButton)
    // 2. `iconButtonTheme.style?.iconColor` (if using MaterialStateProperty and resolved)
    // 3. `overallIconTheme.color` (e.g., from AppBar's IconTheme)
    // 4. Fallback to a color from the ColorScheme (e.g., onSurface or primary)
    Color? finalIconColor = iconColor;

    if (finalIconColor == null) {
      // Try to get color from IconButtonTheme's style
      // IconButtonThemeData.style.iconColor is a MaterialStateProperty<Color?>
      // We need to resolve it for a typical 'enabled' state (i.e., not disabled).
      final Set<WidgetState> enabledStates =
          {}; // Represents the default, enabled state

      final Color? themeButtonIconColor = iconButtonTheme.style?.iconColor
          ?.resolve(enabledStates);

      if (themeButtonIconColor != null) {
        finalIconColor = themeButtonIconColor;
      } else if (overallIconTheme.color != null) {
        finalIconColor = overallIconTheme.color;
      } else {
        // Fallback: Check if inside an AppBar context for more specific theme colors
        final AppBarTheme appBarTheme = AppBarTheme.of(context);
        if (appBarTheme.actionsIconTheme?.color != null) {
          finalIconColor = appBarTheme.actionsIconTheme!.color;
        } else if (appBarTheme.iconTheme?.color != null) {
          finalIconColor = appBarTheme.iconTheme!.color;
        } else {
          // General fallback if no other theme color is found
          finalIconColor = colorScheme.onSurface;
        }
      }
    }

    // Determine effective icon size:
    // Priority:
    // 1. `this.iconSize`
    // 2. `iconButtonTheme.style?.iconSize`
    // 3. `overallIconTheme.size`
    // 4. Default fallback size
    final double? themeIconSize = iconButtonTheme.style?.iconSize?.resolve(
      {},
    ); // Resolve for normal state
    final double effectiveIconSize =
        iconSize ?? themeIconSize ?? overallIconTheme.size ?? 24.0;

    return IconButton(
      icon: Icon(
        iconData,
        color: finalIconColor, // Use the determined color
        size: effectiveIconSize,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: padding,
      constraints: constraints,
      visualDensity: visualDensity,
      // Apply theme's IconButton style if `style` prop isn't provided,
      // allowing instance-specific style overrides.
      style: style ?? iconButtonTheme.style,
    );
  }
}
