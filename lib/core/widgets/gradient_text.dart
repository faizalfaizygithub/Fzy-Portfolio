import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColors.textGradient,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: gradient.createShader,
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
