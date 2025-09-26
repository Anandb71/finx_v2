// lib/screens/chart_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class ChartAnalysisScreen extends StatefulWidget {
  const ChartAnalysisScreen({super.key});

  @override
  State<ChartAnalysisScreen> createState() => _ChartAnalysisScreenState();
}

class _ChartAnalysisScreenState extends State<ChartAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedTimeframe = '1D';
  String _selectedIndicator = 'RSI';
  List<Map<String, dynamic>> _chartData = [];
  Map<String, dynamic> _analysisResults = {};

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y'];
  final List<String> _indicators = [
    'RSI',
    'MACD',
    'SMA',
    'EMA',
    'Bollinger Bands',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateChartData();
    _performAnalysis();
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

  void _generateChartData() {
    final random = math.Random();
    final data = <Map<String, dynamic>>[];
    double basePrice = 150.0;
    final now = DateTime.now();

    int days = _getDaysForTimeframe(_selectedTimeframe);

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final volatility = 0.02 + (random.nextDouble() * 0.03);
      final change = (random.nextDouble() - 0.5) * volatility;
      basePrice *= (1 + change);

      data.add({
        'date': date,
        'open': basePrice * (0.99 + random.nextDouble() * 0.02),
        'high': basePrice * (1.01 + random.nextDouble() * 0.02),
        'low': basePrice * (0.98 + random.nextDouble() * 0.02),
        'close': basePrice,
        'volume': 1000000 + random.nextInt(500000),
      });
    }

    setState(() {
      _chartData = data;
    });
  }

  int _getDaysForTimeframe(String timeframe) {
    switch (timeframe) {
      case '1D':
        return 1;
      case '1W':
        return 7;
      case '1M':
        return 30;
      case '3M':
        return 90;
      case '6M':
        return 180;
      case '1Y':
        return 365;
      default:
        return 30;
    }
  }

  void _performAnalysis() {
    if (_chartData.isEmpty) return;

    final prices = _chartData.map((d) => d['close'] as double).toList();
    final volumes = _chartData.map((d) => d['volume'] as int).toList();

    final currentPrice = prices.last;
    final previousPrice = prices.length > 1
        ? prices[prices.length - 2]
        : currentPrice;
    final priceChange = currentPrice - previousPrice;
    final priceChangePercent = (priceChange / previousPrice) * 100;

    // Calculate RSI
    final rsi = _calculateRSI(prices);

    // Calculate MACD
    final macd = _calculateMACD(prices);

    // Calculate moving averages
    final sma20 = _calculateSMA(prices, 20);
    final sma50 = _calculateSMA(prices, 50);

    // Calculate Bollinger Bands
    final bollinger = _calculateBollingerBands(prices, 20);

    // Calculate volume analysis
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;
    final volumeRatio = currentVolume / avgVolume;

    // Determine trend
    String trend = 'Neutral';
    if (sma20 > sma50 && currentPrice > sma20) {
      trend = 'Bullish';
    } else if (sma20 < sma50 && currentPrice < sma20) {
      trend = 'Bearish';
    }

    // Generate signals
    List<String> signals = [];
    if (rsi < 30) signals.add('Oversold');
    if (rsi > 70) signals.add('Overbought');
    if (macd['macd']! > macd['signal']!) signals.add('MACD Bullish');
    if (macd['macd']! < macd['signal']!) signals.add('MACD Bearish');
    if (currentPrice > bollinger['upper']!) signals.add('Above Upper Band');
    if (currentPrice < bollinger['lower']!) signals.add('Below Lower Band');
    if (volumeRatio > 1.5) signals.add('High Volume');

    setState(() {
      _analysisResults = {
        'currentPrice': currentPrice,
        'priceChange': priceChange,
        'priceChangePercent': priceChangePercent,
        'rsi': rsi,
        'macd': macd,
        'sma20': sma20,
        'sma50': sma50,
        'bollinger': bollinger,
        'trend': trend,
        'signals': signals,
        'volumeRatio': volumeRatio,
        'support': _findSupport(prices),
        'resistance': _findResistance(prices),
      };
    });
  }

  double _calculateRSI(List<double> prices) {
    if (prices.length < 14) return 50.0;

    double gain = 0;
    double loss = 0;

    for (int i = 1; i < 15; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        gain += change;
      } else {
        loss -= change;
      }
    }

    final avgGain = gain / 14;
    final avgLoss = loss / 14;

    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  Map<String, double> _calculateMACD(List<double> prices) {
    if (prices.length < 26) return {'macd': 0, 'signal': 0, 'histogram': 0};

    final ema12 = _calculateEMA(prices, 12);
    final ema26 = _calculateEMA(prices, 26);
    final macd = ema12 - ema26;

    // Simplified signal line (9-period EMA of MACD)
    final signal = macd * 0.9; // Simplified calculation
    final histogram = macd - signal;

    return {'macd': macd, 'signal': signal, 'histogram': histogram};
  }

  double _calculateEMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    final multiplier = 2.0 / (period + 1);
    double ema = prices.take(period).reduce((a, b) => a + b) / period;

    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] * multiplier) + (ema * (1 - multiplier));
    }

    return ema;
  }

  double _calculateSMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    final sum = prices.skip(prices.length - period).reduce((a, b) => a + b);
    return sum / period;
  }

  Map<String, double> _calculateBollingerBands(
    List<double> prices,
    int period,
  ) {
    if (prices.length < period) {
      final price = prices.last;
      return {'upper': price, 'middle': price, 'lower': price};
    }

    final sma = _calculateSMA(prices, period);
    final recentPrices = prices.skip(prices.length - period);

    double variance = 0;
    for (final price in recentPrices) {
      variance += math.pow(price - sma, 2);
    }
    variance /= period;

    final stdDev = math.sqrt(variance);
    final upper = sma + (2 * stdDev);
    final lower = sma - (2 * stdDev);

    return {'upper': upper, 'middle': sma, 'lower': lower};
  }

  double _findSupport(List<double> prices) {
    if (prices.length < 10) return prices.last;

    final recentPrices = prices.skip(prices.length - 10);
    return recentPrices.reduce((a, b) => a < b ? a : b);
  }

  double _findResistance(List<double> prices) {
    if (prices.length < 10) return prices.last;

    final recentPrices = prices.skip(prices.length - 10);
    return recentPrices.reduce((a, b) => a > b ? a : b);
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
              _buildTimeframeSelector(),
              _buildChart(),
              _buildAnalysisResults(),
              _buildTechnicalIndicators(),
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
                    'Chart Analysis',
                    style: LiquidTextStyle.headlineMedium(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Technical analysis and market insights',
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

  Widget _buildTimeframeSelector() {
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
                      'Timeframe & Indicators',
                      style: LiquidTextStyle.titleLarge(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _buildSelectorRow(
                      'Timeframe',
                      _timeframes,
                      _selectedTimeframe,
                      (value) {
                        setState(() {
                          _selectedTimeframe = value;
                          _generateChartData();
                          _performAnalysis();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSelectorRow(
                      'Indicator',
                      _indicators,
                      _selectedIndicator,
                      (value) {
                        setState(() {
                          _selectedIndicator = value;
                        });
                      },
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

  Widget _buildSelectorRow(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LiquidTextStyle.bodyLarge(
            context,
          ).copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selected;

              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00FFA3)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_chartData.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LiquidCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price Chart',
                      style: LiquidTextStyle.titleLarge(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    if (_analysisResults.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTrendColor(
                            _analysisResults['trend'],
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _analysisResults['trend'],
                          style: LiquidTextStyle.bodyMedium(context).copyWith(
                            color: _getTrendColor(_analysisResults['trend']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: ChartAnalysisPainter(_chartData, _analysisResults),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResults.isEmpty)
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
                  'Analysis Results',
                  style: LiquidTextStyle.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalysisCard(
                        'Current Price',
                        '\$${_analysisResults['currentPrice'].toStringAsFixed(2)}',
                        _analysisResults['priceChange'] >= 0
                            ? Colors.green
                            : Colors.red,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalysisCard(
                        'Change',
                        '${_analysisResults['priceChangePercent'].toStringAsFixed(2)}%',
                        _analysisResults['priceChange'] >= 0
                            ? Colors.green
                            : Colors.red,
                        Icons.show_chart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalysisCard(
                        'RSI',
                        _analysisResults['rsi'].toStringAsFixed(1),
                        _getRSIColor(_analysisResults['rsi']),
                        Icons.speed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalysisCard(
                        'Volume Ratio',
                        '${_analysisResults['volumeRatio'].toStringAsFixed(1)}x',
                        _analysisResults['volumeRatio'] > 1.5
                            ? Colors.orange
                            : Colors.blue,
                        Icons.volume_up,
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

  Widget _buildTechnicalIndicators() {
    if (_analysisResults.isEmpty)
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
                  'Technical Signals',
                  style: LiquidTextStyle.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_analysisResults['signals'] as List<String>).map((
                    signal,
                  ) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getSignalColor(signal).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getSignalColor(signal).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        signal,
                        style: LiquidTextStyle.bodyMedium(context).copyWith(
                          color: _getSignalColor(signal),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Key Levels',
                  style: LiquidTextStyle.titleMedium(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLevelCard(
                        'Support',
                        '\$${_analysisResults['support'].toStringAsFixed(2)}',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLevelCard(
                        'Resistance',
                        '\$${_analysisResults['resistance'].toStringAsFixed(2)}',
                        Colors.red,
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

  Widget _buildAnalysisCard(
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

  Widget _buildLevelCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: LiquidTextStyle.bodyMedium(
              context,
            ).copyWith(color: Colors.white70),
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
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Bullish':
        return Colors.green;
      case 'Bearish':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getRSIColor(double rsi) {
    if (rsi > 70) return Colors.red;
    if (rsi < 30) return Colors.green;
    return Colors.orange;
  }

  Color _getSignalColor(String signal) {
    if (signal.contains('Bullish') || signal.contains('Oversold'))
      return Colors.green;
    if (signal.contains('Bearish') || signal.contains('Overbought'))
      return Colors.red;
    if (signal.contains('High Volume')) return Colors.orange;
    return Colors.blue;
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
          const Color(0xFF1A1A2E).withOpacity(0.03),
          const Color(0xFF16213E).withOpacity(0.05),
          const Color(0xFF0F3460).withOpacity(0.03),
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

class ChartAnalysisPainter extends CustomPainter {
  final List<Map<String, dynamic>> chartData;
  final Map<String, dynamic> analysisResults;

  ChartAnalysisPainter(this.chartData, this.analysisResults);

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.length < 2) return;

    final prices = chartData.map((d) => d['close'] as double).toList();
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw price line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF00FFA3);

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y =
          size.height - ((prices[i] - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw moving averages if available
    if (analysisResults.isNotEmpty) {
      final sma20 = analysisResults['sma20'] as double;
      final sma50 = analysisResults['sma50'] as double;

      // SMA 20
      final sma20Paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.blue.withOpacity(0.7);

      final sma20Y =
          size.height - ((sma20 - minPrice) / priceRange) * size.height;
      canvas.drawLine(
        Offset(0, sma20Y),
        Offset(size.width, sma20Y),
        sma20Paint,
      );

      // SMA 50
      final sma50Paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.orange.withOpacity(0.7);

      final sma50Y =
          size.height - ((sma50 - minPrice) / priceRange) * size.height;
      canvas.drawLine(
        Offset(0, sma50Y),
        Offset(size.width, sma50Y),
        sma50Paint,
      );
    }

    // Draw Bollinger Bands if available
    if (analysisResults.isNotEmpty && analysisResults['bollinger'] != null) {
      final bollinger = analysisResults['bollinger'] as Map<String, double>;
      final upper = bollinger['upper']!;
      final lower = bollinger['lower']!;

      final bandPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.purple.withOpacity(0.5);

      final upperY =
          size.height - ((upper - minPrice) / priceRange) * size.height;
      final lowerY =
          size.height - ((lower - minPrice) / priceRange) * size.height;

      canvas.drawLine(Offset(0, upperY), Offset(size.width, upperY), bandPaint);
      canvas.drawLine(Offset(0, lowerY), Offset(size.width, lowerY), bandPaint);
    }

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF00FFA3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < prices.length; i += (prices.length / 10).round()) {
      final x = (i / (prices.length - 1)) * size.width;
      final y =
          size.height - ((prices[i] - minPrice) / priceRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
