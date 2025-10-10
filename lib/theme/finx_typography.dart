import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finx_colors.dart';

/// FinX Typography System
/// Headings: Satoshi equivalent (using Manrope - geometric sans-serif)
/// Body: Inter
class FinxTypography {
  // Headings - Manrope (closest to Satoshi)
  static TextStyle h1({Color? color}) => GoogleFonts.manrope(
        fontSize: 72, // 4.5rem
        fontWeight: FontWeight.w900,
        letterSpacing: -0.02 * 72,
        color: color ?? FinxColors.ghostWhite,
        height: 1.1,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.manrope(
        fontSize: 44, // 2.75rem
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 44,
        color: color ?? FinxColors.ghostWhite,
        height: 1.2,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.manrope(
        fontSize: 28, // 1.75rem
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 28,
        color: color ?? FinxColors.ghostWhite,
        height: 1.3,
      );

  static TextStyle h4({Color? color}) => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 20,
        color: color ?? FinxColors.ghostWhite,
        height: 1.4,
      );

  // Body Text - Inter
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color ?? FinxColors.ghostWhite,
        height: 1.7,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color ?? FinxColors.ghostWhite,
        height: 1.7,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? FinxColors.ghostWhite,
        height: 1.6,
      );

  // UI Labels - Inter Medium
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? FinxColors.ghostWhite,
        height: 1.5,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? FinxColors.ghostWhite,
        height: 1.4,
      );

  // Caption - Inter
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? FinxColors.neutralFogLight,
        height: 1.5,
      );

  // Button Text
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? FinxColors.nightVoid,
        letterSpacing: 0.5,
      );
}

