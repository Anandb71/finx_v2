import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_provider.dart';
import '../services/mascot_manager_service.dart';
import '../services/global_mascot_manager.dart';
import '../widgets/sparkline_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _pulseAnimation;

  String _selectedTimeframe = '1M';
  String _selectedMetric = 'Portfolio Value';

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];
  final List<String> _metrics = [
    'Portfolio Value',
    'P&L',
    'Volume',
    'Trades',
    'Win Rate',
    'Sharpe Ratio',
  ];

  // Dynamic data based on selections
  Map<String, List<double>> _getChartDataForMetric(String metric) {
    switch (metric) {
      case 'Portfolio Value':
        return {
          'portfolio': [
            100000,
            101200,
            102500,
            101800,
            103200,
            104500,
            103800,
            105200,
            106800,
            108200,
            107500,
            109000,
            110200,
            111500,
            112800,
            111200,
            113500,
            114800,
            116200,
            115500,
            117200,
            118500,
            119800,
            121200,
            122500,
            121800,
            123200,
            124500,
            125800,
            127200,
          ],
          'sp500': [
            95000,
            95200,
            95500,
            95800,
            96200,
            96500,
            96800,
            97200,
            97800,
            98200,
            98500,
            99000,
            99200,
            99500,
            99800,
            100200,
            100500,
            100800,
            101200,
            101500,
            101800,
            102200,
            102500,
            102800,
            103200,
            103500,
            103800,
            104200,
            104500,
            104800,
          ],
        };
      case 'P&L':
        return {
          'portfolio': [
            0,
            1200,
            2500,
            1800,
            3200,
            4500,
            3800,
            5200,
            6800,
            8200,
            7500,
            9000,
            10200,
            11500,
            12800,
            11200,
            13500,
            14800,
            16200,
            15500,
            17200,
            18500,
            19800,
            21200,
            22500,
            21800,
            23200,
            24500,
            25800,
            27200,
          ],
          'sp500': [
            0,
            200,
            500,
            800,
            1200,
            1500,
            1800,
            2200,
            2800,
            3200,
            3500,
            4000,
            4200,
            4500,
            4800,
            5200,
            5500,
            5800,
            6200,
            6500,
            6800,
            7200,
            7500,
            7800,
            8200,
            8500,
            8800,
            9200,
            9500,
            9800,
          ],
        };
      case 'Volume':
        return {
          'portfolio': [
            1000,
            1200,
            1500,
            1800,
            2000,
            2200,
            2500,
            2800,
            3000,
            3200,
            3500,
            3800,
            4000,
            4200,
            4500,
            4800,
            5000,
            5200,
            5500,
            5800,
            6000,
            6200,
            6500,
            6800,
            7000,
            7200,
            7500,
            7800,
            8000,
            8200,
          ],
          'sp500': [
            800,
            900,
            1000,
            1100,
            1200,
            1300,
            1400,
            1500,
            1600,
            1700,
            1800,
            1900,
            2000,
            2100,
            2200,
            2300,
            2400,
            2500,
            2600,
            2700,
            2800,
            2900,
            3000,
            3100,
            3200,
            3300,
            3400,
            3500,
            3600,
            3700,
          ],
        };
      case 'Trades':
        return {
          'portfolio': [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24,
            25,
            26,
            27,
            28,
            29,
          ],
          'sp500': [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
          ],
        };
      case 'Win Rate':
        return {
          'portfolio': [
            0,
            100,
            100,
            75,
            80,
            83,
            85,
            87,
            88,
            89,
            90,
            91,
            92,
            93,
            94,
            95,
            96,
            97,
            98,
            99,
            100,
            100,
            100,
            100,
            100,
            100,
            100,
            100,
            100,
            100,
          ],
          'sp500': [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
          ],
        };
      case 'Sharpe Ratio':
        return {
          'portfolio': [
            0,
            0.5,
            1.0,
            1.2,
            1.4,
            1.6,
            1.8,
            2.0,
            2.1,
            2.2,
            2.3,
            2.4,
            2.5,
            2.6,
            2.7,
            2.8,
            2.9,
            3.0,
            3.1,
            3.2,
            3.3,
            3.4,
            3.5,
            3.6,
            3.7,
            3.8,
            3.9,
            4.0,
            4.1,
            4.2,
          ],
          'sp500': [
            0,
            0.3,
            0.6,
            0.8,
            1.0,
            1.2,
            1.4,
            1.6,
            1.8,
            2.0,
            2.1,
            2.2,
            2.3,
            2.4,
            2.5,
            2.6,
            2.7,
            2.8,
            2.9,
            3.0,
            3.1,
            3.2,
            3.3,
            3.4,
            3.5,
            3.6,
            3.7,
            3.8,
            3.9,
            4.0,
          ],
        };
      default:
        return {
          'portfolio': [
            100000,
            101200,
            102500,
            101800,
            103200,
            104500,
            103800,
            105200,
            106800,
            108200,
            107500,
            109000,
            110200,
            111500,
            112800,
            111200,
            113500,
            114800,
            116200,
            115500,
            117200,
            118500,
            119800,
            121200,
            122500,
            121800,
            123200,
            124500,
            125800,
            127200,
          ],
          'sp500': [
            95000,
            95200,
            95500,
            95800,
            96200,
            96500,
            96800,
            97200,
            97800,
            98200,
            98500,
            99000,
            99200,
            99500,
            99800,
            100200,
            100500,
            100800,
            101200,
            101500,
            101800,
            102200,
            102500,
            102800,
            103200,
            103500,
            103800,
            104200,
            104500,
            104800,
          ],
        };
    }
  }

  Map<String, dynamic> _getMetricData(String metric) {
    switch (metric) {
      case 'Portfolio Value':
        return {'value': '\$104,250', 'change': '+4.25%', 'isPositive': true};
      case 'P&L':
        return {'value': '+\$2,150', 'change': '+2.11%', 'isPositive': true};
      case 'Volume':
        return {'value': '8,200', 'change': '+15.2%', 'isPositive': true};
      case 'Trades':
        return {'value': '29', 'change': '+3.2%', 'isPositive': true};
      case 'Win Rate':
        return {'value': '100%', 'change': '+5.0%', 'isPositive': true};
      case 'Sharpe Ratio':
        return {'value': '4.2', 'change': '+0.3', 'isPositive': true};
      default:
        return {'value': '\$104,250', 'change': '+4.25%', 'isPositive': true};
    }
  }

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    );

    _headerAnimationController.forward();
    _chartAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);

    // Show analytics mascot popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GlobalMascotManager.showMascotPopup(MascotTrigger.analyticsView);
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _chartAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildTimeframeSelector(),
              _buildMetricsGrid(),
              _buildMainChart(),
              _buildPerformanceMetrics(),
              _buildSectorAnalysis(),
              _buildRiskMetrics(),
              _buildTradingInsights(),
              _buildMarketComparison(),
              _buildBottomPadding(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 50,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 3 * (1 - _headerAnimation.value)),
            child: Opacity(
              opacity: _headerAnimation.value,
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                        Color(0xFF0F3460),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background particles
                      ...List.generate(
                        4,
                        (index) => _buildFloatingParticle(index),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title with glow effect
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                              ).createShader(bounds),
                              child: Text(
                                'Analytics Dashboard',
                                style: GoogleFonts.orbitron(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),

                            // Subtitle
                            Text(
                              'Advanced insights & performance metrics',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1.3) % 1.0;
    final size = 2.0 + (random * 4.0);
    final left = 20.0 + (random * 300.0);
    final top = 60.0 + (random * 200.0);
    final delay = Duration(milliseconds: (index * 200).toInt());

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: top + (10 * _pulseAnimation.value * (index % 2 == 0 ? 1 : -1)),
          child: Opacity(
            opacity: 0.3 + (0.4 * _pulseAnimation.value),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: _timeframes.map((timeframe) {
            final isSelected = _selectedTimeframe == timeframe;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTimeframe = timeframe),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FFA3).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    timeframe,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final portfolioData = _getMetricData('Portfolio Value');
    final pnlData = _getMetricData('P&L');

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Value',
                portfolioData['value'],
                portfolioData['change'],
                Icons.trending_up,
                const Color(0xFF00FFA3),
                portfolioData['isPositive'],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Today\'s P&L',
                pnlData['value'],
                pnlData['change'],
                Icons.arrow_upward,
                const Color(0xFF00D4FF),
                pnlData['isPositive'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _headerAnimation.value),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? const Color(0xFF00FFA3).withOpacity(0.2)
                              : const Color(0xFFFF6B6B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          change,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPositive
                                ? const Color(0xFF00FFA3)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainChart() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Portfolio Performance',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                _buildMetricSelector(),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                final chartData = _getChartDataForMetric(_selectedMetric);
                return Container(
                  height: 200,
                  child: CustomPaint(
                    painter: AdvancedChartPainter(
                      portfolioData: chartData['portfolio']!,
                      sp500Data: chartData['sp500']!,
                      animationValue: _chartAnimation.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMetric,
          isDense: true,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: const Color(0xFF1A1A1A),
          items: _metrics.map((String metric) {
            return DropdownMenuItem<String>(value: metric, child: Text(metric));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedMetric = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _buildLegendItem('Portfolio Value', const Color(0xFF00FFA3)),
        const SizedBox(width: 24),
        _buildLegendItem('S&P 500', const Color(0xFF00D4FF)),
        const SizedBox(width: 24),
        _buildLegendItem('Benchmark', Colors.white70),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard(
                    'Sharpe Ratio',
                    '1.85',
                    'Excellent',
                    Icons.speed,
                    const Color(0xFF00FFA3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceCard(
                    'Max Drawdown',
                    '-8.2%',
                    'Low Risk',
                    Icons.trending_down,
                    const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard(
                    'Win Rate',
                    '68.5%',
                    'Good',
                    Icons.emoji_events,
                    const Color(0xFF00D4FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceCard(
                    'Avg Return',
                    '2.1%',
                    'Daily',
                    Icons.trending_up,
                    const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorAnalysis() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sector Allocation',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectorItem('Technology', 35.2, const Color(0xFF00FFA3)),
            _buildSectorItem('Healthcare', 22.8, const Color(0xFF00D4FF)),
            _buildSectorItem('Finance', 18.5, const Color(0xFFFF6B6B)),
            _buildSectorItem('Energy', 12.3, const Color(0xFFFFD93D)),
            _buildSectorItem('Consumer', 11.2, const Color(0xFF9C27B0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorItem(String sector, double percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sector,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMetrics() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Analysis',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildRiskItem('Volatility', '12.3%', 'Medium'),
                  _buildRiskItem('Beta', '1.15', 'Above Market'),
                  _buildRiskItem('VaR (95%)', '-\$2,450', 'Low Risk'),
                  _buildRiskItem('Correlation', '0.78', 'High'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(String metric, String value, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Low Risk':
        return const Color(0xFF00FFA3);
      case 'Medium':
        return const Color(0xFFFFD93D);
      case 'High':
        return const Color(0xFFFF6B6B);
      case 'Above Market':
        return const Color(0xFF00D4FF);
      default:
        return Colors.white70;
    }
  }

  Widget _buildTradingInsights() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trading Insights',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildInsightCard(
              'Best Performing Stock',
              'AAPL',
              '+12.5%',
              'Apple Inc.',
              const Color(0xFF00FFA3),
            ),
            _buildInsightCard(
              'Most Traded',
              'TSLA',
              '15 trades',
              'Tesla Inc.',
              const Color(0xFF00D4FF),
            ),
            _buildInsightCard(
              'Biggest Gain',
              'NVDA',
              '+8.2%',
              'NVIDIA Corp.',
              const Color(0xFF9C27B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String symbol,
    String value,
    String company,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                symbol.substring(0, 1),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$symbol - $company',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketComparison() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Comparison',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonCard(
                    'Your Portfolio',
                    '+4.25%',
                    const Color(0xFF00FFA3),
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComparisonCard(
                    'S&P 500',
                    '+2.1%',
                    const Color(0xFF00D4FF),
                    false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String performance,
    Color color,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? color.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            performance,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }
}

class AdvancedChartPainter extends CustomPainter {
  final List<double> portfolioData;
  final List<double> sp500Data;
  final double animationValue;

  AdvancedChartPainter({
    required this.portfolioData,
    required this.sp500Data,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (portfolioData.isEmpty || sp500Data.isEmpty) return;

    // Calculate combined min/max for both datasets
    final allData = [...portfolioData, ...sp500Data];
    final minValue = allData.reduce((a, b) => a < b ? a : b);
    final maxValue = allData.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    // Draw S&P 500 line first (background)
    _drawDataLine(
      canvas,
      size,
      sp500Data,
      minValue,
      range,
      const Color(0xFF00D4FF),
      Colors.white70,
      2.0,
    );

    // Draw portfolio line on top
    _drawDataLine(
      canvas,
      size,
      portfolioData,
      minValue,
      range,
      const Color(0xFF00FFA3),
      const Color(0xFF00FFA3),
      3.0,
    );
  }

  void _drawDataLine(
    Canvas canvas,
    Size size,
    List<double> data,
    double minValue,
    double range,
    Color lineColor,
    Color pointColor,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Draw line
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final currentPoint = points[i];
      final previousPoint = points[i - 1];

      final controlPoint1 = Offset(
        previousPoint.dx + (currentPoint.dx - previousPoint.dx) / 3,
        previousPoint.dy,
      );
      final controlPoint2 = Offset(
        currentPoint.dx - (currentPoint.dx - previousPoint.dx) / 3,
        currentPoint.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        currentPoint.dx,
        currentPoint.dy,
      );
    }

    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i += 3) {
      final point = points[i];
      canvas.drawCircle(point, 3, pointPaint);
      if (pointColor == const Color(0xFF00FFA3)) {
        canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Add mascot popup method to the main class
extension AnalyticsScreenMascot on _AnalyticsScreenState {
  void _showMascotPopup(MascotTrigger trigger) {
    // Use the global mascot popup system
    GlobalMascotManager.showMascotPopup(trigger);
  }
}
