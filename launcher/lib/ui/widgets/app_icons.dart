import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconData {
  static const String _basePath = 'assets/svgs/';
  static const String googleSignIn = '${_basePath}google.svg';
}

class AppIcons extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  const AppIcons({
    super.key,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SvgPicture.asset(
        icon,
        height: 35.0,
        width: 35.0,
      ),
    );
  }
}
