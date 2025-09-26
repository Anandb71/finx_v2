// lib/utils/liquid_text_style.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiquidTextStyle {
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.manrope(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: Theme.of(context).colorScheme.onBackground,
    letterSpacing: -1.5,
  );
  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onBackground,
    letterSpacing: 0.5,
  );
  static TextStyle titleLarge(BuildContext context) => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle titleMedium(BuildContext context) => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
  );
  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
  );
  static TextStyle labelMedium(BuildContext context) => GoogleFonts.manrope(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onSurface,
  );
  static TextStyle labelSmall(BuildContext context) => GoogleFonts.manrope(
    fontWeight: FontWeight.bold,
    fontSize: 10,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

