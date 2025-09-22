import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskCalculatorScreen extends StatefulWidget {
  const RiskCalculatorScreen({super.key});

  @override
  State<RiskCalculatorScreen> createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _glowAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _glowAnimation;

  double _accountBalance = 10000.0;
  double _riskPercentage = 2.0;
  double _entryPrice = 150.0;
  double _stopLoss = 140.0;
  double _takeProfit = 170.0;

  // Calculated values
  double _riskAmount = 0.0;
  double _positionSize = 0.0;
  double _riskRewardRatio = 0.0;
  double _maxShares = 0.0;
  double _potentialLoss = 0.0;
  double _potentialGain = 0.0;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
    _calculateRisk();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
    _glowAnimationController.repeat(reverse: true);
  }

  void _calculateRisk() {
    _riskAmount = _accountBalance * (_riskPercentage / 100);
    _positionSize = _riskAmount / (_entryPrice - _stopLoss).abs();
    _maxShares = _positionSize.floor().toDouble();
    _potentialLoss = _maxShares * (_entryPrice - _stopLoss).abs();
    _potentialGain = _maxShares * (_takeProfit - _entryPrice).abs();
    _riskRewardRatio = _potentialGain / _potentialLoss;
    setState(() {});
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildInputSection(),
            _buildResultsSection(),
            _buildRiskVisualization(),
            _buildRecommendations(),
            _buildBottomPadding(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _headerAnimation.value)),
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
                        10,
                        (index) => _buildFloatingParticle(index),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFF9C27B0),
                                          Color(0xFF673AB7),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Risk Calculator',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF9C27B0,
                                            ).withOpacity(_glowAnimation.value),
                                            const Color(
                                              0xFF673AB7,
                                            ).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF9C27B0)
                                                .withOpacity(
                                                  0.3 * _glowAnimation.value,
                                                ),
                                            blurRadius:
                                                15 * _glowAnimation.value,
                                            spreadRadius:
                                                2 * _glowAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'CALCULATOR',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    );
                                  },
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
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1.3) % 1.0;
    final size = 2.0 + (random * 4.0);
    final left = 20.0 + (random * 300.0);
    final top = 20.0 + (random * 80.0);
    final opacity = 0.2 + (random * 0.6);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final animationValue = (_glowAnimation.value + random) % 1.0;
        return Positioned(
          left: left + (40 * (animationValue - 0.5)),
          top: top + (30 * (animationValue - 0.5)),
          child: Opacity(
            opacity: opacity * (1 - animationValue),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.5),
                    blurRadius: 6,
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

  Widget _buildInputSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Parameters',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      'Account Balance',
                      _accountBalance,
                      '\$',
                      (value) {
                        setState(() {
                          _accountBalance = value;
                          _calculateRisk();
                        });
                      },
                      const Color(0xFF00FFA3),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Risk Percentage',
                      _riskPercentage,
                      '%',
                      (value) {
                        setState(() {
                          _riskPercentage = value;
                          _calculateRisk();
                        });
                      },
                      const Color(0xFF00D4FF),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField('Entry Price', _entryPrice, '\$', (value) {
                      setState(() {
                        _entryPrice = value;
                        _calculateRisk();
                      });
                    }, const Color(0xFFFFD700)),
                    const SizedBox(height: 16),
                    _buildInputField('Stop Loss', _stopLoss, '\$', (value) {
                      setState(() {
                        _stopLoss = value;
                        _calculateRisk();
                      });
                    }, const Color(0xFFFF6B6B)),
                    const SizedBox(height: 16),
                    _buildInputField('Take Profit', _takeProfit, '\$', (value) {
                      setState(() {
                        _takeProfit = value;
                        _calculateRisk();
                      });
                    }, const Color(0xFF00FFA3)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    String label,
    double value,
    String prefix,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: TextFormField(
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
              border: InputBorder.none,
              prefixText: prefix,
              prefixStyle: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            onChanged: (text) {
              final newValue = double.tryParse(text) ?? 0.0;
              onChanged(newValue);
            },
            controller: TextEditingController(text: value.toStringAsFixed(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Analysis Results',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultCard(
                            'Risk Amount',
                            '\$${_riskAmount.toStringAsFixed(2)}',
                            Icons.warning,
                            const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResultCard(
                            'Max Shares',
                            _maxShares.toStringAsFixed(0),
                            Icons.shopping_cart,
                            const Color(0xFF00D4FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultCard(
                            'Potential Loss',
                            '\$${_potentialLoss.toStringAsFixed(2)}',
                            Icons.trending_down,
                            const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResultCard(
                            'Potential Gain',
                            '\$${_potentialGain.toStringAsFixed(2)}',
                            Icons.trending_up,
                            const Color(0xFF00FFA3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Risk/Reward Ratio',
                      '${_riskRewardRatio.toStringAsFixed(2)}:1',
                      Icons.balance,
                      _riskRewardRatio >= 2.0
                          ? const Color(0xFF00FFA3)
                          : const Color(0xFFFFD700),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskVisualization() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Visualization',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: RiskVisualizationPainter(
                          entryPrice: _entryPrice,
                          stopLoss: _stopLoss,
                          takeProfit: _takeProfit,
                          currentPrice: _entryPrice,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendations() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Recommendations',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._getRecommendations().map(
                      (rec) => _buildRecommendationItem(rec),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (recommendation['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (recommendation['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              recommendation['icon'] as IconData,
              color: recommendation['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation['description'] as String,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }

  List<Map<String, dynamic>> _getRecommendations() {
    final recommendations = <Map<String, dynamic>>[];

    if (_riskPercentage > 5.0) {
      recommendations.add({
        'title': 'High Risk Warning',
        'description':
            'Risk percentage is above 5%. Consider reducing to 1-2% for better risk management.',
        'icon': Icons.warning,
        'color': const Color(0xFFFF6B6B),
      });
    }

    if (_riskRewardRatio < 1.0) {
      recommendations.add({
        'title': 'Poor Risk/Reward',
        'description':
            'Risk/Reward ratio is below 1:1. Look for better entry points or adjust targets.',
        'icon': Icons.trending_down,
        'color': const Color(0xFFFFD700),
      });
    } else if (_riskRewardRatio >= 2.0) {
      recommendations.add({
        'title': 'Excellent Risk/Reward',
        'description':
            'Great risk/reward ratio! This trade setup looks promising.',
        'icon': Icons.trending_up,
        'color': const Color(0xFF00FFA3),
      });
    }

    if (_maxShares < 1) {
      recommendations.add({
        'title': 'Position Too Small',
        'description':
            'Calculated position size is less than 1 share. Consider adjusting entry price or stop loss.',
        'icon': Icons.info,
        'color': const Color(0xFF00D4FF),
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Good Risk Management',
        'description':
            'Your risk parameters look well-balanced. Always use stop losses!',
        'icon': Icons.check_circle,
        'color': const Color(0xFF00FFA3),
      });
    }

    return recommendations;
  }
}

class RiskVisualizationPainter extends CustomPainter {
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final double currentPrice;

  RiskVisualizationPainter({
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.currentPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate positions
    final minPrice = [
      entryPrice,
      stopLoss,
      takeProfit,
    ].reduce((a, b) => a < b ? a : b);
    final maxPrice = [
      entryPrice,
      stopLoss,
      takeProfit,
    ].reduce((a, b) => a > b ? a : b);
    final range = maxPrice - minPrice;
    final padding = range * 0.1;
    final adjustedMin = minPrice - padding;
    final adjustedMax = maxPrice + padding;
    final adjustedRange = adjustedMax - adjustedMin;

    final getY = (double price) =>
        size.height - ((price - adjustedMin) / adjustedRange) * size.height;

    // Draw price levels
    final entryY = getY(entryPrice);
    final stopY = getY(stopLoss);
    final profitY = getY(takeProfit);

    // Entry line
    paint.color = const Color(0xFF00D4FF);
    canvas.drawLine(Offset(0, entryY), Offset(size.width, entryY), paint);

    // Stop loss line
    paint.color = const Color(0xFFFF6B6B);
    canvas.drawLine(Offset(0, stopY), Offset(size.width, stopY), paint);

    // Take profit line
    paint.color = const Color(0xFF00FFA3);
    canvas.drawLine(Offset(0, profitY), Offset(size.width, profitY), paint);

    // Draw labels
    _drawLabel(
      canvas,
      'Entry: \$${entryPrice.toStringAsFixed(2)}',
      const Color(0xFF00D4FF),
      10,
      entryY,
    );
    _drawLabel(
      canvas,
      'Stop Loss: \$${stopLoss.toStringAsFixed(2)}',
      const Color(0xFFFF6B6B),
      10,
      stopY,
    );
    _drawLabel(
      canvas,
      'Take Profit: \$${takeProfit.toStringAsFixed(2)}',
      const Color(0xFF00FFA3),
      10,
      profitY,
    );

    // Draw risk/reward zones
    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Risk zone (red)
    fillPaint.color = const Color(0xFFFF6B6B).withOpacity(0.2);
    canvas.drawRect(Rect.fromLTRB(0, stopY, size.width, entryY), fillPaint);

    // Reward zone (green)
    fillPaint.color = const Color(0xFF00FFA3).withOpacity(0.2);
    canvas.drawRect(Rect.fromLTRB(0, entryY, size.width, profitY), fillPaint);
  }

  void _drawLabel(Canvas canvas, String text, Color color, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
