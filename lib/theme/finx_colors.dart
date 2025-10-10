import 'package:flutter/material.dart';

/// FinX Design Manifesto Color Palette
/// "Aurora on a Midnight Lake"
class FinxColors {
  // Primary Colors
  static const Color nightVoid = Color(0xFF0D0F17);
  static const Color ghostWhite = Color(0xFFF0F2F5);
  static const Color auroraGreen = Color(0xFF00F5A0);
  static const Color celestialViolet = Color(0xFF8E54E9);
  
  // Neutral Fog Palette
  static const Color neutralFogDark = Color(0xFF2A2D3A);
  static const Color neutralFogMedium = Color(0xFF4A4D59);
  static const Color neutralFogLight = Color(0xFF8D909D);
  
  // Semantic Colors
  static const Color success = Color(0xFF00D2A0);
  static const Color warning = Color(0xFFFFC700);
  static const Color error = Color(0xFFFF5A5A);
  
  // Gradients
  static const LinearGradient auroraFlow = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    transform: GradientRotation(110 * 3.14159 / 180),
    colors: [celestialViolet, auroraGreen],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient auroraFlowHover = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    transform: GradientRotation(120 * 3.14159 / 180),
    colors: [celestialViolet, auroraGreen],
    stops: [0.0, 1.0],
  );
}

/// 8-Point Grid System
class FinxSpacing {
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Border Radius System
class FinxRadius {
  static const double button = 12.0;
  static const double card = 24.0;
  static const double modal = 32.0;
}

