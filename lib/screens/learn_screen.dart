// lib/screens/learn_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:animations/animations.dart';

import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

// Mock screen imports - replace with your actual screen files if names differ
import 'portfolio_simulator_screen.dart';
import 'risk_calculator_screen.dart';
import 'chart_analysis_screen.dart';
import 'quiz_center_screen.dart';
import 'mascot_tutorial_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<String> _categories = [
    'All',
    'Stocks',
    'ETFs',
    'Options',
    'Crypto',
    'Real Estate',
    'Bonds',
    'Futures',
  ];
  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.primary.withOpacity(0.03),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildStatsSection(),
            _buildMascotSection(),
            _buildInteractiveTools(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
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
                  Icon(
                    Icons.school_outlined,
                    color: LiquidMaterialTheme.neonAccent(context),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Learn & Grow',
                    style: LiquidTextStyle.headlineMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard('Progress', '0%', Icons.trending_up),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Lessons', '0', Icons.book)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '0 days',
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return LiquidCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: LiquidMaterialTheme.neonAccent(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(value, style: LiquidTextStyle.titleLarge(context)),
            const SizedBox(height: 4),
            Text(title, style: LiquidTextStyle.bodyMedium(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LiquidCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidMaterialTheme.neonAccent(context),
                          const Color(0xFF00E676),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Learning Assistant',
                          style: LiquidTextStyle.titleMedium(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Personalized learning recommendations.',
                          style: LiquidTextStyle.bodyMedium(context),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MascotTutorialScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: LiquidMaterialTheme.neonAccent(context),
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

  Widget _buildInteractiveTools() {
    final tools = _getInteractiveTools();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final tool = tools[index];
          return FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Interval(0.2 * index, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: _buildToolCard(tool),
            ),
          );
        }, childCount: tools.length),
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return LiquidCard(
      onTap: () => _navigateToTool(tool['name'] as String),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tool['color1'] as Color, tool['color2'] as Color],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (tool['color1'] as Color).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                tool['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                tool['name'] as String,
                style: LiquidTextStyle.titleMedium(
                  context,
                ).copyWith(fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                tool['description'] as String,
                style: LiquidTextStyle.bodyMedium(
                  context,
                ).copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTool(String toolName) {
    Widget? destination;
    switch (toolName) {
      case 'Portfolio Simulator':
        destination = const PortfolioSimulatorScreen();
        break;
      case 'Risk Calculator':
        destination = const RiskCalculatorScreen();
        break;
      case 'Chart Analysis':
        destination = const ChartAnalysisScreen();
        break;
      case 'Quiz Center':
        destination = const QuizCenterScreen();
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination!,
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
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }

  List<Map<String, dynamic>> _getInteractiveTools() {
    return [
      {
        'name': 'Portfolio Simulator',
        'description': 'Practice with virtual money',
        'icon': Icons.account_balance_wallet,
        'color1': const Color(0xFF00E676),
        'color2': LiquidMaterialTheme.neonAccent(context),
      },
      {
        'name': 'Risk Calculator',
        'description': 'Calculate investment risk',
        'icon': Icons.calculate,
        'color1': const Color(0xFFFF9800),
        'color2': const Color(0xFFFF5722),
      },
      {
        'name': 'Chart Analysis',
        'description': 'Analyze market charts',
        'icon': Icons.show_chart,
        'color1': const Color(0xFF4ECDC4),
        'color2': const Color(0xFF2196F3),
      },
      {
        'name': 'Quiz Center',
        'description': 'Test your knowledge',
        'icon': Icons.quiz,
        'color1': const Color(0xFFE91E63),
        'color2': const Color(0xFF9C27B0),
      },
    ];
  }
}
