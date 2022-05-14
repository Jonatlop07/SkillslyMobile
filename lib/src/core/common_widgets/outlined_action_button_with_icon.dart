import 'package:flutter/material.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';

class OutlinedActionButtonWithIcon extends StatelessWidget {
  const OutlinedActionButtonWithIcon({
    Key? key,
    required this.text,
    required this.color,
    required this.iconData,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final Color color;
  final IconData iconData;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.p48,
      child: OutlinedButton.icon(
        icon: Icon(
          iconData,
          size: Sizes.p32,
        ),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: Sizes.p4 / 2, color: color),
          primary: color,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
