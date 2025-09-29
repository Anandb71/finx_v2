// lib/screens/analytics_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/enhanced_portfolio_provider.dart';
import '../widgets/liquid_card.dart';
import '../widgets/liquid_sparkline_chart.dart';
import '../theme/liquid_material_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _staggerController;
  late final AnimationController _donutController;
  late final AnimationController _glowController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _staggerAnimation;
  late final Animation<double> _donutAnimation;
  late final Animation<double> _glowAnimation;

  // --- State Variables ---
  Offset? _chartHoverPosition;
  int? _hoveredSegmentIndex;
  List<Map<String, dynamic>> _topGainers = [];
  List<Map<String, dynamic>> _topLosers = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // FIX: Fetch initial data here instead of in the build method.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final portfolio = Provider.of<EnhancedPortfolioProvider>(
        context,
        listen: false,
      );
      _updateTopPerformers(portfolio);
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _donutController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic),
    );
    _donutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _donutController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _staggerController.forward();
    _donutController.forward();
    _glowController.repeat(reverse: true);
  }

  List<double> _generatePriceData(double basePrice, bool isGain) {
    final random = math.Random();
    final data = <double>[];
    double currentPrice = basePrice;

    for (int i = 0; i < 20; i++) {
      final variation = (random.nextDouble() - 0.5) * (isGain ? 2 : -2);
      currentPrice += variation;
      data.add(currentPrice);
    }
    return data;
  }

  List<double> _generatePortfolioHistory(EnhancedPortfolioProvider portfolio) {
    // Generate sample data based on current portfolio value
    final currentValue = portfolio.totalValue;
    final List<double> data = [];
    final double baseValue = currentValue * 0.95;

    for (int i = 0; i < 30; i++) {
      final double variation = (i / 30.0) * (currentValue - baseValue);
      final double randomFactor = (i % 3 == 0) ? 0.02 : -0.01;
      final double value =
          baseValue + variation + (currentValue * randomFactor);
      data.add(value);
    }

    if (data.isNotEmpty) {
      data[data.length - 1] = currentValue;
    }

    return data;
  }

  List<Map<String, dynamic>> _getAssetAllocation(
    EnhancedPortfolioProvider portfolio,
  ) {
    final holdings = portfolio.holdings;
    final stockData = portfolio.currentStockData;
    final totalValue = portfolio.totalValue;

    if (totalValue == 0 || holdings.isEmpty) {
      return [
        {'name': 'Cash', 'percentage': 100.0, 'color': const Color(0xFF9C27B0)},
      ];
    }

    final allocation = <Map<String, dynamic>>[];
    final colors = [
      const Color(0xFF00E676),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFFFF5722),
      const Color(0xFF3F51B5),
    ];

    int colorIndex = 0;
    holdings.forEach((symbol, quantity) {
      final stock = stockData[symbol];
      if (stock != null) {
        final value = quantity * stock.currentPrice;
        final percentage = (value / totalValue) * 100;
        allocation.add({
          'name': symbol,
          'percentage': percentage,
          'color': colors[colorIndex % colors.length],
        });
        colorIndex++;
      }
    });

    final cashPercentage = (portfolio.virtualCash / totalValue) * 100;
    if (cashPercentage > 0.1) {
      allocation.add({
        'name': 'Cash',
        'percentage': cashPercentage,
        'color': const Color(0xFF9C27B0),
      });
    }

    return allocation;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _donutController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedPortfolioProvider>(
      builder: (context, portfolio, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.background.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildLiquidAppBar(),
                      _buildPortfolioHistoryCard(portfolio),
                      _buildAssetAllocationCard(portfolio),
                      _buildTopPerformersCard(),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.background.withOpacity(0.9),
                Theme.of(context).colorScheme.background.withOpacity(0.7),
              ],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
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
                              'Analytics',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Portfolio Performance',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary
                                      .withOpacity(_glowAnimation.value * 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Text(
                              'LIVE',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioHistoryCard(EnhancedPortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _staggerAnimation.value)),
              child: Opacity(
                opacity: _staggerAnimation.value,
                child: LiquidCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Portfolio History',
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Consumer<EnhancedPortfolioProvider>(
                            builder: (context, portfolio, child) {
                              return Text(
                                '\$${portfolio.totalValue.toStringAsFixed(2)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.1),
                        ),
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _chartHoverPosition = details.localPosition;
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _chartHoverPosition = null;
                            });
                          },
                          child: Stack(
                            children: [
                              LiquidSparklineChart(
                                data: _generatePortfolioHistory(portfolio),
                                height: 300,
                                lineColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                strokeWidth: 3,
                                showLiveIndicator: true,
                                glowAnimationValue: _glowAnimation.value,
                              ),
                              if (_chartHoverPosition != null)
                                Positioned(
                                  left: _chartHoverPosition!.dx - 50,
                                  top: _chartHoverPosition!.dy - 30,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Value: \$${(_generatePortfolioHistory(portfolio).last).toStringAsFixed(2)}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
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
  }

  Widget _buildAssetAllocationCard(EnhancedPortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _staggerAnimation.value)),
              child: Opacity(
                opacity: _staggerAnimation.value,
                child: LiquidCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset Allocation',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: AnimatedBuilder(
                          animation: _donutAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: DonutChartPainter(
                                data: _getAssetAllocation(portfolio),
                                animationValue: _donutAnimation.value,
                                hoveredIndex: _hoveredSegmentIndex,
                                glowValue: _glowAnimation.value,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    Consumer<EnhancedPortfolioProvider>(
                                      builder: (context, portfolio, child) {
                                        return Text(
                                          '\$${portfolio.totalValue.toStringAsFixed(0)}',
                                          style: GoogleFonts.manrope(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(portfolio),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(EnhancedPortfolioProvider portfolio) {
    return Column(
      children: _getAssetAllocation(portfolio).asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isHovered = _hoveredSegmentIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _hoveredSegmentIndex = _hoveredSegmentIndex == index
                  ? null
                  : index;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHovered
                  ? item['color'].withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? item['color']
                    : Colors.white.withOpacity(0.2),
                width: isHovered ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: item['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['name'],
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${item['percentage'].toStringAsFixed(1)}%',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopPerformersCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _staggerAnimation.value)),
              child: Opacity(
                opacity: _staggerAnimation.value,
                child: LiquidCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Movers',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMoversSection('Top Gainers', _topGainers, true),
                      const SizedBox(height: 20),
                      _buildMoversSection('Top Losers', _topLosers, false),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoversSection(
    String title,
    List<Map<String, dynamic>> data,
    bool isGainers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        ...data.map((item) => _buildMoverItem(item, isGainers)).toList(),
      ],
    );
  }

  Widget _buildMoverItem(Map<String, dynamic> item, bool isGainers) {
    final change = item['changePercent'] as double;
    final color = isGainers
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['symbol'],
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${item['price'].toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 40,
            child: LiquidSparklineChart(
              data: item['data'],
              height: 40,
              lineColor: color,
              fillColor: color.withOpacity(0.2),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTopPerformers(EnhancedPortfolioProvider portfolio) {
    // Generate mock top performers data
    setState(() {
      _topGainers = [
        {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'price': 175.43,
          'change': 2.34,
          'data': [170.0, 172.0, 171.5, 173.0, 175.43],
        },
        {
          'symbol': 'GOOGL',
          'name': 'Alphabet Inc.',
          'price': 142.67,
          'change': 1.89,
          'data': [140.0, 141.0, 140.5, 142.0, 142.67],
        },
        {
          'symbol': 'MSFT',
          'name': 'Microsoft Corp.',
          'price': 378.85,
          'change': 1.56,
          'data': [370.0, 372.0, 371.5, 375.0, 378.85],
        },
      ];

      _topLosers = [
        {
          'symbol': 'TSLA',
          'name': 'Tesla Inc.',
          'price': 245.12,
          'change': -3.45,
          'data': [250.0, 248.0, 246.0, 244.0, 245.12],
        },
        {
          'symbol': 'AMZN',
          'name': 'Amazon.com Inc.',
          'price': 155.89,
          'change': -2.12,
          'data': [158.0, 157.0, 156.5, 155.0, 155.89],
        },
        {
          'symbol': 'META',
          'name': 'Meta Platforms Inc.',
          'price': 489.34,
          'change': -1.78,
          'data': [495.0, 492.0, 490.0, 488.0, 489.34],
        },
      ];
    });
  }
}

class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double animationValue;
  final int? hoveredIndex;
  final double glowValue;

  DonutChartPainter({
    required this.data,
    required this.animationValue,
    this.hoveredIndex,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final percentage = item['percentage'] as double;
      final sweepAngle = (percentage / 100) * 2 * math.pi * animationValue;
      final color = item['color'] as Color;
      final isHovered = hoveredIndex == i;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      if (isHovered) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Inner circle to create donut effect
      canvas.drawCircle(
        center,
        innerRadius,
        Paint()
          ..color = const Color(0xFF0F0F23)
          ..style = PaintingStyle.fill,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DonutChartPainter &&
        (oldDelegate.data != data ||
            oldDelegate.animationValue != animationValue ||
            oldDelegate.hoveredIndex != hoveredIndex ||
            oldDelegate.glowValue != glowValue);
  }
}
