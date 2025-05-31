import 'package:flutter/material.dart';

import 'custom_icon_button.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomText(
          'facebook',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        CustomIconButton(
          onPressed: () {},
          iconData: Icons.search,
          iconSize: 24,
        ),
        const SizedBox(width: 8),
        CustomIconButton(
          onPressed: () {},
          iconData: Icons.message,
          iconSize: 24,
        ),
      ],
    );
  }
}
