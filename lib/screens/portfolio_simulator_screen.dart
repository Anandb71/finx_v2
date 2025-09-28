// lib/screens/portfolio_simulator_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class PortfolioSimulatorScreen extends StatefulWidget {
  const PortfolioSimulatorScreen({super.key});

  @override
  State<PortfolioSimulatorScreen> createState() =>
      _PortfolioSimulatorScreenState();
}

class _PortfolioSimulatorScreenState extends State<PortfolioSimulatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _initialAmount = 10000.0;
  double _monthlyContribution = 500.0;
  double _expectedReturn = 8.0;
  int _timeHorizon = 10;
  String _riskLevel = 'Moderate';
  List<Map<String, dynamic>> _simulationResults = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSimulation();
  }

  void _setupAnimations() {
    _auroraController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _runSimulation() {
    final random = math.Random();
    final results = <Map<String, dynamic>>[];
    double currentValue = _initialAmount;

    for (int year = 0; year <= _timeHorizon; year++) {
      // Add monthly contributions
      if (year > 0) {
        currentValue += _monthlyContribution * 12;
      }

      // Apply expected return with some volatility
      final volatility = _getVolatilityForRiskLevel(_riskLevel);
      final annualReturn =
          _expectedReturn + (random.nextDouble() - 0.5) * volatility;
      currentValue *= (1 + annualReturn / 100);

      results.add({
        'year': year,
        'value': currentValue,
        'contributions': _initialAmount + (_monthlyContribution * 12 * year),
        'gains':
            currentValue -
            (_initialAmount + (_monthlyContribution * 12 * year)),
      });
    }

    setState(() {
      _simulationResults = results;
    });
  }

  double _getVolatilityForRiskLevel(String riskLevel) {
    switch (riskLevel) {
      case 'Conservative':
        return 5.0;
      case 'Moderate':
        return 10.0;
      case 'Aggressive':
        return 20.0;
      default:
        return 10.0;
    }
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildAuroraBackground(),
          CustomScrollView(
            slivers: [
              _buildLiquidAppBar(),
              _buildSimulationControls(),
              _buildResultsChart(),
              _buildResultsSummary(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuroraBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: AuroraPainter(_auroraController.value),
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
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.6),
                  const Color(0xFF0F3460).withOpacity(0.4),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Portfolio Simulator',
                    style: LiquidTextStyle.headlineMedium(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project your investment growth',
                    style: LiquidTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationControls() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LiquidCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulation Parameters',
                      style: LiquidTextStyle.titleLarge(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _buildParameterSlider(
                      'Initial Amount',
                      _initialAmount,
                      1000,
                      100000,
                      '\$',
                      (value) => setState(() {
                        _initialAmount = value;
                        _runSimulation();
                      }),
                    ),
                    _buildParameterSlider(
                      'Monthly Contribution',
                      _monthlyContribution,
                      0,
                      5000,
                      '\$',
                      (value) => setState(() {
                        _monthlyContribution = value;
                        _runSimulation();
                      }),
                    ),
                    _buildParameterSlider(
                      'Expected Annual Return',
                      _expectedReturn,
                      1,
                      20,
                      '%',
                      (value) => setState(() {
                        _expectedReturn = value;
                        _runSimulation();
                      }),
                    ),
                    _buildParameterSlider(
                      'Time Horizon',
                      _timeHorizon.toDouble(),
                      1,
                      30,
                      ' years',
                      (value) => setState(() {
                        _timeHorizon = value.round();
                        _runSimulation();
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildRiskLevelSelector(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    String suffix,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: LiquidTextStyle.bodyLarge(
                context,
              ).copyWith(color: Colors.white70),
            ),
            Text(
              '${value.toStringAsFixed(value < 100 ? 0 : 0)}$suffix',
              style: LiquidTextStyle.bodyLarge(context).copyWith(
                color: const Color(0xFF00FFA3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00FFA3),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: const Color(0xFF00FFA3),
            overlayColor: const Color(0xFF00FFA3).withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRiskLevelSelector() {
    final riskLevels = ['Conservative', 'Moderate', 'Aggressive'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Level',
          style: LiquidTextStyle.bodyLarge(
            context,
          ).copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Row(
          children: riskLevels.map((level) {
            final isSelected = _riskLevel == level;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _riskLevel = level;
                  _runSimulation();
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00FFA3)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    level,
                    textAlign: TextAlign.center,
                    style: LiquidTextStyle.bodyMedium(context).copyWith(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsChart() {
    if (_simulationResults.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LiquidCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projected Growth',
                  style: LiquidTextStyle.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: PortfolioSimulationPainter(_simulationResults),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    if (_simulationResults.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox());

    final finalValue = _simulationResults.last['value'] as double;
    final totalContributions =
        _simulationResults.last['contributions'] as double;
    final totalGains = _simulationResults.last['gains'] as double;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LiquidCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Final Value',
                        '\$${finalValue.toStringAsFixed(0)}',
                        const Color(0xFF00FFA3),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Gains',
                        '\$${totalGains.toStringAsFixed(0)}',
                        const Color(0xFF00D4FF),
                        Icons.show_chart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Contributions',
                        '\$${totalContributions.toStringAsFixed(0)}',
                        Colors.orange,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Return Rate',
                        '${((totalGains / totalContributions) * 100).toStringAsFixed(1)}%',
                        Colors.purple,
                        Icons.percent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: LiquidTextStyle.titleMedium(
              context,
            ).copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: LiquidTextStyle.bodyMedium(
              context,
            ).copyWith(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;

  AuroraPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0A1A).withOpacity(0.008),
          const Color(0xFF0D1B2A).withOpacity(0.012),
          const Color(0xFF0A1A2E).withOpacity(0.008),
        ],
        stops: [
          0.0 + (animationValue * 0.1),
          0.5 + (animationValue * 0.2),
          1.0 + (animationValue * 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PortfolioSimulationPainter extends CustomPainter {
  final List<Map<String, dynamic>> results;

  PortfolioSimulationPainter(this.results);

  @override
  void paint(Canvas canvas, Size size) {
    if (results.length < 2) return;

    final values = results.map((r) => r['value'] as double).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw value line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF00FFA3);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw area under curve
    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00FFA3).withOpacity(0.3),
          const Color(0xFF00FFA3).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF00FFA3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
