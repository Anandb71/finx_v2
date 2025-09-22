import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/portfolio_provider.dart';

class ModernStockCard extends StatefulWidget {
  final Map<String, dynamic> stockData;
  final bool isDesktop;
  final VoidCallback? onTap;

  const ModernStockCard({
    super.key,
    required this.stockData,
    this.isDesktop = false,
    this.onTap,
  });

  @override
  State<ModernStockCard> createState() => _ModernStockCardState();
}

class _ModernStockCardState extends State<ModernStockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() {
      _isHovered = true;
    });
    _animationController.forward();
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
    });
    _animationController.reverse();
  }

  List<double> _extractPricesFromHistory(dynamic priceHistory) {
    if (priceHistory == null || priceHistory is! List) return [];
    return priceHistory.map((e) => (e as num).toDouble()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = widget.stockData['symbol'] ?? 'N/A';
    final name = widget.stockData['name'] ?? 'Unknown Company';

    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        // Get real-time price from PortfolioProvider
        final realTimePrice = portfolio.currentPrices[symbol] ?? 0.0;
        final currentPrice = realTimePrice > 0
            ? realTimePrice
            : (widget.stockData['currentPrice'] ?? 0.0).toDouble();

        // Debug print for real-time updates
        if (realTimePrice > 0) {
          print(
            '📊 Real-time update for $symbol: \$${currentPrice.toStringAsFixed(2)}',
          );
        }

        final priceHistory = _extractPricesFromHistory(
          widget.stockData['priceHistory'],
        );

        // Calculate change percentage from price history
        double changePercent = 0.0;
        if (priceHistory.length >= 2) {
          final firstPrice = priceHistory.first;
          final lastPrice = priceHistory.last;
          changePercent = ((lastPrice - firstPrice) / firstPrice) * 100;
        }

        final isPositive = changePercent >= 0;
        final changeColor = isPositive ? const Color(0xFF00FFA3) : Colors.red;
        final cardWidth = widget.isDesktop ? 280.0 : 260.0;
        final cardHeight = widget.isDesktop ? 200.0 : 180.0;

        return MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // More rounded corners
                      border: Border.all(
                        color: _isHovered
                            ? changeColor.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        width: _isHovered ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        if (_isHovered)
                          BoxShadow(
                            color: changeColor.withOpacity(0.2),
                            blurRadius: 25,
                            spreadRadius: 0,
                            offset: const Offset(0, 12),
                          ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top section: Logo + Symbol + Name
                          Row(
                            children: [
                              // Company Logo
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      changeColor,
                                      changeColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: changeColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    symbol.isNotEmpty ? symbol[0] : '?',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
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
                                    const SizedBox(height: 2),
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Status indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPositive
                                      ? const Color(0xFF00FFA3).withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: changeColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isPositive ? 'GAINER' : 'LOSER',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: changeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Sparkline Chart
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    changeColor.withOpacity(0.1),
                                    changeColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: changeColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: _buildGradientSparkline(
                                  prices: priceHistory,
                                  color: changeColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Bottom section: Price + Change
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${currentPrice.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Current Price',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        size: 16,
                                        color: changeColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: changeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '24h Change',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }

  Widget _buildGradientSparkline({
    required List<double> prices,
    required Color color,
  }) {
    if (prices.isEmpty) {
      return Center(
        child: Text(
          'No Data',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return CustomPaint(
      painter: GradientSparklinePainter(prices: prices, color: color),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class GradientSparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color color;

  GradientSparklinePainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final path = Path();
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    final stepX = size.width / (prices.length - 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final normalizedPrice = (prices[i] - minPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Create gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color, color.withOpacity(0.3)],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw the line with gradient
    canvas.drawPath(path, gradientPaint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
