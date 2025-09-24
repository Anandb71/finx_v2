import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_provider.dart';
import '../services/mascot_manager_service.dart';
import '../services/global_mascot_manager.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  String _selectedMetric = 'Portfolio Value';
  late AnimationController _animationController;

  final List<String> _metrics = [
    'Portfolio Value',
    'P&L',
    'Holdings Breakdown',
    'Trading Activity',
    'Performance',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animationController.forward();

    // Show mascot popup with context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalMascotManager.showMascotPopup(
        MascotTrigger.analyticsView,
        context: {
          'screen': 'Analytics Dashboard',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolio, child) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildOverviewCards(portfolio),
              _buildMetricSelector(),
              _buildChartSection(portfolio),
              _buildInsightsSection(portfolio),
              _buildHoldingsBreakdown(portfolio),
              _buildTradingStats(portfolio),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Portfolio Analytics',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time insights & performance',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(PortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Total Value',
                    '\$${portfolio.totalPortfolioValue.toStringAsFixed(0)}',
                    portfolio.totalGainLossPercentage >= 0
                        ? Colors.green
                        : Colors.red,
                    portfolio.totalGainLossPercentage >= 0 ? '+' : '',
                    '${portfolio.totalGainLossPercentage.toStringAsFixed(2)}%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Cash Available',
                    '\$${portfolio.virtualCash.toStringAsFixed(0)}',
                    Colors.blue,
                    '',
                    '${((portfolio.virtualCash / portfolio.totalPortfolioValue) * 100).toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Total Trades',
                    '${portfolio.totalTrades}',
                    Colors.orange,
                    '',
                    '${portfolio.holdings.length} holdings',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Best Performer',
                    _getBestPerformer(portfolio),
                    Colors.green,
                    '',
                    _getBestPerformerChange(portfolio),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    Color color,
    String prefix,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          const SizedBox(height: 8),
          Text(
            '$prefix$value',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final metric = _metrics[index];
              final isSelected = _selectedMetric == metric;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMetric = metric;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00FFA3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        metric,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(PortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMetric,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildChart(portfolio)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(PortfolioProvider portfolio) {
    final data = _getChartData(portfolio);

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start trading to see your analytics',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _ChartPainter(data, _selectedMetric),
    );
  }

  Map<String, List<double>> _getChartData(PortfolioProvider portfolio) {
    switch (_selectedMetric) {
      case 'Portfolio Value':
        final history = portfolio.portfolioValueHistory;
        if (history.isEmpty) return {};
        return {'Portfolio': history.map((point) => point.value).toList()};
      case 'P&L':
        final history = portfolio.portfolioValueHistory;
        if (history.isEmpty) return {};
        return {'P&L': history.map((point) => point.value - 100000.0).toList()};
      case 'Holdings Breakdown':
        return _getHoldingsBreakdownData(portfolio);
      case 'Trading Activity':
        return _getTradingActivityData(portfolio);
      case 'Performance':
        return _getPerformanceData(portfolio);
      default:
        return {};
    }
  }

  Map<String, List<double>> _getHoldingsBreakdownData(
    PortfolioProvider portfolio,
  ) {
    final holdings = portfolio.holdings;
    final currentPrices = portfolio.currentPrices;

    Map<String, List<double>> data = {};

    for (final symbol in holdings.keys) {
      final currentPrice = currentPrices[symbol] ?? 0.0;
      final value = (holdings[symbol] ?? 0) * currentPrice;

      if (value > 0) {
        data[symbol] = [value];
      }
    }

    return data;
  }

  Map<String, List<double>> _getTradingActivityData(
    PortfolioProvider portfolio,
  ) {
    final transactions = portfolio.transactionHistory;

    if (transactions.isEmpty) return {};

    // Group transactions by day
    Map<String, int> tradesPerDay = {};
    for (final transaction in transactions) {
      final day = transaction.timestamp.toIso8601String().substring(0, 10);
      tradesPerDay[day] = (tradesPerDay[day] ?? 0) + 1;
    }

    return {
      'Trades': tradesPerDay.values.map((count) => count.toDouble()).toList(),
    };
  }

  Map<String, List<double>> _getPerformanceData(PortfolioProvider portfolio) {
    final history = portfolio.portfolioValueHistory;

    if (history.length < 2) return {};

    List<double> dailyReturns = [];
    for (int i = 1; i < history.length; i++) {
      final returnPercent =
          ((history[i].value - history[i - 1].value) / history[i - 1].value) *
          100;
      dailyReturns.add(returnPercent);
    }

    return {'Daily Returns %': dailyReturns};
  }

  Widget _buildInsightsSection(PortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key Insights',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildInsightItem(
                'Portfolio Diversification',
                '${portfolio.holdings.length} different stocks',
                portfolio.holdings.length >= 3 ? Colors.green : Colors.orange,
                portfolio.holdings.length >= 3
                    ? 'Well diversified!'
                    : 'Consider diversifying more',
              ),
              _buildInsightItem(
                'Cash Allocation',
                '${((portfolio.virtualCash / portfolio.totalPortfolioValue) * 100).toStringAsFixed(1)}% in cash',
                portfolio.virtualCash / portfolio.totalPortfolioValue > 0.2
                    ? Colors.blue
                    : Colors.orange,
                portfolio.virtualCash / portfolio.totalPortfolioValue > 0.2
                    ? 'Good cash reserve'
                    : 'Consider investing more',
              ),
              _buildInsightItem(
                'Trading Activity',
                '${portfolio.totalTrades} total trades',
                portfolio.totalTrades > 0 ? Colors.green : Colors.grey,
                portfolio.totalTrades > 0
                    ? 'Active trader!'
                    : 'Start trading to see activity',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String title,
    String value,
    Color color,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 12, color: color),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsBreakdown(PortfolioProvider portfolio) {
    final holdings = portfolio.holdings;
    final currentPrices = portfolio.currentPrices;

    if (holdings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Holdings Yet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start trading to build your portfolio',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Holdings',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...holdings.entries.map((entry) {
                final symbol = entry.key;
                final quantity = entry.value;
                final currentPrice = currentPrices[symbol] ?? 0.0;
                final value = quantity * currentPrice;
                final purchasePrice =
                    portfolio.getPurchasePrice(symbol) ?? currentPrice;
                final gainLoss = (currentPrice - purchasePrice) * quantity;
                final gainLossPercent = purchasePrice > 0
                    ? ((currentPrice - purchasePrice) / purchasePrice) * 100
                    : 0.0;

                return _buildHoldingItem(
                  symbol,
                  quantity,
                  currentPrice,
                  value,
                  gainLoss,
                  gainLossPercent,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoldingItem(
    String symbol,
    int quantity,
    double currentPrice,
    double value,
    double gainLoss,
    double gainLossPercent,
  ) {
    final isPositive = gainLoss >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$quantity shares @ \$${currentPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${value.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}\$${gainLoss.toStringAsFixed(0)} (${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isPositive ? Colors.green : Colors.red,
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

  Widget _buildTradingStats(PortfolioProvider portfolio) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trading Statistics',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Trades',
                      '${portfolio.totalTrades}',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Holdings',
                      '${portfolio.holdings.length}',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'AI Chats',
                      '${portfolio.aiChatCount}',
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Level',
                      '${portfolio.userLevel}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  String _getBestPerformer(PortfolioProvider portfolio) {
    final holdings = portfolio.holdings;
    final currentPrices = portfolio.currentPrices;

    if (holdings.isEmpty) return 'N/A';

    String bestSymbol = '';
    double bestGain = double.negativeInfinity;

    for (final entry in holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final currentPrice = currentPrices[symbol] ?? 0.0;
      final purchasePrice = portfolio.getPurchasePrice(symbol) ?? currentPrice;

      if (purchasePrice > 0) {
        final gain = ((currentPrice - purchasePrice) / purchasePrice) * 100;
        if (gain > bestGain) {
          bestGain = gain;
          bestSymbol = symbol;
        }
      }
    }

    return bestSymbol.isEmpty ? 'N/A' : bestSymbol;
  }

  String _getBestPerformerChange(PortfolioProvider portfolio) {
    final holdings = portfolio.holdings;
    final currentPrices = portfolio.currentPrices;

    if (holdings.isEmpty) return 'N/A';

    double bestGain = double.negativeInfinity;

    for (final entry in holdings.entries) {
      final symbol = entry.key;
      final currentPrice = currentPrices[symbol] ?? 0.0;
      final purchasePrice = portfolio.getPurchasePrice(symbol) ?? currentPrice;

      if (purchasePrice > 0) {
        final gain = ((currentPrice - purchasePrice) / purchasePrice) * 100;
        if (gain > bestGain) {
          bestGain = gain;
        }
      }
    }

    return bestGain == double.negativeInfinity
        ? 'N/A'
        : '${bestGain.toStringAsFixed(1)}%';
  }
}

class _ChartPainter extends CustomPainter {
  final Map<String, List<double>> data;
  final String metric;

  _ChartPainter(this.data, this.metric);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final colors = [
      const Color(0xFF00FFA3),
      const Color(0xFF00D4FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCF7F),
    ];

    int colorIndex = 0;
    for (final entry in data.entries) {
      final values = entry.value;
      if (values.isEmpty) continue;

      paint.color = colors[colorIndex % colors.length];

      final path = Path();
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final range = maxValue - minValue;

      if (range == 0) {
        // All values are the same, draw a horizontal line
        final y = size.height * 0.5;
        path.moveTo(0, y);
        path.lineTo(size.width, y);
      } else {
        for (int i = 0; i < values.length; i++) {
          final x = (i / (values.length - 1)) * size.width;
          final y =
              size.height - ((values[i] - minValue) / range) * size.height;

          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
      }

      canvas.drawPath(path, paint);
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
