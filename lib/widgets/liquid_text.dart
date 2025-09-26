import 'package:flutter/material.dart';
import '../theme/liquid_material_theme.dart';

class LiquidText extends StatelessWidget {
  final String text;
  final LiquidTextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const LiquidText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = style?.toTextStyle(context) ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      text,
      style: color != null ? textStyle?.copyWith(color: color) : textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class LiquidTextStyle {
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? height;
  final String? fontFamily;

  const LiquidTextStyle({
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.height,
    this.fontFamily,
  });

  static const LiquidTextStyle displayLarge = LiquidTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const LiquidTextStyle headlineLarge = LiquidTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const LiquidTextStyle headlineMedium = LiquidTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const LiquidTextStyle headlineSmall = LiquidTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const LiquidTextStyle titleLarge = LiquidTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const LiquidTextStyle titleMedium = LiquidTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const LiquidTextStyle titleSmall = LiquidTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const LiquidTextStyle bodyLarge = LiquidTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const LiquidTextStyle bodyMedium = LiquidTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const LiquidTextStyle bodySmall = LiquidTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const LiquidTextStyle labelLarge = LiquidTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const LiquidTextStyle labelMedium = LiquidTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const LiquidTextStyle labelSmall = LiquidTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  LiquidTextStyle copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    String? fontFamily,
  }) {
    return LiquidTextStyle(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: height ?? this.height,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  TextStyle toTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: fontFamily ?? 'Manrope',
    );
  }
}
