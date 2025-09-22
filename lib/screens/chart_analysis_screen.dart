import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartAnalysisScreen extends StatefulWidget {
  const ChartAnalysisScreen({super.key});

  @override
  State<ChartAnalysisScreen> createState() => _ChartAnalysisScreenState();
}

class _ChartAnalysisScreenState extends State<ChartAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _glowAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _glowAnimation;

  String _selectedTimeframe = '1D';
  String _selectedIndicator = 'SMA';
  String _selectedStock = 'AAPL';
  bool _showVolume = true;
  bool _showIndicators = true;

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y'];
  final List<String> _indicators = [
    'SMA',
    'EMA',
    'RSI',
    'MACD',
    'Bollinger Bands',
  ];
  final List<Map<String, dynamic>> _stocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': 150.0, 'change': 2.5},
    {
      'symbol': 'GOOGL',
      'name': 'Alphabet Inc.',
      'price': 2800.0,
      'change': -1.2,
    },
    {
      'symbol': 'MSFT',
      'name': 'Microsoft Corp.',
      'price': 300.0,
      'change': 1.8,
    },
    {'symbol': 'TSLA', 'name': 'Tesla Inc.', 'price': 800.0, 'change': -3.5},
    {
      'symbol': 'AMZN',
      'name': 'Amazon.com Inc.',
      'price': 3200.0,
      'change': 0.9,
    },
  ];

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

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
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
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _chartAnimationController.forward();
    });
    _glowAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _chartAnimationController.dispose();
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
            _buildControlsSection(),
            _buildMainChart(),
            _buildTechnicalIndicators(),
            _buildAnalysisInsights(),
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
                        12,
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
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Chart Analysis',
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
                                              0xFFFFD700,
                                            ).withOpacity(_glowAnimation.value),
                                            const Color(
                                              0xFFFFA500,
                                            ).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700)
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
                                        'ANALYSIS',
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
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
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

  Widget _buildControlsSection() {
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
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildControlDropdown(
                            'Stock',
                            _selectedStock,
                            _stocks.map((s) => s['symbol'] as String).toList(),
                            (value) => setState(() => _selectedStock = value),
                            const Color(0xFF00FFA3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildControlDropdown(
                            'Timeframe',
                            _selectedTimeframe,
                            _timeframes,
                            (value) =>
                                setState(() => _selectedTimeframe = value),
                            const Color(0xFF00D4FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildControlDropdown(
                            'Indicator',
                            _selectedIndicator,
                            _indicators,
                            (value) =>
                                setState(() => _selectedIndicator = value),
                            const Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildToggleSwitch(
                                  'Volume',
                                  _showVolume,
                                  (value) =>
                                      setState(() => _showVolume = value),
                                  const Color(0xFFFF6B6B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildToggleSwitch(
                                  'Indicators',
                                  _showIndicators,
                                  (value) =>
                                      setState(() => _showIndicators = value),
                                  const Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildControlDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            dropdownColor: const Color(0xFF1A1A2E),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 25,
            decoration: BoxDecoration(
              color: value ? color : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.5),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainChart() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _chartAnimation.value)),
            child: Opacity(
              opacity: _chartAnimation.value,
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
                    Row(
                      children: [
                        Text(
                          'Price Chart - $_selectedStock',
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${_getCurrentPrice().toStringAsFixed(2)}',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00FFA3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: AdvancedChartPainter(
                          data: _getChartData(),
                          showVolume: _showVolume,
                          showIndicators: _showIndicators,
                          indicator: _selectedIndicator,
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

  Widget _buildTechnicalIndicators() {
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
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical Indicators',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: _getIndicatorData().length,
                      itemBuilder: (context, index) {
                        final indicator = _getIndicatorData()[index];
                        return _buildIndicatorCard(indicator);
                      },
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

  Widget _buildIndicatorCard(Map<String, dynamic> indicator) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (indicator['color'] as Color).withOpacity(0.2),
            (indicator['color'] as Color).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (indicator['color'] as Color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            indicator['name'] as String,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            indicator['value'] as String,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: indicator['color'] as Color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            indicator['signal'] as String,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: (indicator['signalColor'] as Color),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInsights() {
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
                      'Analysis Insights',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._getAnalysisInsights().map(
                      (insight) => _buildInsightItem(insight),
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

  Widget _buildInsightItem(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (insight['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (insight['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight['icon'] as IconData,
              color: insight['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight['description'] as String,
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

  double _getCurrentPrice() {
    final stock = _stocks.firstWhere((s) => s['symbol'] == _selectedStock);
    return stock['price'] as double;
  }

  List<double> _getChartData() {
    // Mock chart data - in real app, this would come from API
    return [
      100,
      102,
      98,
      105,
      110,
      108,
      115,
      120,
      118,
      125,
      130,
      128,
      135,
      140,
      138,
      145,
      142,
      148,
      150,
      155,
    ];
  }

  List<Map<String, dynamic>> _getIndicatorData() {
    return [
      {
        'name': 'RSI',
        'value': '65.4',
        'signal': 'Neutral',
        'signalColor': const Color(0xFFFFD700),
        'color': const Color(0xFFFFD700),
      },
      {
        'name': 'MACD',
        'value': '2.1',
        'signal': 'Bullish',
        'signalColor': const Color(0xFF00FFA3),
        'color': const Color(0xFF00FFA3),
      },
      {
        'name': 'SMA(20)',
        'value': '142.5',
        'signal': 'Above',
        'signalColor': const Color(0xFF00FFA3),
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'Volume',
        'value': '2.4M',
        'signal': 'High',
        'signalColor': const Color(0xFFFF6B6B),
        'color': const Color(0xFFFF6B6B),
      },
    ];
  }

  List<Map<String, dynamic>> _getAnalysisInsights() {
    return [
      {
        'title': 'Trend Analysis',
        'description': 'Price is above 20-day SMA, indicating bullish momentum',
        'icon': Icons.trending_up,
        'color': const Color(0xFF00FFA3),
      },
      {
        'title': 'Volume Confirmation',
        'description': 'High volume supports the current price movement',
        'icon': Icons.bar_chart,
        'color': const Color(0xFF00D4FF),
      },
      {
        'title': 'RSI Level',
        'description': 'RSI at 65.4 suggests the stock is not overbought yet',
        'icon': Icons.speed,
        'color': const Color(0xFFFFD700),
      },
      {
        'title': 'Support Level',
        'description': 'Strong support at \$140 level, watch for bounce',
        'icon': Icons.support,
        'color': const Color(0xFF9C27B0),
      },
    ];
  }
}

class AdvancedChartPainter extends CustomPainter {
  final List<double> data;
  final bool showVolume;
  final bool showIndicators;
  final String indicator;

  AdvancedChartPainter({
    required this.data,
    required this.showVolume,
    required this.showIndicators,
    required this.indicator,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.3),
          const Color(0xFF00D4FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Calculate price range
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.1;
    final adjustedMin = minValue - padding;
    final adjustedMax = maxValue + padding;
    final adjustedRange = adjustedMax - adjustedMin;

    final getY = (double price) =>
        size.height - ((price - adjustedMin) / adjustedRange) * size.height;

    // Draw main price line
    paint.color = const Color(0xFF00D4FF);
    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = getY(data[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw moving average if enabled
    if (showIndicators && indicator == 'SMA') {
      paint.color = const Color(0xFFFFD700);
      paint.strokeWidth = 1.5;

      final smaData = _calculateSMA(data, 5);
      final smaPath = Path();

      for (int i = 0; i < smaData.length; i++) {
        final x = (i + 4) * stepX; // Offset for SMA calculation
        final y = getY(smaData[i]);

        if (i == 0) {
          smaPath.moveTo(x, y);
        } else {
          smaPath.lineTo(x, y);
        }
      }

      canvas.drawPath(smaPath, paint);
    }

    // Draw volume bars if enabled
    if (showVolume) {
      final volumePaint = Paint()
        ..color = const Color(0xFFFF6B6B).withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final volumeHeight = size.height * 0.3;
      final volumeData = _generateVolumeData(data.length);

      for (int i = 0; i < volumeData.length; i++) {
        final x = i * stepX;
        final barWidth = stepX * 0.8;
        final barHeight =
            (volumeData[i] / volumeData.reduce((a, b) => a > b ? a : b)) *
            volumeHeight;

        canvas.drawRect(
          Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
          volumePaint,
        );
      }
    }

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = getY(data[i]);
      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }
  }

  List<double> _calculateSMA(List<double> data, int period) {
    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      final sum = data.sublist(i - period + 1, i + 1).reduce((a, b) => a + b);
      result.add(sum / period);
    }
    return result;
  }

  List<double> _generateVolumeData(int length) {
    final random = List.generate(length, (index) => 0.5 + (index % 3) * 0.3);
    return random;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
