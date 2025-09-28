// lib/screens/risk_calculator_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class RiskCalculatorScreen extends StatefulWidget {
  const RiskCalculatorScreen({super.key});

  @override
  State<RiskCalculatorScreen> createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _targetPriceController = TextEditingController();

  double _investmentAmount = 0;
  double _entryPrice = 0;
  double _stopLossPrice = 0;
  double _targetPrice = 0;

  Map<String, dynamic>? _calculationResults;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

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

    // Add listeners to update calculations in real-time
    _investmentController.addListener(_updateCalculations);
    _entryPriceController.addListener(_updateCalculations);
    _stopLossController.addListener(_updateCalculations);
    _targetPriceController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _investmentController.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _investmentAmount = double.tryParse(_investmentController.text) ?? 0;
      _entryPrice = double.tryParse(_entryPriceController.text) ?? 0;
      _stopLossPrice = double.tryParse(_stopLossController.text) ?? 0;
      _targetPrice = double.tryParse(_targetPriceController.text) ?? 0;

      if (_investmentAmount > 0 &&
          _entryPrice > 0 &&
          _stopLossPrice > 0 &&
          _targetPrice > 0) {
        _calculationResults = _calculateRiskReward();
      } else {
        _calculationResults = null;
      }
    });
  }

  Map<String, dynamic> _calculateRiskReward() {
    final shares = _investmentAmount / _entryPrice;
    final potentialLoss = (_entryPrice - _stopLossPrice) * shares;
    final potentialGain = (_targetPrice - _entryPrice) * shares;
    final riskRewardRatio = potentialGain / potentialLoss;
    final lossPercentage = ((_entryPrice - _stopLossPrice) / _entryPrice) * 100;
    final gainPercentage = ((_targetPrice - _entryPrice) / _entryPrice) * 100;
    final riskLevel = _getRiskLevel(riskRewardRatio, lossPercentage);

    return {
      'shares': shares,
      'potentialLoss': potentialLoss,
      'potentialGain': potentialGain,
      'riskRewardRatio': riskRewardRatio,
      'lossPercentage': lossPercentage,
      'gainPercentage': gainPercentage,
      'riskLevel': riskLevel,
    };
  }

  String _getRiskLevel(double riskRewardRatio, double lossPercentage) {
    if (riskRewardRatio >= 2.0 && lossPercentage <= 5.0) {
      return 'Low Risk';
    } else if (riskRewardRatio >= 1.5 && lossPercentage <= 10.0) {
      return 'Medium Risk';
    } else if (riskRewardRatio >= 1.0 && lossPercentage <= 15.0) {
      return 'High Risk';
    } else {
      return 'Very High Risk';
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Low Risk':
        return Colors.green;
      case 'Medium Risk':
        return Colors.orange;
      case 'High Risk':
        return Colors.red;
      case 'Very High Risk':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
              _buildInputSection(),
              if (_calculationResults != null) _buildResultsSection(),
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
                    'Risk Calculator',
                    style: LiquidTextStyle.headlineMedium(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate your risk-reward ratio',
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

  Widget _buildInputSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: LiquidCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investment Parameters',
                      style: LiquidTextStyle.titleLarge(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      'Investment Amount (\$)',
                      _investmentController,
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Entry Price (\$)',
                      _entryPriceController,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Stop Loss Price (\$)',
                      _stopLossController,
                      Icons.trending_down,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Target Price (\$)',
                      _targetPriceController,
                      Icons.flag,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: LiquidTextStyle.bodyLarge(
            context,
          ).copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: LiquidTextStyle.bodyLarge(
            context,
          ).copyWith(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00FFA3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00FFA3), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_calculationResults == null) return const SizedBox.shrink();

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
                  'Risk Analysis Results',
                  style: LiquidTextStyle.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildResultCard(
                  'Shares to Buy',
                  '${_calculationResults!['shares'].toStringAsFixed(0)} shares',
                  Colors.blue,
                  Icons.shopping_cart,
                ),
                const SizedBox(height: 12),
                _buildResultCard(
                  'Potential Loss',
                  '-\$${_calculationResults!['potentialLoss'].toStringAsFixed(2)} (${_calculationResults!['lossPercentage'].toStringAsFixed(1)}%)',
                  Colors.red,
                  Icons.trending_down,
                ),
                const SizedBox(height: 12),
                _buildResultCard(
                  'Potential Gain',
                  '+\$${_calculationResults!['potentialGain'].toStringAsFixed(2)} (${_calculationResults!['gainPercentage'].toStringAsFixed(1)}%)',
                  Colors.green,
                  Icons.trending_up,
                ),
                const SizedBox(height: 12),
                _buildResultCard(
                  'Risk-Reward Ratio',
                  '1:${_calculationResults!['riskRewardRatio'].toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.balance,
                ),
                const SizedBox(height: 12),
                _buildRiskLevelCard(),
                const SizedBox(height: 20),
                _buildRecommendationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LiquidTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: LiquidTextStyle.titleMedium(
                    context,
                  ).copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard() {
    final riskLevel = _calculationResults!['riskLevel'] as String;
    final riskColor = _getRiskColor(riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: riskColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level',
                  style: LiquidTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  riskLevel,
                  style: LiquidTextStyle.titleMedium(
                    context,
                  ).copyWith(color: riskColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final riskLevel = _calculationResults!['riskLevel'] as String;

    String recommendation = '';
    Color recommendationColor = Colors.blue;

    if (riskLevel == 'Low Risk') {
      recommendation =
          '✅ This looks like a good trade! The risk-reward ratio is favorable.';
      recommendationColor = Colors.green;
    } else if (riskLevel == 'Medium Risk') {
      recommendation =
          '⚠️ This trade has moderate risk. Consider your risk tolerance.';
      recommendationColor = Colors.orange;
    } else if (riskLevel == 'High Risk') {
      recommendation =
          '⚠️ High risk trade. Only invest what you can afford to lose.';
      recommendationColor = Colors.red;
    } else {
      recommendation =
          '❌ Very high risk! Consider reducing position size or finding better entry/exit points.';
      recommendationColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: recommendationColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: recommendationColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: recommendationColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: LiquidTextStyle.bodyMedium(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w500),
            ),
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
