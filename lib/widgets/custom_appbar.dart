import 'package:flutter/material.dart';

import 'custom_icon_button.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CustomText(
          'facebook',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        CustomIconButton(
          onPressed: () {},
          iconData: Icons.search,
          iconSize: 30,
        ),
        CustomIconButton(
          onPressed: () {},
          iconData: Icons.message,
          iconSize: 30,
        ),
      ],
    );
  }
}
