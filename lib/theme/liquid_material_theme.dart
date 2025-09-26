import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// 🌊 LIQUID MATERIAL 3 THEME
///
/// The ultimate design system featuring:
/// - Dark space background with intelligent glass panels
/// - Neon green/cyan accents for premium feel
/// - Manrope typography for modern readability
/// - 28px border radius for signature M3 rounded look
/// - Sophisticated glass morphism effects

class LiquidMaterialTheme {
  // 🌌 Core Color Palette - Now context-aware for dynamic theming
  static Color darkSpaceBackground(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color neonAccent(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color softWhite(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color glassSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withOpacity(0.15);
  }

  static Color glassPurple(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  static Color glassBlue(BuildContext context) {
    return Theme.of(context).colorScheme.secondaryContainer;
  }

  // 🎨 Glass Effect Colors - Now context-aware
  static Color glassGlow(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.1);
  }

  static Color mirrorSheen(BuildContext context) {
    return Colors.white.withOpacity(0.1);
  }

  static Color glassBorder(BuildContext context) {
    return Theme.of(context).colorScheme.outline.withOpacity(0.2);
  }

  /// 🌊 Liquid Material 3 Dark Theme
  static ThemeData get darkTheme {
    return createDarkTheme(null);
  }

  // Static fallback colors for use in static contexts
  static const Color _defaultNeonAccent = Color(0xFF00E676);
  static const Color _defaultDarkSpaceBackground = Color(0xFF0F0F23);
  static const Color _defaultSoftWhite = Color(0xFFEAEAEA);

  /// 🌊 Create Dynamic Dark Theme
  static ThemeData createDarkTheme(ColorScheme? dynamicColorScheme) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _defaultNeonAccent,
          brightness: Brightness.dark,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // 🎭 Manrope Typography System
      textTheme: _buildManropeTextTheme(colorScheme),

      // 🧩 Liquid AppBar
      appBarTheme: _buildLiquidAppBarTheme(colorScheme),

      // 🎨 Liquid Cards with 28px radius
      cardTheme: _buildLiquidCardTheme(),

      // 🎯 Liquid Buttons
      elevatedButtonTheme: _buildLiquidButtonTheme(),
      filledButtonTheme: _buildLiquidFilledButtonTheme(),
      outlinedButtonTheme: _buildLiquidOutlinedButtonTheme(),
      textButtonTheme: _buildLiquidTextButtonTheme(),

      // 🌟 Liquid FAB
      floatingActionButtonTheme: _buildLiquidFABTheme(),

      // 🎨 Input Fields
      inputDecorationTheme: _buildLiquidInputTheme(colorScheme),

      // 🎭 Bottom Navigation
      bottomNavigationBarTheme: _buildLiquidBottomNavTheme(colorScheme),

      // 🎨 Progress Indicators
      progressIndicatorTheme: _buildLiquidProgressTheme(),

      // 🎪 Chips
      chipTheme: _buildLiquidChipTheme(colorScheme),

      // 🎨 Dividers
      dividerTheme: _buildLiquidDividerTheme(),

      // 🎭 Page Transitions
      pageTransitionsTheme: _buildLiquidPageTransitions(),

      // 🎨 Scaffold
      scaffoldBackgroundColor: colorScheme.background,

      // 🎭 Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// 🌊 Create Dynamic Light Theme
  static ThemeData createLightTheme(ColorScheme? dynamicColorScheme) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _defaultNeonAccent,
          brightness: Brightness.light,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // 🎭 Manrope Typography System
      textTheme: _buildManropeTextTheme(colorScheme),

      // 🧩 Liquid AppBar
      appBarTheme: _buildLiquidAppBarTheme(colorScheme),

      // 🎨 Liquid Cards with 28px radius
      cardTheme: _buildLiquidCardTheme(),

      // 🎯 Liquid Buttons
      elevatedButtonTheme: _buildLiquidButtonTheme(),
      filledButtonTheme: _buildLiquidFilledButtonTheme(),
      outlinedButtonTheme: _buildLiquidOutlinedButtonTheme(),
      textButtonTheme: _buildLiquidTextButtonTheme(),

      // 🌟 Liquid FAB
      floatingActionButtonTheme: _buildLiquidFABTheme(),

      // 🎨 Input Fields
      inputDecorationTheme: _buildLiquidInputTheme(colorScheme),

      // 🎭 Bottom Navigation
      bottomNavigationBarTheme: _buildLiquidBottomNavTheme(colorScheme),

      // 🎨 Progress Indicators
      progressIndicatorTheme: _buildLiquidProgressTheme(),

      // 🎪 Chips
      chipTheme: _buildLiquidChipTheme(colorScheme),

      // 🎨 Dividers
      dividerTheme: _buildLiquidDividerTheme(),

      // 🎭 Page Transitions
      pageTransitionsTheme: _buildLiquidPageTransitions(),

      // 🎨 Scaffold
      scaffoldBackgroundColor: colorScheme.background,

      // 🎭 Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// 🎭 Manrope Typography System
  static TextTheme _buildManropeTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.manropeTextTheme().copyWith(
      // Display styles - Large, bold, futuristic
      displayLarge: GoogleFonts.manrope(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.15,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
        color: colorScheme.onSurface,
      ),

      // Headline styles - Medium, impactful
      headlineLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: colorScheme.onSurface,
      ),

      // Title styles - Balanced, readable
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: colorScheme.onSurface,
      ),

      // Body styles - Clean, readable
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.3,
        color: Colors.white70,
      ),

      // Label styles - Compact, functional
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
        color: Colors.white70,
      ),
    );
  }

  /// 🧩 Liquid AppBar Theme
  static AppBarTheme _buildLiquidAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.primary, size: 24),
      actionsIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
    );
  }

  /// 🎨 Liquid Card Theme with 28px radius
  static CardThemeData _buildLiquidCardTheme() {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }

  /// 🎯 Liquid Button Themes
  static ElevatedButtonThemeData _buildLiquidButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static FilledButtonThemeData _buildLiquidFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildLiquidOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: _defaultNeonAccent, width: 1),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildLiquidTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// 🌟 Liquid FAB Theme
  static FloatingActionButtonThemeData _buildLiquidFABTheme() {
    return FloatingActionButtonThemeData(
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: _defaultNeonAccent,
      foregroundColor: _defaultDarkSpaceBackground,
    );
  }

  /// 🎨 Liquid Input Theme
  static InputDecorationTheme _buildLiquidInputTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.manrope(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.manrope(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 🎭 Liquid Bottom Navigation Theme
  static BottomNavigationBarThemeData _buildLiquidBottomNavTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface.withOpacity(0.15),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 🎨 Liquid Progress Theme
  static ProgressIndicatorThemeData _buildLiquidProgressTheme() {
    return const ProgressIndicatorThemeData(
      color: _defaultNeonAccent,
      linearTrackColor: Color(0xFF2A2D3A),
      circularTrackColor: Color(0xFF2A2D3A),
    );
  }

  /// 🎪 Liquid Chip Theme
  static ChipThemeData _buildLiquidChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surface.withOpacity(0.15),
      selectedColor: colorScheme.primary,
      labelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
    );
  }

  /// 🎨 Liquid Divider Theme
  static DividerThemeData _buildLiquidDividerTheme() {
    return const DividerThemeData(
      color: Color(0xFF2A2D3A),
      thickness: 1,
      space: 1,
    );
  }

  /// 🎭 Liquid Page Transitions
  static PageTransitionsTheme _buildLiquidPageTransitions() {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const LiquidPageTransitionsBuilder(),
        TargetPlatform.iOS: const LiquidPageTransitionsBuilder(),
      },
    );
  }
}

/// 🎭 Liquid Page Transitions
class LiquidPageTransitionsBuilder extends PageTransitionsBuilder {
  const LiquidPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}
