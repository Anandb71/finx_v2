import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_provider.dart';
import '../widgets/sparkline_widget.dart';
import 'dart:math' as math;

class ModernTradeScreen extends StatefulWidget {
  final Map<String, dynamic> stockData;

  const ModernTradeScreen({super.key, required this.stockData});

  @override
  State<ModernTradeScreen> createState() => _ModernTradeScreenState();
}

class _ModernTradeScreenState extends State<ModernTradeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _quantityController = TextEditingController();
  bool _isBuyMode = true;
  bool _isTrading = false;
  String? _errorMessage;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _quantityController.addListener(_onQuantityChanged);
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    setState(() {
      _errorMessage = null;
    });
  }

  String get _currentSymbol {
    return widget.stockData['symbol'] ?? 'N/A';
  }

  double get _currentPrice {
    if (!mounted) return 0.0;
    return (widget.stockData['currentPrice'] ?? 0.0).toDouble();
  }

  int get _currentHolding {
    if (!mounted) return 0;
    final portfolio = context.read<PortfolioProvider>();
    return portfolio.portfolio[_currentSymbol] ?? 0;
  }

  Future<void> _executeTrade() async {
    if (!mounted) return;

    print(
      'Execute trade called - isBuyMode: $_isBuyMode, quantity: ${_quantityController.text}',
    );

    if (_quantityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter quantity';
      });
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid quantity';
      });
      return;
    }

    setState(() {
      _isTrading = true;
      _errorMessage = null;
    });

    try {
      final portfolio = context.read<PortfolioProvider>();

      // Update the stock price in portfolio
      portfolio.updateStockPrice(_currentSymbol, _currentPrice);

      final success = await portfolio.executeTrade(
        symbol: _currentSymbol,
        quantity: quantity,
        price: _currentPrice,
        type: _isBuyMode ? TransactionType.buy : TransactionType.sell,
      );

      if (mounted) {
        if (success) {
          _successController.forward();
          _quantityController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isBuyMode
                    ? 'Successfully bought $quantity ${_currentSymbol} shares!'
                    : 'Successfully sold $quantity ${_currentSymbol} shares!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _isBuyMode
                  ? const Color(0xFF00FFA3)
                  : Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = _isBuyMode
                ? 'Insufficient funds'
                : 'Insufficient shares';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Trade failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTrading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildStockOverview(),
                    const SizedBox(height: 32),
                    _buildTradingInterface(),
                    const SizedBox(height: 32),
                    _buildPortfolioSummary(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trading',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Buy and sell stocks with virtual money',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFA3), Color(0xFF00CC88)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'DEMO MODE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFA3), Color(0xFF00CC88)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFA3).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _currentSymbol,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stockData['name'] ?? 'Unknown Company',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.stockData['sector'] ?? 'Technology Company',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  'Current Price',
                  '\$${_currentPrice.toStringAsFixed(2)}',
                  const Color(0xFF00FFA3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceCard(
                  'Your Holdings',
                  '$_currentHolding shares',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPriceChart(),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00FFA3).withOpacity(0.1),
            const Color(0xFF00FFA3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price History (Last 30 Days)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SparklineWidget(
                prices: _getPriceHistory(),
                lineColor: const Color(0xFF00FFA3),
                fillColor: const Color(0xFF00FFA3).withOpacity(0.2),
                height: 60,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _getPriceHistory() {
    final priceHistory = widget.stockData['priceHistory'];
    if (priceHistory != null && priceHistory is List) {
      return priceHistory.map((e) => (e as num).toDouble()).toList();
    }

    // Fallback to mock data if no price history available
    final random = math.Random();
    final basePrice = _currentPrice;
    final prices = <double>[];

    for (int i = 0; i < 30; i++) {
      final variation = (random.nextDouble() - 0.5) * (basePrice * 0.1);
      prices.add(basePrice + variation);
    }

    return prices;
  }

  Widget _buildTradingInterface() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
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
              Icon(Icons.trending_up, color: const Color(0xFF00FFA3), size: 24),
              const SizedBox(width: 12),
              Text(
                'Trading Interface',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBuySellToggle(),
          const SizedBox(height: 24),
          _buildQuantityInput(),
          const SizedBox(height: 24),
          _buildEstimatedCost(),
          const SizedBox(height: 24),
          _buildTradeButton(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildBuySellToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBuyMode = true;
                  _errorMessage = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isBuyMode
                      ? const Color(0xFF00FFA3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isBuyMode
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: _isBuyMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BUY',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isBuyMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBuyMode = false;
                  _errorMessage = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_isBuyMode ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isBuyMode
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: !_isBuyMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SELL',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !_isBuyMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter number of shares',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: Icon(
                Icons.shopping_cart,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedCost() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final estimatedCost = quantity * _currentPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Text(
            'Estimated Cost: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            '\$${estimatedCost.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isBuyMode ? const Color(0xFF00FFA3) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeButton() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final isEnabled = quantity > 0 && !_isTrading;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isTrading ? 1.0 : _pulseAnimation.value,
          child: AnimatedBuilder(
            animation: _successAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _successAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isEnabled ? _executeTrade : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBuyMode
                          ? const Color(0xFF00FFA3)
                          : Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white.withOpacity(0.1),
                      disabledForegroundColor: Colors.white.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: _isBuyMode
                          ? const Color(0xFF00FFA3).withOpacity(0.4)
                          : Colors.red.withOpacity(0.4),
                    ),
                    child: _isTrading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Processing...',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isBuyMode
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isBuyMode ? 'BUY SHARES' : 'SELL SHARES',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
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
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
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
                  Icon(
                    Icons.account_balance_wallet,
                    color: const Color(0xFF00FFA3),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Portfolio Summary',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildPortfolioCard(
                      'Available Cash',
                      '\$${portfolio.virtualCash.toStringAsFixed(2)}',
                      const Color(0xFF00FFA3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPortfolioCard(
                      'Total Value',
                      '\$${portfolio.totalPortfolioValue.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
