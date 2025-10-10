import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'services/enhanced_portfolio_provider.dart';
import 'services/real_time_data_service.dart';
import 'services/performance_monitor.dart';
import 'services/data_cache.dart';
import 'services/achievement_service.dart';
import 'services/quest_service.dart';
import 'services/ai_mentor_state_service.dart';
import 'services/news_service.dart';
import 'widgets/app_with_floating_ai.dart';
import 'services/global_mascot_manager.dart';
import 'theme/liquid_material_theme.dart';
import 'theme/finx_colors.dart';
import 'theme/finx_typography.dart';
import 'widgets/finx_button.dart';
import 'widgets/finx_card.dart';

// To make GoogleFonts work, add this to your pubspec.yaml file:
// dependencies:
//   google_fonts: ^6.2.1

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  await DataCache().clearExpiredCache();
  PerformanceMonitor().logMemoryUsage('App Start');

  // Uncomment the line below to force sign out on app start (for testing)
  // await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

// TODO: APIs need to be fixed on site

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Navigation key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Portfolio provider
        ChangeNotifierProvider(
          create: (context) {
            final provider = EnhancedPortfolioProvider();
            provider.initializeRealTimeData();
            return provider;
          },
        ),

        // Real-time data service
        Provider(create: (context) => RealTimeDataService()),

        // Performance monitor
        Provider(create: (context) => PerformanceMonitor()),

        // Data cache
        Provider(create: (context) => DataCache()),

        // Achievement service
        ChangeNotifierProvider(create: (context) => AchievementService()),

        // Quest service
        ChangeNotifierProvider(create: (context) => QuestService()),

        // AI Mentor state service
        ChangeNotifierProvider(create: (context) => AIMentorStateService()),

        // News service
        Provider(create: (context) => NewsService()),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null) {
            // Dynamic colors are available. Use them.
            lightColorScheme = lightDynamic.harmonized();
            darkColorScheme = darkDynamic.harmonized();
          } else {
            // Dynamic colors are not available, use our fallback brand colors.
            lightColorScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF00E676),
              brightness: Brightness.light,
            );
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF00E676),
              brightness: Brightness.dark,
            );
          }

          return MaterialApp(
            navigatorKey: GlobalMascotManager.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: LiquidMaterialTheme.createDarkTheme(
              null,
            ), // Force super dark theme
            darkTheme: LiquidMaterialTheme.createDarkTheme(
              null,
            ), // Force super dark theme
            themeMode: ThemeMode.dark, // Always use dark mode
            home: const AppWithFloatingAI(child: AuthGate()),
            builder: (context, child) {
              return AppWithFloatingAI(
                child: child!,
                showFloatingAI: _shouldShowFloatingAI(context),
              );
            },
          );
        },
      ),
    );
  }

  bool _shouldShowFloatingAI(BuildContext context) {
    // Show floating AI button on all screens except the AI Mentor screen itself
    final route = ModalRoute.of(context);
    if (route == null) return true;

    final routeName = route.settings.name;
    return routeName != '/ai-mentor' && routeName != '/ai_mentor';
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _aboutUsController;
  late AnimationController _featuresController;
  late AnimationController _howItWorksController;
  late AnimationController _finalPitchController;
  late AnimationController _step1Controller;
  late AnimationController _step2Controller;
  late AnimationController _step3Controller;

  late Animation<double> _aboutUsAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<double> _howItWorksAnimation;
  late Animation<double> _finalPitchAnimation;
  late Animation<double> _step1Animation;
  late Animation<double> _step2Animation;
  late Animation<double> _step3Animation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize animation controllers
    _aboutUsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _howItWorksController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _finalPitchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _step1Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _step2Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _step3Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _aboutUsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _aboutUsController, curve: Curves.easeOut),
    );
    _featuresAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOut),
    );
    _howItWorksAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _howItWorksController, curve: Curves.easeOut),
    );
    _finalPitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _finalPitchController, curve: Curves.easeOut),
    );
    _step1Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _step1Controller, curve: Curves.easeOut));
    _step2Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _step2Controller, curve: Curves.easeOut));
    _step3Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _step3Controller, curve: Curves.easeOut));

    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger animations based on scroll position
    if (_scrollController.offset > 200) {
      _aboutUsController.forward();
    }
    if (_scrollController.offset > 400) {
      _featuresController.forward();
    }
    if (_scrollController.offset > 600) {
      _howItWorksController.forward();
      // Trigger step animations with staggered delays
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _step1Controller.forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _step2Controller.forward();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _step3Controller.forward();
      });
    }
    if (_scrollController.offset > 800) {
      _finalPitchController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _aboutUsController.dispose();
    _featuresController.dispose();
    _howItWorksController.dispose();
    _finalPitchController.dispose();
    _step1Controller.dispose();
    _step2Controller.dispose();
    _step3Controller.dispose();
    super.dispose();
  }

  /// Get the last updated date for the website
  String _getLastUpdatedDate() {
    return 'Sep 29, 2025';
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: FinxColors.nightVoid,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FinxColors.nightVoid,
              FinxColors.nightVoid.withOpacity(0.95),
              FinxColors.nightVoid,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Full-page background pattern
            Positioned.fill(
              child: CustomPaint(painter: FullPageGridPatternPainter()),
            ),
            // Full-page geometric elements
            _buildFullPageGeometricElements(context),
            // Scroll progress indicator
            _buildScrollProgressIndicator(context),
            // Advanced particle system
            _buildParticleSystem(context),
            // Main content - Using single ListView for smooth scrolling
            SafeArea(
              child: ListView(
                controller: _scrollController,
                children: [
                  _buildHeader(context, isWeb),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 60.0 : 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHookSection(context),
                        const SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _featuresAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                50 * (1 - _featuresAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _featuresAnimation.value,
                                child: _buildFeaturesSection(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _aboutUsAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                30 * (1 - _aboutUsAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _aboutUsAnimation.value,
                                child: _buildAboutUsSection(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _howItWorksAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                40 * (1 - _howItWorksAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _howItWorksAnimation.value,
                                child: _buildHowItWorksSection(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _finalPitchAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                30 * (1 - _finalPitchAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _finalPitchAnimation.value,
                                child: _buildFinalPitch(context),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 60.0 : 24.0,
        vertical: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                color: FinxColors.auroraGreen,
                size: 32,
              ),
              SizedBox(width: FinxSpacing.xs),
              Text(
                'Finx',
                style: FinxTypography.h4(color: FinxColors.ghostWhite),
              ),
            ],
          ),
          // Navigation
          if (isWeb)
            Row(
              children: [
                _buildNavItem('Features'),
                const SizedBox(width: 32),
                _buildNavItem('About'),
                const SizedBox(width: 32),
                _buildNavItem('Contact'),
                SizedBox(width: FinxSpacing.lg),
                FinxButton(
                  text: 'Sign In',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  type: FinxButtonType.primary,
                ),
              ],
            )
          else
            // Mobile login button
            FinxButton(
              text: 'Sign In',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              type: FinxButtonType.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHookSection(BuildContext context) {
    return Stack(
      children: [
        // Advanced Aurora glow effect with multiple layers
        _buildAdvancedAuroraGlow(context),
        // Floating geometric elements
        _buildFloatingGeometricElements(context),
        // Main content - Centered and constrained
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with pulsing effect
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 3),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00FFA3).withOpacity(0.3),
                              const Color(0xFF00FFA3).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFA3).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: Color(0xFF00FFA3),
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Main Headline with gradient text and typing effect
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF00FFA3),
                      Color(0xFF00D4FF),
                      Color(0xFF8A2BE2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: _buildTypingText(
                            'Learn to Invest, The Fun Way.',
                            value,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Sub-headline with enhanced styling
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 2500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          'Master the art of investing with AI-powered insights, real-time simulations, and gamified learning experiences.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),

                // Enhanced CTA Button with advanced animations
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 3000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00FFA3),
                              Color(0xFF00D4FF),
                              Color(0xFF8A2BE2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFA3).withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.rocket_launch, size: 24),
                              const SizedBox(width: 12),
                              const Text(
                                'Start Trading Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedAuroraGlow(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.3),
            radius: 1.5,
            colors: [
              const Color(0xFF00FFA3).withOpacity(0.15),
              const Color(0xFF00D4FF).withOpacity(0.08),
              const Color(0xFF8A2BE2).withOpacity(0.05),
              const Color(0xFF00FFA3).withOpacity(0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced grid pattern
            _buildAdvancedGridPattern(),
            // Multiple layers of floating orbs with different animations
            _buildAnimatedFloatingOrb(
              context,
              0.2,
              0.1,
              const Color(0xFF00FFA3),
              120,
              0,
            ),
            _buildAnimatedFloatingOrb(
              context,
              -0.3,
              0.2,
              const Color(0xFF00D4FF),
              90,
              1,
            ),
            _buildAnimatedFloatingOrb(
              context,
              0.4,
              -0.1,
              const Color(0xFF8A2BE2),
              150,
              2,
            ),
            _buildAnimatedFloatingOrb(
              context,
              -0.2,
              -0.2,
              const Color(0xFF00FFA3),
              100,
              3,
            ),
            _buildAnimatedFloatingOrb(
              context,
              0.1,
              0.3,
              const Color(0xFF00D4FF),
              80,
              4,
            ),
            _buildAnimatedFloatingOrb(
              context,
              0.6,
              0.0,
              const Color(0xFF8A2BE2),
              70,
              5,
            ),
            // Advanced geometric elements
            _buildAdvancedGeometricElements(context),
            // Morphing shapes
            _buildMorphingShapes(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingText(String text, double progress) {
    final visibleLength = (text.length * progress).round();
    final visibleText = text.substring(0, visibleLength.clamp(0, text.length));

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: visibleText,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              letterSpacing: -3.0,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          if (visibleLength < text.length)
            TextSpan(
              text: '|',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF00FFA3),
                shadows: [
                  Shadow(
                    color: const Color(0xFF00FFA3).withOpacity(0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingGeometricElements(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Floating triangles
          _buildFloatingTriangle(
            context,
            0.1,
            0.2,
            const Color(0xFF00FFA3),
            30,
          ),
          _buildFloatingTriangle(
            context,
            0.8,
            0.3,
            const Color(0xFF00D4FF),
            25,
          ),
          _buildFloatingTriangle(
            context,
            0.3,
            0.8,
            const Color(0xFF8A2BE2),
            35,
          ),

          // Floating circles
          _buildFloatingCircle(context, 0.7, 0.1, const Color(0xFF00FFA3), 20),
          _buildFloatingCircle(context, 0.2, 0.7, const Color(0xFF00D4FF), 15),
          _buildFloatingCircle(context, 0.9, 0.6, const Color(0xFF8A2BE2), 25),

          // Floating squares
          _buildFloatingSquare(context, 0.5, 0.1, const Color(0xFF00FFA3), 18),
          _buildFloatingSquare(context, 0.1, 0.5, const Color(0xFF00D4FF), 22),
          _buildFloatingSquare(context, 0.8, 0.8, const Color(0xFF8A2BE2), 16),
        ],
      ),
    );
  }

  Widget _buildAnimatedFloatingOrb(
    BuildContext context,
    double x,
    double y,
    Color color,
    double size,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 3000 + (index * 500)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x * 0.4),
          top:
              MediaQuery.of(context).size.height * (0.3 + y * 0.3) +
              (value * 20 * math.sin(index.toDouble())),
          child: Transform.scale(
            scale: 0.5 + (0.5 * value),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.4),
                    color.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: size * 1.2,
                    spreadRadius: size * 0.3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingTriangle(
    BuildContext context,
    double x,
    double y,
    Color color,
    double size,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y + (value * 30),
          child: Transform.rotate(
            angle: value * 2 * math.pi,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -value * 2 * math.pi,
                  child: Icon(
                    Icons.change_history,
                    color: color,
                    size: size * 0.6,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingCircle(
    BuildContext context,
    double x,
    double y,
    Color color,
    double size,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 5),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y + (value * 25),
          child: Transform.scale(
            scale: 0.7 + (0.3 * value),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: size * 0.8,
                    spreadRadius: size * 0.2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingSquare(
    BuildContext context,
    double x,
    double y,
    Color color,
    double size,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 6),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y + (value * 20),
          child: Transform.rotate(
            angle: value * math.pi,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: size * 0.5,
                    spreadRadius: size * 0.1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedGridPattern() {
    return Positioned.fill(
      child: CustomPaint(painter: AdvancedGridPatternPainter()),
    );
  }

  Widget _buildMorphingShapes(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Morphing triangle to circle
          _buildMorphingShape(
            context,
            0.2,
            0.3,
            const Color(0xFF00FFA3),
            40,
            0,
          ),
          // Morphing square to hexagon
          _buildMorphingShape(
            context,
            0.8,
            0.7,
            const Color(0xFF00D4FF),
            35,
            1,
          ),
          // Morphing diamond to star
          _buildMorphingShape(
            context,
            0.5,
            0.1,
            const Color(0xFF8A2BE2),
            30,
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildMorphingShape(
    BuildContext context,
    double x,
    double y,
    Color color,
    double size,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 3 + index),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final morphValue = (math.sin(value * 2 * math.pi) + 1) / 2;
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Transform.rotate(
            angle: value * 2 * math.pi,
            child: CustomPaint(
              size: Size(size, size),
              painter: MorphingShapePainter(
                color: color,
                morphValue: morphValue,
                shapeType: index % 3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedGeometricElements(BuildContext context) {
    return Stack(
      children: [
        // Animated geometric shapes
        _buildAnimatedGeometricShape(
          context,
          0.15,
          0.1,
          60,
          const Color(0xFF00FFA3),
          0,
        ),
        _buildAnimatedGeometricShape(
          context,
          0.85,
          0.2,
          45,
          const Color(0xFF00D4FF),
          1,
        ),
        _buildAnimatedGeometricShape(
          context,
          0.3,
          0.9,
          35,
          const Color(0xFF8A2BE2),
          2,
        ),
        _buildAnimatedGeometricShape(
          context,
          0.7,
          0.8,
          50,
          const Color(0xFF00FFA3),
          3,
        ),
      ],
    );
  }

  Widget _buildAnimatedGeometricShape(
    BuildContext context,
    double x,
    double y,
    double size,
    Color color,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 8 + (index * 2)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top:
              MediaQuery.of(context).size.height * y +
              (value * 40 * math.sin(index.toDouble())),
          child: Transform.rotate(
            angle: value * 2 * math.pi,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(size * 0.2),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: size * 0.5,
                    spreadRadius: size * 0.1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridPattern() {
    return Positioned.fill(child: CustomPaint(painter: GridPatternPainter()));
  }

  Widget _buildGeometricElements(BuildContext context) {
    return Stack(
      children: [
        // Subtle geometric shapes
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00FFA3).withOpacity(0.05),
              border: Border.all(
                color: const Color(0xFF00FFA3).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.05,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.85,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2).withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8A2BE2).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullPageGeometricElements(BuildContext context) {
    return Stack(
      children: [
        // Parallax floating particles
        ...List.generate(8, (index) {
          final positions = [
            (0.15, 0.05, 80.0, const Color(0xFF00FFA3), 0.3),
            (0.6, 0.02, 50.0, const Color(0xFF00D4FF), 0.5),
            (0.3, 0.08, 35.0, const Color(0xFF8A2BE2), 0.7),
            (0.8, 0.9, 25.0, const Color(0xFF00FFA3), 0.4),
            (0.4, 0.95, 20.0, const Color(0xFF00D4FF), 0.6),
            (0.7, 0.1, 30.0, const Color(0xFF8A2BE2), 0.8),
            (0.2, 0.8, 40.0, const Color(0xFF00FFA3), 0.2),
            (0.9, 0.3, 15.0, const Color(0xFF00D4FF), 0.9),
          ];
          final (topRatio, leftRatio, size, color, speed) = positions[index];
          return _buildParallaxParticle(
            context,
            topRatio,
            leftRatio,
            size,
            color,
            speed,
          );
        }),

        // Animated floating orbs with rotation
        _buildRotatingOrb(context, 0.25, 0.15, 60, const Color(0xFF00FFA3)),
        _buildRotatingOrb(context, 0.75, 0.85, 45, const Color(0xFF00D4FF)),
        _buildRotatingOrb(context, 0.5, 0.05, 35, const Color(0xFF8A2BE2)),

        // Morphing geometric shapes
        _buildMorphingShape(context, 0.35, 0.7, const Color(0xFF00FFA3), 40, 0),
        _buildMorphingShape(
          context,
          0.65,
          0.25,
          const Color(0xFF00D4FF),
          30,
          1,
        ),
      ],
    );
  }

  Widget _buildParallaxParticle(
    BuildContext context,
    double topRatio,
    double leftRatio,
    double size,
    Color color,
    double parallaxSpeed,
  ) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final scrollOffset = _scrollController.hasClients
            ? _scrollController.offset
            : 0.0;
        final parallaxOffset = scrollOffset * parallaxSpeed;

        return Positioned(
          top: MediaQuery.of(context).size.height * topRatio - parallaxOffset,
          left: MediaQuery.of(context).size.width * leftRatio,
          child: Transform.rotate(
            angle: scrollOffset * 0.001,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: size * 0.5,
                    spreadRadius: size * 0.1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingOrb(
    BuildContext context,
    double topRatio,
    double leftRatio,
    double size,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final scrollOffset = _scrollController.hasClients
            ? _scrollController.offset
            : 0.0;
        final rotationAngle = scrollOffset * 0.002;

        return Positioned(
          top: MediaQuery.of(context).size.height * topRatio,
          left: MediaQuery.of(context).size.width * leftRatio,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: color.withOpacity(0.1), width: 1),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _featuresAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _featuresAnimation.value)),
              child: Opacity(
                opacity: _featuresAnimation.value,
                child: _buildFeatureCard(
                  icon: Icons.timeline_rounded,
                  title: 'Real-Time Simulation',
                  description:
                      'Invest in stocks, ETFs, and more with \$100,000 in virtual cash.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _featuresAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _featuresAnimation.value)),
              child: Opacity(
                opacity: _featuresAnimation.value,
                child: _buildFeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI-Powered Insights',
                  description:
                      'Get personalized tips and market analysis from your AI mentor.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _featuresAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _featuresAnimation.value)),
              child: Opacity(
                opacity: _featuresAnimation.value,
                child: _buildFeatureCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Gamified Challenges',
                  description:
                      'Complete quests, earn rewards, and climb the leaderboards.',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF00FFA3).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF00FFA3), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return Column(
      children: [
        Text(
          'About Finx',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildMissionVisionCard(
                icon: Icons.track_changes_rounded,
                title: 'Our Mission',
                description:
                    'We believe that financial literacy should be accessible, engaging, and fun. Finx transforms complex investment concepts into interactive experiences that anyone can understand and enjoy.',
                color: const Color(0xFF00FFA3),
              ),
            ),
            const SizedBox(width: 24),
            Container(
              width: 1,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF00FFA3).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMissionVisionCard(
                icon: Icons.visibility_rounded,
                title: 'Our Vision',
                description:
                    'To create a generation of confident investors who make informed financial decisions and build wealth through knowledge, practice, and community support.',
                color: const Color(0xFF00D4FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionVisionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      children: [
        Text(
          'How It Works',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 800;
            if (isWeb) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedBuilder(
                    animation: _step1Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _step1Animation.value)),
                        child: Opacity(
                          opacity: _step1Animation.value,
                          child: _buildStepCard(
                            stepNumber: '1',
                            title: 'Sign Up',
                            description:
                                'Create your free account and get \$100,000 in virtual cash to start trading.',
                            icon: Icons.person_add_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _step2Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _step2Animation.value)),
                        child: Opacity(
                          opacity: _step2Animation.value,
                          child: _buildStepCard(
                            stepNumber: '2',
                            title: 'Learn & Practice',
                            description:
                                'Use our AI-powered insights and educational content to make informed decisions.',
                            icon: Icons.school_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _step3Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _step3Animation.value)),
                        child: Opacity(
                          opacity: _step3Animation.value,
                          child: _buildStepCard(
                            stepNumber: '3',
                            title: 'Compete & Grow',
                            description:
                                'Join challenges, climb leaderboards, and build your investment confidence.',
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  AnimatedBuilder(
                    animation: _step1Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _step1Animation.value)),
                        child: Opacity(
                          opacity: _step1Animation.value,
                          child: _buildStepCard(
                            stepNumber: '1',
                            title: 'Sign Up',
                            description:
                                'Create your free account and get \$100,000 in virtual cash to start trading.',
                            icon: Icons.person_add_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _step2Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _step2Animation.value)),
                        child: Opacity(
                          opacity: _step2Animation.value,
                          child: _buildStepCard(
                            stepNumber: '2',
                            title: 'Learn & Practice',
                            description:
                                'Use our AI-powered insights and educational content to make informed decisions.',
                            icon: Icons.school_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _step3Animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _step3Animation.value)),
                        child: Opacity(
                          opacity: _step3Animation.value,
                          child: _buildStepCard(
                            stepNumber: '3',
                            title: 'Compete & Grow',
                            description:
                                'Join challenges, climb leaderboards, and build your investment confidence.',
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return _buildHoverableStepCard(
      stepNumber: stepNumber,
      title: title,
      description: description,
      icon: icon,
      elasticProgress: 1.0, // Always fully visible
    );
  }

  Widget _buildHoverableStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required double elasticProgress,
  }) {
    return _HoverableStepCard(
      stepNumber: stepNumber,
      title: title,
      description: description,
      icon: icon,
      elasticProgress: elasticProgress,
    );
  }

  double _elasticOut(double t) {
    const c4 = (2 * math.pi) / 3; // Using math.pi is more accurate
    return t == 0
        ? 0
        : t == 1
        ? 1
        : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  Widget _buildScrollProgressIndicator(BuildContext context) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final scrollOffset = _scrollController.hasClients
            ? _scrollController.offset
            : 0.0;
        final maxScroll = _scrollController.hasClients
            ? _scrollController.position.maxScrollExtent
            : 1000.0;
        final progress = (scrollOffset / maxScroll).clamp(0.0, 1.0);

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFA3).withOpacity(0.1),
                  const Color(0xFF00D4FF).withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00FFA3).withOpacity(0.8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleSystem(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: List.generate(15, (index) {
        final x = (index * 37.0) % screenSize.width;
        final y = (index * 23.0) % screenSize.height;
        final size = 2.0 + (index % 3) * 1.0;
        final opacity = 0.1 + (index % 4) * 0.05;

        final colors = [
          const Color(0xFF00FFA3),
          const Color(0xFF00D4FF),
          const Color(0xFF8A2BE2),
        ];
        final color = colors[index % colors.length];

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(opacity * 0.5),
                  blurRadius: size * 2,
                  spreadRadius: size * 0.5,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Professional Developer Credit Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFA3).withOpacity(0.1),
                  const Color(0xFF00E676).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00FFA3).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Animated Developer Badge
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FFA3), Color(0xFF00E676)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFA3).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.code, color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Developed by Anand B',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // GitHub Link with Hover Effect
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              // Add your GitHub URL here
                              // You can use url_launcher package to open GitHub
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: const Color(0xFF00FFA3),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GitHub Profile',
                                    style: TextStyle(
                                      color: const Color(0xFF00FFA3),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Last Updated Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.update,
                        color: const Color(0xFF00FFA3),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last updated: ${_getLastUpdatedDate()}',
                        style: TextStyle(
                          color: const Color(0xFF00FFA3).withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Copyright with Professional Styling
                Text(
                  '© 2025 Finx. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn to Invest, The Fun Way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF00FFA3).withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPitch(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ready to build your confidence and master your financial future?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFA3).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Sign Up Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HoverableStepCard extends StatefulWidget {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final double elasticProgress;

  const _HoverableStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.elasticProgress,
  });

  @override
  State<_HoverableStepCard> createState() => _HoverableStepCardState();
}

class _HoverableStepCardState extends State<_HoverableStepCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
              padding: EdgeInsets.all(28 + (widget.elasticProgress * 8)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.08 + (widget.elasticProgress * 0.06),
                ),
                borderRadius: BorderRadius.circular(
                  20 + (widget.elasticProgress * 10),
                ),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF00FFA3).withOpacity(0.6)
                      : const Color(
                          0xFF00FFA3,
                        ).withOpacity(0.2 + (widget.elasticProgress * 0.3)),
                  width: _isHovered ? 2 : 1 + (widget.elasticProgress * 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.1 + (widget.elasticProgress * 0.15),
                    ),
                    blurRadius: _isHovered
                        ? 25
                        : 15 + (widget.elasticProgress * 20),
                    spreadRadius: 0,
                    offset: Offset(
                      0,
                      _isHovered ? 12 : 6 + (widget.elasticProgress * 8),
                    ),
                  ),
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0xFF00FFA3).withOpacity(0.4)
                        : const Color(
                            0xFF00FFA3,
                          ).withOpacity(widget.elasticProgress * 0.2),
                    blurRadius: _isHovered ? 40 : 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Transform.scale(
                    scale: 0.8 + (widget.elasticProgress * 0.2),
                    child: Container(
                      width: 70 + (widget.elasticProgress * 20),
                      height: 70 + (widget.elasticProgress * 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00FFA3),
                            const Color(0xFF00D4FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered
                                ? const Color(0xFF00FFA3).withOpacity(0.6)
                                : const Color(0xFF00FFA3).withOpacity(
                                    0.3 + (widget.elasticProgress * 0.2),
                                  ),
                            blurRadius: _isHovered
                                ? 25
                                : 15 + (widget.elasticProgress * 10),
                            spreadRadius: 0,
                            offset: Offset(
                              0,
                              _isHovered ? 8 : 4 + (widget.elasticProgress * 4),
                            ),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.stepNumber,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26 + (widget.elasticProgress * 4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 + (widget.elasticProgress * 8)),
                  Transform.rotate(
                    angle: widget.elasticProgress * 0.2,
                    child: Container(
                      padding: EdgeInsets.all(
                        16 + (widget.elasticProgress * 4),
                      ),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? const Color(0xFF00FFA3).withOpacity(0.2)
                            : const Color(0xFF00FFA3).withOpacity(
                                0.1 + (widget.elasticProgress * 0.1),
                              ),
                        borderRadius: BorderRadius.circular(
                          16 + (widget.elasticProgress * 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered
                                ? const Color(0xFF00FFA3).withOpacity(0.5)
                                : const Color(
                                    0xFF00FFA3,
                                  ).withOpacity(widget.elasticProgress * 0.3),
                            blurRadius: _isHovered ? 16 : 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF00FFA3),
                        size: 36 + (widget.elasticProgress * 4),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 + (widget.elasticProgress * 4)),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20 + (widget.elasticProgress * 2),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16 + (widget.elasticProgress * 2)),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14 + (widget.elasticProgress * 1),
                      color: Colors.white.withOpacity(
                        0.7 + (widget.elasticProgress * 0.1),
                      ),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdvancedGridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add enhanced dots at intersections
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // Add diagonal lines for extra depth
    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += spacing * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.width, size.height),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FullPageGridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    const double spacing = 60.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add subtle dots at intersections
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MorphingShapePainter extends CustomPainter {
  final Color color;
  final double morphValue;
  final int shapeType;

  MorphingShapePainter({
    required this.color,
    required this.morphValue,
    required this.shapeType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (shapeType) {
      case 0: // Triangle to Circle
        _drawTriangleToCircle(canvas, center, radius, paint, strokePaint);
        break;
      case 1: // Square to Hexagon
        _drawSquareToHexagon(canvas, center, radius, paint, strokePaint);
        break;
      case 2: // Diamond to Star
        _drawDiamondToStar(canvas, center, radius, paint, strokePaint);
        break;
    }
  }

  void _drawTriangleToCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint strokePaint,
  ) {
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle) * (1 - morphValue * 0.3);
      final y = center.dy + radius * math.sin(angle) * (1 - morphValue * 0.3);
      points.add(Offset(x, y));
    }

    if (morphValue > 0.5) {
      // Draw circle
      canvas.drawCircle(center, radius * morphValue, paint);
      canvas.drawCircle(center, radius * morphValue, strokePaint);
    } else {
      // Draw triangle
      path.moveTo(points[0].dx, points[0].dy);
      path.lineTo(points[1].dx, points[1].dy);
      path.lineTo(points[2].dx, points[2].dy);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawSquareToHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint strokePaint,
  ) {
    final path = Path();
    final sides = morphValue > 0.5 ? 6 : 4;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 4;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawDiamondToStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint strokePaint,
  ) {
    final path = Path();
    final points = <Offset>[];
    final spikes = morphValue > 0.5 ? 5 : 4;

    for (int i = 0; i < spikes; i++) {
      final angle = (i * 2 * math.pi / spikes) - math.pi / 2;
      final outerRadius = radius;
      final innerRadius = radius * 0.4 * morphValue;

      // Outer point
      final outerX = center.dx + outerRadius * math.cos(angle);
      final outerY = center.dy + outerRadius * math.sin(angle);
      points.add(Offset(outerX, outerY));

      // Inner point (for star)
      if (morphValue > 0.5) {
        final innerAngle = angle + math.pi / spikes;
        final innerX = center.dx + innerRadius * math.cos(innerAngle);
        final innerY = center.dy + innerRadius * math.sin(innerAngle);
        points.add(Offset(innerX, innerY));
      }
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
