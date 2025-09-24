import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_provider.dart';
import '../widgets/sparkline_widget.dart';

class TradeScreen extends StatefulWidget {
  final Map<String, dynamic> stockData;

  const TradeScreen({super.key, required this.stockData});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  final TextEditingController _quantityController = TextEditingController();
  bool _isBuyMode = true;
  bool _isTrading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  double get _currentPrice {
    if (!mounted) return 248.50; // Default Tesla price
    final portfolio = context.read<PortfolioProvider>();
    final price = portfolio.currentPrices['TSLA'];
    if (price != null) {
      return price;
    }
    return 248.50; // Default Tesla price
  }

  int get _currentHolding {
    if (!mounted) return 0;
    final portfolio = context.read<PortfolioProvider>();
    return portfolio.getStockQuantity('TSLA');
  }

  double get _currentHoldingValue {
    if (!mounted) return 0.0;
    final portfolio = context.read<PortfolioProvider>();
    return portfolio.getStockValue('TSLA');
  }

  Future<void> _executeTrade() async {
    print(
      'Execute trade called - isBuyMode: $_isBuyMode, quantity: ${_quantityController.text}',
    );
    if (!mounted) return;

    if (_quantityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter quantity';
      });
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      setState(() {
        _errorMessage = 'Please enter valid quantity';
      });
      return;
    }

    setState(() {
      _isTrading = true;
      _errorMessage = null;
    });

    if (!mounted) return;

    final portfolio = context.read<PortfolioProvider>();
    final success = await portfolio.executeTrade(
      symbol: 'TSLA',
      quantity: quantity,
      price: _currentPrice,
      type: _isBuyMode ? TransactionType.buy : TransactionType.sell,
    );

    if (!mounted) return;

    if (success) {
      _successController.forward();
      _quantityController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _isBuyMode
                      ? 'Successfully bought $quantity shares!'
                      : 'Successfully sold $quantity shares!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00FFA3),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = _isBuyMode
              ? 'Insufficient funds'
              : 'Insufficient shares';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isTrading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStockHeader(),
                    const SizedBox(height: 15),
                    _buildPriceCard(),
                    const SizedBox(height: 15),
                    _buildPositionCard(),
                    const SizedBox(height: 15),
                    _buildTradingInterface(),
                    const SizedBox(height: 15),
                    _buildRecentTransactions(),
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
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Trade',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStockHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tesla Inc.',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'TSLA',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Price',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFA3).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FFA3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_currentPrice.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FFA3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Price Chart',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SparklineWidget(
                prices: [
                  240,
                  245,
                  250,
                  248,
                  252,
                  248,
                  250,
                  255,
                  260,
                  258,
                  262,
                  265,
                  268,
                  270,
                  275,
                  280,
                  285,
                  290,
                  295,
                  300,
                ],
                lineColor: Color(0xFF00FFA3),
                height: 180,
                width: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Position',
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
                child: _buildPositionItem(
                  'Available Cash',
                  '\$${context.watch<PortfolioProvider>().virtualCash.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  const Color(0xFF00FFA3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPositionItem(
                  'TSLA Shares',
                  '${_currentHolding}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPositionItem(
            'TSLA Value',
            '\$${_currentHoldingValue.toStringAsFixed(2)}',
            Icons.analytics,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingInterface() {
    print('Building trading interface');
    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), // Slightly more visible
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ), // More visible border
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
                  fontSize: 20, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Increased spacing
          _buildBuySellToggle(),
          const SizedBox(height: 20), // Increased spacing
          _buildQuantityInput(),
          const SizedBox(height: 20), // Increased spacing
          _buildEstimatedCost(),
          const SizedBox(height: 20), // Increased spacing
          _buildTradeButton(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBuySellToggle() {
    print('Building buy/sell toggle - isBuyMode: $_isBuyMode');
    return Container(
      padding: const EdgeInsets.all(8), // Even more padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Much more visible background
        borderRadius: BorderRadius.circular(20), // Even bigger border radius
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.5),
          width: 2,
        ), // Bright border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ), // Even more padding
                decoration: BoxDecoration(
                  color: _isBuyMode
                      ? const Color(0xFF00FFA3)
                      : Colors.white.withOpacity(
                          0.1,
                        ), // Always visible background
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Bigger border radius
                  border: Border.all(
                    color: _isBuyMode
                        ? const Color(0xFF00FFA3)
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: _isBuyMode
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: _isBuyMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      size: 22, // Bigger icon
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'BUY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22, // Much bigger font size
                        fontWeight: FontWeight.bold,
                        color: _isBuyMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Increased spacing
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBuyMode = false;
                  _errorMessage = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ), // Even more padding
                decoration: BoxDecoration(
                  color: !_isBuyMode
                      ? Colors.red
                      : Colors.white.withOpacity(
                          0.1,
                        ), // Always visible background
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Bigger border radius
                  border: Border.all(
                    color: !_isBuyMode
                        ? Colors.red
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: !_isBuyMode
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: !_isBuyMode
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      size: 22, // Bigger icon
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'SELL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22, // Much bigger font size
                        fontWeight: FontWeight.bold,
                        color: !_isBuyMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
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
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter quantity',
            hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
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
              color: const Color(0xFF00FFA3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeButton() {
    print(
      'Building trade button - isBuyMode: $_isBuyMode, isTrading: $_isTrading',
    );
    return Container(
      width: double.infinity,
      height: 70, // Even bigger height to make it more prominent
      margin: const EdgeInsets.only(top: 10), // Add margin for separation
      child: AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimation.value,
            child: ElevatedButton(
              onPressed: _isTrading ? null : _executeTrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBuyMode
                    ? const Color(0xFF00FFA3)
                    : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ), // Much bigger padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Bigger border radius
                  side: BorderSide(
                    color: _isBuyMode ? const Color(0xFF00FFA3) : Colors.red,
                    width: 3, // Thick border
                  ),
                ),
                elevation: 15, // Even higher elevation for more prominence
                shadowColor: _isBuyMode
                    ? const Color(0xFF00FFA3).withOpacity(0.8)
                    : Colors.red.withOpacity(0.8),
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
                          _isBuyMode ? Icons.trending_up : Icons.trending_down,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isBuyMode ? 'BUY SHARES' : 'SELL SHARES',
                          style: GoogleFonts.inter(
                            fontSize: 24, // Even bigger font
                            fontWeight: FontWeight.bold,
                            letterSpacing:
                                1.2, // Add letter spacing for emphasis
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<PortfolioProvider>(
            builder: (context, portfolio, child) {
              final transactions = portfolio.getRecentTransactions(limit: 5);
              if (transactions.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions yet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }
              return Column(
                children: transactions.map((transaction) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          transaction.type == TransactionType.buy
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: transaction.type == TransactionType.buy
                              ? const Color(0xFF00FFA3)
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${transaction.type == TransactionType.buy ? 'Bought' : 'Sold'} ${transaction.quantity} ${transaction.symbol}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'at \$${transaction.price.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(transaction.quantity * transaction.price).toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: transaction.type == TransactionType.buy
                                ? const Color(0xFF00FFA3)
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
