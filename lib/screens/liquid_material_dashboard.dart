// lib/screens/liquid_material_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import '../services/enhanced_portfolio_provider.dart';
import '../services/gemini_ai_service.dart';
import '../services/real_time_data_service.dart';
import '../services/news_service.dart';
import 'full_news_screen.dart';
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../widgets/liquid_sparkline_chart.dart';
import 'trade_screen.dart';
import 'analytics_screen.dart';
import 'learn_screen.dart';
import 'leaderboard_screen.dart';
import 'quests_screen.dart';
import 'achievements_screen.dart';
import 'portfolio_screen.dart';
import 'ai_mentor_screen.dart';

// IMPROVEMENT: Typography now pulls colors from the theme for Material You compatibility.
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

/// 🎨 Advanced Particle System
class Particle {
  double x, y, vx, vy, size, opacity, life;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.life,
    required this.color,
  });

  void update({
    double? dailyChangePercent,
    Color? gainColor,
    Color? lossColor,
  }) {
    x += vx;
    y += vy;
    life -= 0.01;
    opacity = (life > 0 ? life : 0).clamp(0.0, 1.0).toDouble();
    size *= 0.999;

    // ENHANCED: Data-driven particle physics and color with more dramatic effects
    if (dailyChangePercent != null) {
      if (dailyChangePercent > 1.0) {
        vy -= 0.01; // More pronounced upward drift on gains
        if (dailyChangePercent > 2.0 && gainColor != null) {
          color = Color.lerp(color, gainColor, 0.2)!; // Stronger color shift
        }
      } else if (dailyChangePercent < -1.0) {
        vy += 0.01; // More pronounced downward drift on losses
        if (dailyChangePercent < -2.0 && lossColor != null) {
          color = Color.lerp(color, lossColor, 0.2)!; // Stronger color shift
        }
      }

      // Add horizontal drift based on volatility
      if (dailyChangePercent.abs() > 3.0) {
        vx +=
            (math.Random().nextDouble() - 0.5) *
            0.02; // Random horizontal drift
      }
    }
  }

  bool isDead() => life <= 0 || size <= 0.1;
}

/// 🎨 Advanced Particle Painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    for (final particle in particles) {
      paint.color = particle.color.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 🌊 LIQUID MATERIAL DASHBOARD
class LiquidMaterialDashboard extends StatefulWidget {
  const LiquidMaterialDashboard({super.key});

  @override
  State<LiquidMaterialDashboard> createState() =>
      _LiquidMaterialDashboardState();
}

class _LiquidMaterialDashboardState extends State<LiquidMaterialDashboard>
    with TickerProviderStateMixin {
  // --- Layout Constants ---
  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 24.0);

  // --- Animation Controllers ---
  late final AnimationController _fadeController;
  late final AnimationController _auroraController;
  late final AnimationController _glowController;
  late final AnimationController _pillAnimationController;
  late final AnimationController _valueAnimationController;
  late final AnimationController _loadingController;
  late final AnimationController _blurController;

  // IMPROVEMENT: Physics-based tilt now uses its own dedicated controller.
  late final AnimationController _tiltController;
  late final AnimationController _magneticController;
  late final AnimationController _rippleController;

  // --- Animations ---
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowAnimation;
  late Animation<double> _pillAnimation;
  late final Animation<double> _blurAnimation;
  late final Animation<double> _valueAnimation;
  late final Animation<double> _magneticAnimation;
  late final Animation<double> _rippleAnimation;

  // --- Physics and Interaction State ---
  // IMPROVEMENT: State for physics simulation.
  SpringSimulation? _xSpring, _ySpring;
  Offset _tilt = Offset.zero;

  // IMPROVEMENT: Use a ValueNotifier for scroll delta to prevent rebuilding the whole screen.
  final ValueNotifier<double> _scrollDeltaNotifier = ValueNotifier(0.0);

  // --- Loading Narrative State ---
  bool _isLoading = true;
  bool _showSyncingText = false;

  // --- Gamification State (for quests) ---
  int _questProgress = 1;
  final int _questGoal = 3;
  bool _isQuestComplete = false;

  // --- User Profile State ---
  String get _userEmail {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'user@example.com';
  }

  String get _userName {
    return _extractNameFromEmail(_userEmail);
  }

  String _extractNameFromEmail(String email) {
    try {
      // Extract name from email: xyz@gmail.com -> xyz
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty && emailParts[0].isNotEmpty) {
        final username = emailParts[0];
        // Handle cases like "john.doe" -> "John Doe"
        if (username.contains('.')) {
          final nameParts = username.split('.');
          return nameParts
              .map(
                (part) => part.isNotEmpty
                    ? part[0].toUpperCase() + part.substring(1).toLowerCase()
                    : '',
              )
              .join(' ');
        }
        // Convert to title case: xyz -> Xyz
        return username[0].toUpperCase() + username.substring(1).toLowerCase();
      }
    } catch (e) {
      // Fallback if parsing fails
    }
    return 'User';
  }

  // --- Particle System ---
  List<Particle> _particles = [];
  Timer? _particleTimer;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pillAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pillAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _valueAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _valueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _valueAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOutCubic),
    );

    _tiltController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        )..addListener(() {
          setState(() {
            _tilt = Offset(
              _xSpring?.x(_tiltController.value) ?? 0,
              _ySpring?.x(_tiltController.value) ?? 0,
            );
          });
        });

    _magneticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _magneticAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _magneticController, curve: Curves.easeOutCubic),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _auroraController.repeat(reverse: true);
    _glowController.repeat(reverse: true);

    _startLoadingSequence();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeParticles();
      _startParticleSystem();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _auroraController.dispose();
    _glowController.dispose();
    _pillAnimationController.dispose();
    _valueAnimationController.dispose();
    _loadingController.dispose();
    _blurController.dispose();
    _tiltController.dispose();
    _magneticController.dispose();
    _rippleController.dispose();
    _scrollDeltaNotifier.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _initializeParticles() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    _particles = List.generate(50, (_) => _createParticle(size));
  }

  Particle _createParticle(Size size) {
    return Particle(
      x: math.Random().nextDouble() * size.width,
      y: math.Random().nextDouble() * size.height,
      vx: (math.Random().nextDouble() - 0.5) * 0.8, // More varied speed
      vy: (math.Random().nextDouble() - 0.5) * 0.8,
      size: math.Random().nextDouble() * 4.0 + 0.5, // More varied size
      opacity: math.Random().nextDouble() * 0.6 + 0.1,
      life: math.Random().nextDouble() * 1.5 + 0.5,
      color: LiquidMaterialTheme.neonAccent(context),
    );
  }

  void _startParticleSystem() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      final portfolio = Provider.of<EnhancedPortfolioProvider>(
        context,
        listen: false,
      );
      final size = MediaQuery.of(context).size;

      setState(() {
        for (var particle in _particles) {
          // Mouse interaction - repel particles near cursor
          final distance = math.sqrt(
            math.pow(particle.x - _mousePosition.dx, 2) +
                math.pow(particle.y - _mousePosition.dy, 2),
          );
          if (distance < 100) {
            final repelForce = (100 - distance) / 100 * 0.02;
            final dx = particle.x - _mousePosition.dx;
            final dy = particle.y - _mousePosition.dy;
            particle.vx += dx * repelForce / distance;
            particle.vy += dy * repelForce / distance;
          }

          particle.update(
            dailyChangePercent: portfolio.dayGainPercent,
            gainColor: Theme.of(context).colorScheme.primary,
            lossColor: Theme.of(context).colorScheme.error,
          );
        }
        _particles.removeWhere((p) => p.isDead());
        if (_particles.length < 50) {
          _particles.add(_createParticle(size));
        }
      });
    });
  }

  // --- Interaction & Animation Logic ---

  void _animatePill({double changeMagnitude = 0.0}) {
    final intensity = (1.0 + (changeMagnitude.abs() * 0.05)).clamp(1.05, 1.3);
    setState(() {
      _pillAnimation = Tween<double>(begin: 1.0, end: intensity).animate(
        CurvedAnimation(
          parent: _pillAnimationController,
          curve: Curves.elasticOut,
        ),
      );
    });

    _pillAnimationController.forward(from: 0.0);
  }

  void _startCardTilt(Offset localPosition, Size cardSize) {
    final targetX =
        (localPosition.dy / cardSize.height - 0.5) *
        -0.3; // Increased tilt range
    final targetY = (localPosition.dx / cardSize.width - 0.5) * 0.3;

    _xSpring = SpringSimulation(
      const SpringDescription(
        mass: 0.8,
        stiffness: 200,
        damping: 25,
      ), // More responsive
      _tilt.dx,
      targetX,
      0,
    );
    _ySpring = SpringSimulation(
      const SpringDescription(mass: 0.8, stiffness: 200, damping: 25),
      _tilt.dy,
      targetY,
      0,
    );

    _tiltController.forward(from: 0);
  }

  void _resetCardTilt() {
    _xSpring = SpringSimulation(
      const SpringDescription(
        mass: 0.8,
        stiffness: 120,
        damping: 18,
      ), // More responsive reset
      _tilt.dx,
      0,
      0,
    );
    _ySpring = SpringSimulation(
      const SpringDescription(mass: 0.8, stiffness: 120, damping: 18),
      _tilt.dy,
      0,
      0,
    );
    _tiltController.forward(from: 0);
  }

  void _startLoadingSequence() async {
    // Step 1: Fade in background and particles
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Show "Syncing with markets..." message
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showSyncingText = true);

    // Step 3: Start blur animation and value counting
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _showSyncingText = false);
      _blurController.forward();
      _valueAnimationController.forward();
    }

    // Step 4: Wait for value to be revealed, then fade in main content
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController
          .forward(); // Fade in the main content with staggered animation
    }
  }

  void _navigateWithFluidTransition(Widget destination) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            // --- Background Layers ---
            _buildAuroraBackground(),
            CustomPaint(
              painter: ParticlePainter(_particles),
              size: Size.infinite,
            ),

            // --- Main UI ---
            Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: _buildLiquidFAB(),
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: MouseRegion(
                    onHover: (event) {
                      _mousePosition = event.localPosition;
                    },
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (notification) {
                        _scrollDeltaNotifier.value =
                            notification.scrollDelta ?? 0.0;
                        return false;
                      },
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildLiquidAppBar(),
                          _buildHeroPortfolioCard(),
                          _buildSectionHeader(context, "Quick Actions"),
                          _buildQuickActionCards(),
                          _buildAPITestButton(),
                          _buildSectionHeader(context, "Your Holdings"),
                          _buildHoldingsCard(),
                          _buildSectionHeader(
                            context,
                            "Market Movers",
                            withRefresh: true,
                          ),
                          _buildMarketMoversSection(),
                          _buildSectionHeader(context, "Financial News"),
                          _buildNewsSection(),
                          _buildSectionHeader(context, "Daily Quests"),
                          _buildDailyQuestsSection(),
                          _buildSectionHeader(context, "Recent Achievements"),
                          _buildAchievementsSection(),
                          _buildSignOutButton(),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Widget Builder Methods ---

  Widget _buildAuroraBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF000000), // Super dark black
                Color(0xFF000000), // Super dark black
                Color(0xFF000000), // Super dark black
                Color(0xFF000000), // Super dark black
              ],
            ),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _buildSectionHeader(
    BuildContext context,
    String title, {
    bool withRefresh = false,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: LiquidTextStyle.headlineMedium(context)),
            if (withRefresh)
              IconButton(
                icon: _isRefreshingMarketMovers
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                onPressed: _isRefreshingMarketMovers
                    ? null
                    : _refreshMarketMovers,
              ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildLiquidAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: LiquidMaterialTheme.darkSpaceBackground(
                context,
              ).withOpacity(0.5),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidMaterialTheme.neonAccent(context),
                          LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: LiquidTextStyle.titleLarge(context).copyWith(
                          color: LiquidMaterialTheme.darkSpaceBackground(
                            context,
                          ),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome back, $_userName!',
                          style: LiquidTextStyle.titleMedium(context),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            'Ready to invest in the future?',
                            style: LiquidTextStyle.bodyLarge(
                              context,
                            ).copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Last updated: ${_formatLastUpdated()}',
                                style: LiquidTextStyle.bodyMedium(context)
                                    .copyWith(
                                      fontSize: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.7),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPortfolioCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _horizontalPadding,
        child: Consumer<EnhancedPortfolioProvider>(
          builder: (context, portfolio, child) {
            final totalValue = portfolio.totalValue;
            final dayGain = portfolio.dayGain;
            final dayGainPercent = portfolio.dayGainPercent;
            return LiquidCard(
              onTap: () =>
                  _navigateWithFluidTransition(const PortfolioScreen()),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 200,
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return LiquidSparklineChart(
                              data: _generateSamplePriceData(
                                totalValue > 0 ? totalValue : 100000.0,
                              ),
                              lineColor: dayGain >= 0 || totalValue == 0
                                  ? LiquidMaterialTheme.neonAccent(context)
                                  : const Color(0xFFFF5277),
                              fillColor: dayGain >= 0 || totalValue == 0
                                  ? LiquidMaterialTheme.neonAccent(
                                      context,
                                    ).withOpacity(0.4)
                                  : const Color(0xFFFF5277).withOpacity(0.1),
                              showLiveIndicator: true,
                              glowAnimationValue: _glowAnimation.value,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Value',
                          style: LiquidTextStyle.bodyLarge(context),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _blurAnimation,
                          builder: (context, child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: totalValue > 0 ? totalValue : 100000.0,
                              ),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: _blurAnimation.value,
                                    sigmaY: _blurAnimation.value,
                                  ),
                                  child: Text(
                                    NumberFormat.currency(
                                      symbol: '\$',
                                      decimalDigits: 2,
                                    ).format(value),
                                    style: LiquidTextStyle.headlineLarge(
                                      context,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (_showSyncingText)
                          AnimatedOpacity(
                            opacity: _showSyncingText ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Syncing with markets...',
                                style: LiquidTextStyle.bodyMedium(context)
                                    .copyWith(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _pillAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pillAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (dayGain >= 0 || totalValue == 0
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.error)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        (dayGain >= 0 || totalValue == 0
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.error)
                                            .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      dayGain >= 0 || totalValue == 0
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      color: dayGain >= 0 || totalValue == 0
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).colorScheme.error,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      totalValue > 0
                                          ? '${dayGain >= 0 ? '+' : ''}\$${dayGain.abs().toStringAsFixed(2)} (${dayGainPercent >= 0 ? '+' : ''}${dayGainPercent.toStringAsFixed(1)}%) Today'
                                          : '\$0.00 (0.0%) Today',
                                      style: LiquidTextStyle.bodyMedium(context)
                                          .copyWith(
                                            color:
                                                dayGain >= 0 || totalValue == 0
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionCards() {
    return SliverPadding(
      padding: _horizontalPadding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildListDelegate([
          Consumer<EnhancedPortfolioProvider>(
            builder: (context, portfolio, child) => _buildQuickActionCard(
              icon: Icons.trending_up,
              title: 'Trade',
              subtitle: _getTradeSubtitle(portfolio),
              onTap: () async {
                // Get real-time stock data for AAPL
                final stockData = await portfolio.fetchStockData('AAPL');
                _navigateWithFluidTransition(
                  TradeScreen(
                    stockData: {
                      'symbol': 'AAPL',
                      'name': 'Apple Inc.',
                      'price': stockData?.currentPrice ?? 150.25,
                      'currentPrice': stockData?.currentPrice ?? 150.25,
                    },
                  ),
                );
              },
            ),
          ),
          Consumer<EnhancedPortfolioProvider>(
            builder: (context, portfolio, child) => _buildQuickActionCard(
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              subtitle: _getAnalyticsSubtitle(portfolio),
              onTap: () =>
                  _navigateWithFluidTransition(const AnalyticsScreen()),
            ),
          ),
          _buildQuickActionCard(
            icon: Icons.school_outlined,
            title: 'Learn',
            subtitle: _getLearnSubtitle(),
            onTap: () => _navigateWithFluidTransition(const LearnScreen()),
          ),
          _buildQuickActionCard(
            icon: Icons.leaderboard_outlined,
            title: 'Leaderboard',
            subtitle: _getLeaderboardSubtitle(),
            onTap: () =>
                _navigateWithFluidTransition(const LeaderboardScreen()),
          ),
        ]),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollDeltaNotifier,
              builder: (context, scrollDelta, child) {
                return Transform.translate(
                  offset:
                      Offset(0, isHovered ? -5 : 0) +
                      Offset(0, scrollDelta * 0.2),
                  child: LiquidCard(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: LiquidMaterialTheme.glassSurface(
                                    context,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          LiquidMaterialTheme.neonAccent(
                                            context,
                                          ).withOpacity(
                                            0.3 + (_glowAnimation.value * 0.2),
                                          ),
                                      blurRadius:
                                          16.0 + (_glowAnimation.value * 8.0),
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      LiquidMaterialTheme.neonAccent(context),
                                      LiquidMaterialTheme.neonAccent(
                                        context,
                                      ).withOpacity(0.7),
                                    ],
                                  ).createShader(bounds),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          Text(
                            title,
                            style: LiquidTextStyle.titleMedium(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: LiquidTextStyle.bodyMedium(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoldingsCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _horizontalPadding,
        child: Consumer<EnhancedPortfolioProvider>(
          builder: (context, portfolio, child) {
            final virtualCash = portfolio.virtualCash;
            return LiquidCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash Balance',
                              style: LiquidTextStyle.bodyMedium(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(
                                symbol: '\$',
                                decimalDigits: 0,
                              ).format(virtualCash),
                              style: LiquidTextStyle.titleLarge(
                                context,
                              ).copyWith(color: const Color(0xFF00E676)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Invested Value',
                              style: LiquidTextStyle.bodyMedium(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$0',
                              style: LiquidTextStyle.titleLarge(
                                context,
                              ).copyWith(color: const Color(0xFF2196F3)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AnimatedBuilder(
                        animation: _valueAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            height: 16.0,
                            child: Stack(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: 0.75),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Container(
                                      width: 200 * value,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF00E676),
                                            Color(0xFF4CAF50),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00E676,
                                            ).withOpacity(0.4),
                                            blurRadius: 8.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return ShaderMask(
                                      shaderCallback: (rect) {
                                        final slidePosition =
                                            _glowAnimation.value;
                                        return LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                          stops: [
                                            (slidePosition - 0.3).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            slidePosition.clamp(0.0, 1.0),
                                            (slidePosition + 0.3).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                          ],
                                        ).createShader(rect);
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF00E676),
                                              Color(0xFF4CAF50),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketMoversSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: _horizontalPadding,
          itemCount: _getMarketMovers().length,
          itemBuilder: (context, index) {
            final stock = _getMarketMovers()[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildMarketMoverCard(stock),
            );
          },
        ),
      ),
    );
  }

  // BUG FIX & IMPROVEMENT: Corrected syntax, removed unnecessary StatefulBuilder, and added physics tilt.
  Widget _buildMarketMoverCard(Map<String, dynamic> stock) {
    return MouseRegion(
      onEnter: (_) => _resetCardTilt(),
      onExit: (_) => _resetCardTilt(),
      child: Builder(
        builder: (context) {
          final cardSize = (context.findRenderObject() as RenderBox?)?.size;
          return MouseRegion(
            onHover: (event) {
              if (cardSize != null) {
                _startCardTilt(event.localPosition, cardSize);
              }
            },
            onExit: (_) => _resetCardTilt(),
            child: AnimatedBuilder(
              animation: _tiltController,
              builder: (context, child) => Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tilt.dx)
                  ..rotateY(_tilt.dy),
                alignment: FractionalOffset.center,
                child: AnimatedScale(
                  scale: _tilt != Offset.zero ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollDeltaNotifier,
                    builder: (context, scrollDelta, child) {
                      return Transform.translate(
                        offset: Offset(0, scrollDelta * 0.2),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 160,
                      child: Consumer<EnhancedPortfolioProvider>(
                        builder: (context, portfolio, child) {
                          return LiquidCard(
                            onTap: () => _navigateWithFluidTransition(
                              TradeScreen(
                                stockData: {
                                  'symbol': stock['symbol'],
                                  'name': stock['name'],
                                  'price': portfolio.getCurrentPrice(
                                    stock['symbol'],
                                  ),
                                  'currentPrice': portfolio.getCurrentPrice(
                                    stock['symbol'],
                                  ),
                                },
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          stock['symbol'],
                                          style: LiquidTextStyle.titleMedium(
                                            context,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stock['changePercent'] >= 0
                                                ? LiquidMaterialTheme.neonAccent(
                                                    context,
                                                  ).withOpacity(0.2)
                                                : const Color(
                                                    0xFFFF5277,
                                                  ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${stock['changePercent'] >= 0 ? '+' : ''}${stock['changePercent'].toStringAsFixed(1)}%',
                                            style:
                                                LiquidTextStyle.labelMedium(
                                                  context,
                                                ).copyWith(
                                                  color:
                                                      stock['changePercent'] >=
                                                          0
                                                      ? const Color(0xFF00E676)
                                                      : const Color(0xFFFF5277),
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stock['name'],
                                    style: LiquidTextStyle.bodyMedium(
                                      context,
                                    ).copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _glowAnimation,
                                      builder: (context, child) {
                                        return LiquidSparklineChart(
                                          data: _generateSamplePriceData(
                                            stock['price'],
                                          ),
                                          lineColor: stock['changePercent'] >= 0
                                              ? const Color(0xFF00E676)
                                              : const Color(0xFFFF5277),
                                          fillColor:
                                              (stock['changePercent'] >= 0
                                                      ? const Color(0xFF00E676)
                                                      : const Color(0xFFFF5277))
                                                  .withOpacity(0.1),
                                          showLiveIndicator: true,
                                          glowAnimationValue:
                                              _glowAnimation.value,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${stock['price'].toStringAsFixed(2)}',
                                    style: LiquidTextStyle.titleMedium(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ENHANCED: Interactive, stateful quest card with celebration effects
  Widget _buildDailyQuestsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: StatefulBuilder(
          builder: (context, setState) {
            final quest = _getDailyQuests().first;
            final isComplete = _questProgress >= _questGoal;

            return LiquidCard(
              onTap: () {
                if (isComplete) {
                  // Claim reward logic with celebration
                  HapticFeedback.heavyImpact();
                  _animatePill(
                    changeMagnitude: 5.0,
                  ); // Trigger celebration animation
                  setState(() {
                    _questProgress = 0; // Reset quest
                    _isQuestComplete = false;
                  });
                } else {
                  // Simulate progress with haptic feedback
                  HapticFeedback.lightImpact();
                  _animatePill(
                    changeMagnitude: 1.0,
                  ); // Trigger progress animation
                  setState(() {
                    _questProgress++;
                    if (_questProgress >= _questGoal) {
                      _isQuestComplete = true;
                      HapticFeedback.mediumImpact(); // Special feedback for completion
                    }
                  });
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isComplete
                    ? _buildQuestCompleteState(context, quest)
                    : _buildQuestInProgressState(context, quest),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestInProgressState(
    BuildContext context,
    Map<String, dynamic> quest,
  ) {
    double progress = _questProgress / _questGoal;
    return Padding(
      key: const ValueKey('in_progress'),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.0,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Icon(
                Icons.emoji_events_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${quest['title']} ($_questProgress/$_questGoal)',
                  style: LiquidTextStyle.titleMedium(
                    context,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  quest['description'],
                  style: LiquidTextStyle.bodyMedium(context),
                ),
              ],
            ),
          ),
          // ... XP Pill ...
        ],
      ),
    );
  }

  Widget _buildQuestCompleteState(
    BuildContext context,
    Map<String, dynamic> quest,
  ) {
    return Padding(
      key: const ValueKey('complete'),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Claim ${quest['reward']}',
            style: LiquidTextStyle.titleMedium(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final achievement = _getAchievements()[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: LiquidCard(
            onTap: () =>
                _navigateWithFluidTransition(const AchievementsScreen()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidMaterialTheme.neonAccent(context),
                          LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(achievement['icon'], color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          achievement['title'],
                          style: LiquidTextStyle.titleMedium(
                            context,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement['description'],
                          style: LiquidTextStyle.bodyMedium(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (achievement['isUnlocked'])
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'UNLOCKED',
                          style: LiquidTextStyle.labelSmall(context).copyWith(
                            color: LiquidMaterialTheme.neonAccent(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }, childCount: _getAchievements().length),
    );
  }

  Widget _buildSignOutButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: LiquidCard(
          onTap: () async {
            final shouldSignOut = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: LiquidMaterialTheme.darkSpaceBackground(
                  context,
                ),
                title: Text(
                  'Sign Out',
                  style: LiquidTextStyle.titleLarge(context),
                ),
                content: Text(
                  'Are you sure you want to sign out?',
                  style: LiquidTextStyle.bodyMedium(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: LiquidTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Sign Out',
                      style: LiquidTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: const Color(0xFFFF5277)),
                    ),
                  ),
                ],
              ),
            );

            if (shouldSignOut == true) {
              try {
                // Sign out from Firebase Auth
                await FirebaseAuth.instance.signOut();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully signed out',
                        style: LiquidTextStyle.bodyMedium(context),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error signing out: $e',
                        style: LiquidTextStyle.bodyMedium(context),
                      ),
                      backgroundColor: const Color(0xFFFF5277),
                    ),
                  );
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF5277),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: LiquidTextStyle.titleMedium(
                    context,
                  ).copyWith(color: const Color(0xFFFF5277)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidFAB() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) {
            setState(() => isHovered = true);
            _magneticController.forward();
          },
          onExit: (_) {
            setState(() => isHovered = false);
            _magneticController.reverse();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Liquid Ripple Effect
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  if (_rippleAnimation.value == 0)
                    return const SizedBox.shrink();
                  return Container(
                    width: 80 + (_rippleAnimation.value * 40),
                    height: 80 + (_rippleAnimation.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .withOpacity(1.0 - _rippleAnimation.value),
                        width: 1.0,
                      ),
                    ),
                  );
                },
              ),
              // Magnetic Hover Effect
              AnimatedBuilder(
                animation: _magneticAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _magneticAnimation.value,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary
                                    .withOpacity(
                                      0.3 + (_glowAnimation.value * 0.2),
                                    ),
                                blurRadius: 20 + (_glowAnimation.value * 15),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary
                                    .withOpacity(
                                      0.1 + (_glowAnimation.value * 0.1),
                                    ),
                                blurRadius: 40 + (_glowAnimation.value * 20),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: AnimatedRotation(
                            turns: isHovered ? 0.125 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: LiquidCard(
                              borderRadius: BorderRadius.circular(28),
                              child: FloatingActionButton(
                                onPressed: () {
                                  _rippleController.forward().then((_) {
                                    _rippleController.reset();
                                  });
                                  _navigateWithFluidTransition(
                                    const AIMentorScreen(),
                                  );
                                },
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                highlightElevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(Icons.auto_awesome, size: 28),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Data Fetching Methods ---

  /// Get real-time stock data from the service
  Future<StockData?> _getRealTimeStockData(String symbol) async {
    try {
      final portfolio = context.read<EnhancedPortfolioProvider>();
      // Use the public method to get stock data
      return portfolio.getStockData(symbol);
    } catch (e) {
      print('Error getting real-time data for $symbol: $e');
      return null;
    }
  }

  String _getTradeSubtitle(EnhancedPortfolioProvider portfolio) {
    final totalValue = portfolio.totalValue;
    if (totalValue > 100000) {
      return 'Advanced Trading';
    } else if (totalValue > 50000) {
      return 'Intermediate Trading';
    } else {
      return 'Beginner Trading';
    }
  }

  String _getAnalyticsSubtitle(EnhancedPortfolioProvider portfolio) {
    final holdingsCount = portfolio.holdings.length;
    if (holdingsCount > 10) {
      return 'Complex Portfolio Analysis';
    } else if (holdingsCount > 5) {
      return 'Multi-Asset Analysis';
    } else {
      return 'Basic Analytics';
    }
  }

  String _getLearnSubtitle() {
    return 'Explore new strategies & insights';
  }

  String _getLeaderboardSubtitle() {
    return 'Compete with top investors';
  }

  List<double> _generateSamplePriceData(double currentPrice) {
    final List<double> data = [];
    final double basePrice = currentPrice * 0.95;
    for (int i = 0; i < 10; i++) {
      final double variation = (i / 10.0) * (currentPrice - basePrice);
      final double randomFactor = (i % 3 == 0) ? 0.02 : -0.01;
      final double price =
          basePrice + variation + (currentPrice * randomFactor);
      data.add(price);
    }
    if (data.isNotEmpty) {
      data[data.length - 1] = currentPrice;
    }
    return data;
  }

  // Market movers data cache
  List<Map<String, dynamic>> _marketMoversCache = [];
  DateTime? _lastMarketMoversUpdate;
  bool _isRefreshingMarketMovers = false;
  DateTime _lastAppUpdate = DateTime.now();

  List<Map<String, dynamic>> _getMarketMovers() {
    // Update every 20 seconds instead of every render
    final now = DateTime.now();
    if (_lastMarketMoversUpdate == null ||
        now.difference(_lastMarketMoversUpdate!).inSeconds > 20) {
      _updateMarketMoversData();
      _lastMarketMoversUpdate = now;
    }

    return _marketMoversCache.isNotEmpty
        ? _marketMoversCache
        : _getDefaultMarketMovers();
  }

  Future<void> _updateMarketMoversData() async {
    // Fetch real-time data for market movers
    final symbols = ['AAPL', 'TSLA', 'NVDA', 'MSFT'];
    final portfolio = context.read<EnhancedPortfolioProvider>();

    final List<Map<String, dynamic>> realTimeData = [];

    for (final symbol in symbols) {
      final stockData = await portfolio.fetchStockData(symbol);
      if (stockData != null) {
        realTimeData.add({
          'symbol': symbol,
          'name': stockData.name,
          'price': stockData.currentPrice,
          'change': stockData.change,
          'changePercent': stockData.changePercent,
          'currentPrice': stockData.currentPrice,
        });
      }
    }

    if (realTimeData.isNotEmpty) {
      _marketMoversCache = realTimeData;
      if (mounted) setState(() {});
    } else {
      // Fallback to default data
      _marketMoversCache = _getDefaultMarketMovers();
    }
  }

  /// Format last updated timestamp
  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastAppUpdate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Refresh market movers data manually
  void _refreshMarketMovers() async {
    if (_isRefreshingMarketMovers) return;

    setState(() {
      _isRefreshingMarketMovers = true;
    });

    try {
      // Force refresh by clearing cache and fetching new data
      _marketMoversCache.clear();
      _lastMarketMoversUpdate = null;

      // Fetch fresh data
      await _updateMarketMoversData();

      // Update timestamp to prevent auto-refresh for a while
      _lastMarketMoversUpdate = DateTime.now();
    } catch (e) {
      print('Error refreshing market movers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingMarketMovers = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultMarketMovers() {
    final now = DateTime.now();
    final random = (now.millisecondsSinceEpoch % 1000) / 1000.0;
    return [
      {
        'symbol': 'AAPL',
        'name': 'Apple Inc.',
        'price': 150.25 + (random - 0.5) * 2.0,
        'change': 2.45 + (random - 0.5) * 1.0,
        'changePercent': 1.66 + (random - 0.5) * 0.5,
      },
      {
        'symbol': 'TSLA',
        'name': 'Tesla Inc.',
        'price': 245.80 + (random - 0.5) * 5.0,
        'change': -5.20 + (random - 0.5) * 2.0,
        'changePercent': -2.07 + (random - 0.5) * 1.0,
      },
      {
        'symbol': 'NVDA',
        'name': 'NVIDIA Corp.',
        'price': 425.30 + (random - 0.5) * 3.0,
        'change': 8.75 + (random - 0.5) * 1.5,
        'changePercent': 2.10 + (random - 0.5) * 0.3,
      },
      {
        'symbol': 'MSFT',
        'name': 'Microsoft Corp.',
        'price': 335.15 + (random - 0.5) * 1.5,
        'change': 1.25 + (random - 0.5) * 0.8,
        'changePercent': 0.37 + (random - 0.5) * 0.2,
      },
    ];
  }

  List<Map<String, dynamic>> _getDailyQuests() {
    return [
      {
        'title': 'Complete 3 Trades',
        'description': 'Make 3 successful trades today',
        'reward': '50 XP',
      },
      {
        'title': 'Analyze Portfolio',
        'description': 'Review your portfolio performance',
        'reward': '25 XP',
      },
      {
        'title': 'Learn New Strategy',
        'description': 'Complete a learning module',
        'reward': '75 XP',
      },
    ];
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {
        'title': 'First Trade',
        'description': 'Completed your first trade',
        'icon': Icons.trending_up,
        'isUnlocked': true,
      },
      {
        'title': 'Portfolio Master',
        'description': 'Reached \$100K portfolio value',
        'icon': Icons.emoji_events,
        'isUnlocked': true,
      },
      {
        'title': 'Risk Taker',
        'description': 'Made 10 high-risk trades',
        'icon': Icons.warning,
        'isUnlocked': false,
      },
    ];
  }

  Widget _buildAPITestButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: LiquidCard(
          onTap: _testAllAPIs,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.api,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test All APIs',
                        style: LiquidTextStyle.titleMedium(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click to test all API connections',
                        style: LiquidTextStyle.bodyMedium(
                          context,
                        ).copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _testAllAPIs() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFA3)),
              ),
              const SizedBox(height: 16),
              Text(
                'Testing all APIs...',
                style: LiquidTextStyle.bodyMedium(context),
              ),
            ],
          ),
        ),
      );

      // Test all APIs
      final testMessage = "Hello, can you help me with my portfolio?";
      final portfolioData = {
        'virtualCash': 100000.0,
        'totalValue': 105000.0,
        'holdings': {'AAPL': 10, 'GOOGL': 5},
        'transactionHistory': [],
      };

      // Test Gemini API
      print('🧪 Testing Gemini API...');
      final geminiResponse = await GeminiAIService.getPortfolioAdvice(
        testMessage,
        portfolioData,
      );

      // Test Finnhub API
      print('🧪 Testing Finnhub API...');
      print(
        '🔑 Finnhub API Key: ${dotenv.env['FINNHUB_API_KEY']?.substring(0, 10)}...',
      );
      final realTimeService = context.read<RealTimeDataService>();
      final stockData = await realTimeService.getStockData('AAPL');
      print(
        '📊 Finnhub response: ${stockData?.symbol} - \$${stockData?.currentPrice}',
      );

      // Test Firebase (if available)
      print('🧪 Testing Firebase connection...');
      final firebaseUser = FirebaseAuth.instance.currentUser;

      final results = {
        'gemini': {
          'status': geminiResponse.contains('trouble')
              ? '❌ Failed'
              : '✅ Working',
          'response': geminiResponse.substring(0, 100) + '...',
        },
        'finnhub': {
          'status': stockData != null ? '✅ Working' : '❌ Failed',
          'response': stockData != null
              ? 'Stock data retrieved successfully'
              : 'Failed to get stock data',
        },
        'firebase': {
          'status': firebaseUser != null ? '✅ Working' : '❌ Failed',
          'response': firebaseUser != null
              ? 'User authenticated'
              : 'No user logged in',
        },
      };

      // Close loading dialog
      Navigator.of(context).pop();

      // Show result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'API Test Result',
                style: LiquidTextStyle.titleMedium(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Test Results:',
                style: LiquidTextStyle.bodyMedium(
                  context,
                ).copyWith(color: Colors.green, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Gemini API Result
              _buildAPIResult('Gemini AI', results['gemini']!),
              const SizedBox(height: 12),
              // Finnhub API Result
              _buildAPIResult('Finnhub Stock Data', results['finnhub']!),
              const SizedBox(height: 12),
              // Firebase Result
              _buildAPIResult('Firebase Auth', results['firebase']!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'API Test Failed',
                style: LiquidTextStyle.titleMedium(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❌ Gemini API connection failed',
                style: LiquidTextStyle.bodyMedium(
                  context,
                ).copyWith(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Error:',
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.toString(),
                  style: LiquidTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAPIResult(String apiName, Map<String, String> result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result['status']!.contains('✅')
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result['status']!.contains('✅')
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                apiName,
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                result['status']!,
                style: LiquidTextStyle.labelSmall(context).copyWith(
                  color: result['status']!.contains('✅')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result['response']!,
            style: LiquidTextStyle.bodyMedium(
              context,
            ).copyWith(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // --- News Section ---
  Widget _buildNewsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _horizontalPadding,
        child: FutureBuilder<List<NewsArticle>>(
          future: context.read<NewsService>().getFinancialNews(
            pageSize: 3,
          ), // Reduced to 3 for better performance
          builder: (context, snapshot) {
            // Show loading only for the first time
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildNewsLoadingCard();
            }

            // Show error state if there's an error and no cached data
            if (snapshot.hasError && !snapshot.hasData) {
              return _buildNewsErrorCard();
            }

            // Show cached data or fallback if no data
            final articles = snapshot.data ?? [];
            if (articles.isEmpty) {
              return _buildNewsErrorCard();
            }

            return Column(
              children: [
                _buildNewsCard(articles[0], isMain: true),
                if (articles.length > 1) ...[
                  const SizedBox(height: 12),
                  ...articles
                      .skip(1)
                      .take(2) // Limit to 2 additional articles
                      .map(
                        (article) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNewsCard(article, isMain: false),
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsLoadingCard() {
    return LiquidCard(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading financial news...',
              style: LiquidTextStyle.bodyMedium(
                context,
              ).copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsErrorCard() {
    return LiquidCard(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Financial News',
              style: LiquidTextStyle.titleMedium(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay updated with the latest market news',
              style: LiquidTextStyle.bodyMedium(
                context,
              ).copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, {required bool isMain}) {
    return LiquidCard(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateWithFluidTransition(const FullNewsScreen());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: isMain
              ? _buildMainNewsCard(article)
              : _buildSecondaryNewsCard(article),
        ),
      ),
    );
  }

  Widget _buildMainNewsCard(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'FEATURED',
                style: LiquidTextStyle.labelSmall(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const Spacer(),
            Text(
              article.timeAgo,
              style: LiquidTextStyle.labelSmall(
                context,
              ).copyWith(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          article.title,
          style: LiquidTextStyle.titleMedium(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          article.description,
          style: LiquidTextStyle.bodyMedium(
            context,
          ).copyWith(color: Colors.white70, height: 1.4),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.source, size: 14, color: Colors.white60),
            const SizedBox(width: 4),
            Text(
              article.source,
              style: LiquidTextStyle.labelSmall(
                context,
              ).copyWith(color: Colors.white60, fontSize: 11),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryNewsCard(NewsArticle article) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: LiquidTextStyle.bodyMedium(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    article.timeAgo,
                    style: LiquidTextStyle.labelSmall(
                      context,
                    ).copyWith(color: Colors.white60, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.source, size: 12, color: Colors.white60),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      article.source,
                      style: LiquidTextStyle.labelSmall(
                        context,
                      ).copyWith(color: Colors.white60, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
