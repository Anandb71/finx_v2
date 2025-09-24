import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_provider.dart';

class PortfolioSimulatorScreen extends StatefulWidget {
  const PortfolioSimulatorScreen({super.key});

  @override
  State<PortfolioSimulatorScreen> createState() =>
      _PortfolioSimulatorScreenState();
}

class _PortfolioSimulatorScreenState extends State<PortfolioSimulatorScreen>
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
  String _selectedStock = 'AAPL';
  double _investmentAmount = 1000.0;
  int _shares = 0;
  double _currentPrice = 150.0;
  double _totalValue = 0.0;
  double _profitLoss = 0.0;
  double _profitLossPercent = 0.0;

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y'];
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
    _updateCalculations();
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

  void _updateCalculations() {
    final selectedStockData = _stocks.firstWhere(
      (stock) => stock['symbol'] == _selectedStock,
    );
    _currentPrice = selectedStockData['price'] as double;
    _shares = (_investmentAmount / _currentPrice).floor();
    _totalValue = _shares * _currentPrice;
    _profitLoss = _totalValue - _investmentAmount;
    _profitLossPercent = (_profitLoss / _investmentAmount) * 100;
    setState(() {});
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
            _buildStockSelector(),
            _buildInvestmentControls(),
            _buildPortfolioSummary(),
            _buildPerformanceChart(),
            _buildTradingHistory(),
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
                                          Color(0xFF00FFA3),
                                          Color(0xFF00D4FF),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Portfolio Simulator',
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
                                              0xFF00FFA3,
                                            ).withOpacity(_glowAnimation.value),
                                            const Color(
                                              0xFF00D4FF,
                                            ).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00FFA3)
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
                                        'SIMULATOR',
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
                  colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withOpacity(0.5),
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

  Widget _buildStockSelector() {
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
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFA3).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Stock',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _stocks.length,
                        itemBuilder: (context, index) {
                          final stock = _stocks[index];
                          final isSelected = stock['symbol'] == _selectedStock;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStock = stock['symbol'] as String;
                                _updateCalculations();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF00FFA3),
                                          Color(0xFF00D4FF),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00FFA3)
                                      : Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00FFA3,
                                          ).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    stock['symbol'] as String,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${(stock['price'] as double).toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildInvestmentControls() {
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
                      'Investment Amount',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00D4FF).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.white60,
                                ),
                                border: InputBorder.none,
                                prefixText: '\$ ',
                                prefixStyle: GoogleFonts.inter(
                                  color: const Color(0xFF00D4FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _investmentAmount =
                                      double.tryParse(value) ?? 0.0;
                                  _updateCalculations();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF9C27B0)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Shares: $_shares',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Price: \$${_currentPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
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

  Widget _buildPortfolioSummary() {
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _profitLoss >= 0
                        ? [
                            const Color(0xFF00FFA3).withOpacity(0.2),
                            const Color(0xFF00D4FF).withOpacity(0.1),
                          ]
                        : [
                            const Color(0xFFFF6B6B).withOpacity(0.2),
                            const Color(0xFFFF8E53).withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _profitLoss >= 0
                        ? const Color(0xFF00FFA3).withOpacity(0.3)
                        : const Color(0xFFFF6B6B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Value',
                            '\$${_totalValue.toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                            _profitLoss >= 0
                                ? const Color(0xFF00FFA3)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'P&L',
                            '${_profitLoss >= 0 ? '+' : ''}\$${_profitLoss.toStringAsFixed(2)}',
                            Icons.trending_up,
                            _profitLoss >= 0
                                ? const Color(0xFF00FFA3)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'P&L %',
                            '${_profitLossPercent >= 0 ? '+' : ''}${_profitLossPercent.toStringAsFixed(2)}%',
                            Icons.percent,
                            _profitLoss >= 0
                                ? const Color(0xFF00FFA3)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Shares',
                            '$_shares',
                            Icons.shopping_cart,
                            const Color(0xFF00D4FF),
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

  Widget _buildSummaryCard(
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

  Widget _buildPerformanceChart() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _chartAnimation.value)),
            child: Opacity(
              opacity: _chartAnimation.value,
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
                    Row(
                      children: [
                        Text(
                          'Performance Chart',
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 30,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _timeframes.length,
                            itemBuilder: (context, index) {
                              final timeframe = _timeframes[index];
                              final isSelected =
                                  timeframe == _selectedTimeframe;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTimeframe = timeframe;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF9C27B0),
                                              Color(0xFF673AB7),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF9C27B0)
                                          : Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    timeframe,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9C27B0).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: PerformanceChartPainter(
                          data: _getChartData(),
                          isPositive: _profitLoss >= 0,
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

  Widget _buildTradingHistory() {
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
                      'Simulation History',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(5, (index) => _buildHistoryItem(index)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final histories = [
      {
        'action': 'BUY',
        'symbol': 'AAPL',
        'shares': 10,
        'price': 145.0,
        'time': '2 hours ago',
      },
      {
        'action': 'SELL',
        'symbol': 'GOOGL',
        'shares': 5,
        'price': 2850.0,
        'time': '1 day ago',
      },
      {
        'action': 'BUY',
        'symbol': 'MSFT',
        'shares': 15,
        'price': 295.0,
        'time': '2 days ago',
      },
      {
        'action': 'BUY',
        'symbol': 'TSLA',
        'shares': 8,
        'price': 820.0,
        'time': '3 days ago',
      },
      {
        'action': 'SELL',
        'symbol': 'AMZN',
        'shares': 3,
        'price': 3150.0,
        'time': '1 week ago',
      },
    ];

    final history = histories[index];
    final isBuy = history['action'] == 'BUY';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBuy
              ? const Color(0xFF00FFA3).withOpacity(0.2)
              : const Color(0xFFFF6B6B).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBuy
                  ? const Color(0xFF00FFA3).withOpacity(0.2)
                  : const Color(0xFFFF6B6B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.trending_up : Icons.trending_down,
              color: isBuy ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history['action']} ${history['shares']} ${history['symbol']}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'At \$${(history['price'] as double).toStringAsFixed(2)} • ${history['time']}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            '\$${((history['shares'] as int) * (history['price'] as double)).toStringAsFixed(0)}',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isBuy ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }

  List<double> _getChartData() {
    final portfolio = context.read<PortfolioProvider>();
    final history = portfolio.portfolioValueHistory;

    if (history.isEmpty) {
      // Return starting value if no history
      return [100000.0];
    }

    // Convert portfolio value history to chart data
    return history.map((point) => point.value).toList();
  }
}

class PerformanceChartPainter extends CustomPainter {
  final List<double> data;
  final bool isPositive;

  PerformanceChartPainter({required this.data, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = isPositive ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isPositive ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B))
              .withOpacity(0.3),
          (isPositive ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B))
              .withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

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

    // Draw data points
    final pointPaint = Paint()
      ..color = isPositive ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
