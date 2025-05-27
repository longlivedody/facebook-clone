import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticLabel;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? defaultThemeStyle = Theme.of(context).textTheme.bodyLarge;

    final TextStyle effectiveTextStyle =
        (defaultThemeStyle ?? const TextStyle()).merge(style);

    return Text(
      text,
      style: effectiveTextStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticLabel,
    );
  }
}
