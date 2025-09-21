import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/trade_screen.dart';
import 'sparkline_widget.dart';

class ExpandableStockCard extends StatefulWidget {
  final Map<String, dynamic> stockData;
  final bool isDesktop;

  const ExpandableStockCard({
    super.key,
    required this.stockData,
    this.isDesktop = false,
  });

  @override
  State<ExpandableStockCard> createState() => _ExpandableStockCardState();
}

class _ExpandableStockCardState extends State<ExpandableStockCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final symbol = widget.stockData['symbol'] ?? 'N/A';
    final name = widget.stockData['name'] ?? 'Unknown';
    final currentPrice = (widget.stockData['currentPrice'] ?? 0.0).toDouble();
    final priceHistory = widget.stockData['priceHistory'] as List<dynamic>?;

    // Calculate change percent from history if available, otherwise use provided
    double calculatedChangePercent = (widget.stockData['changePercent'] ?? 0.0)
        .toDouble();
    if (priceHistory != null && priceHistory.length >= 2) {
      try {
        final lastItem = priceHistory.last;
        final secondLastItem = priceHistory[priceHistory.length - 2];

        double lastPrice;
        double secondLastPrice;

        if (lastItem is Map<String, dynamic>) {
          lastPrice = (lastItem['close'] ?? 0.0).toDouble();
        } else if (lastItem is num) {
          lastPrice = lastItem.toDouble();
        } else {
          lastPrice = 0.0;
        }

        if (secondLastItem is Map<String, dynamic>) {
          secondLastPrice = (secondLastItem['close'] ?? 0.0).toDouble();
        } else if (secondLastItem is num) {
          secondLastPrice = secondLastItem.toDouble();
        } else {
          secondLastPrice = 0.0;
        }

        if (secondLastPrice != 0) {
          calculatedChangePercent =
              ((lastPrice - secondLastPrice) / secondLastPrice) * 100;
        }
      } catch (e) {
        print('Error calculating change percent: $e');
        // Keep the original calculatedChangePercent
      }
    }

    final isPositive = calculatedChangePercent >= 0;

    final cardWidth = widget.isDesktop ? 360.0 : 320.0; // Bigger width
    final cardHeight = widget.isDesktop ? 280.0 : 260.0; // Bigger height

    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _isHovered = true;
          });
          _animationController.forward();
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _isHovered = false;
          });
          _animationController.reverse();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TradeScreen(stockData: widget.stockData),
              ),
            );
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? const Color(0xFF00FFA3).withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          symbol,
                          style: GoogleFonts.inter(
                            fontSize: widget.isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // GAINER/LOSER badge
                        if (_isHovered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFF00FFA3).withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPositive
                                    ? const Color(0xFF00FFA3)
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isPositive ? 'GAINER' : 'LOSER',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? const Color(0xFF00FFA3)
                                    : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: widget.isDesktop ? 12 : 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${currentPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: widget.isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: isPositive
                                    ? const Color(0xFF00FFA3)
                                    : Colors.red,
                                size: widget.isDesktop ? 16 : 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${calculatedChangePercent.toStringAsFixed(1)}%',
                                style: GoogleFonts.inter(
                                  fontSize: widget.isDesktop ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: isPositive
                                      ? const Color(0xFF00FFA3)
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isHovered &&
                        priceHistory != null &&
                        priceHistory.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPositive
                                ? const Color(0xFF00FFA3).withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timeline,
                                  size: widget.isDesktop ? 12 : 10,
                                  color: isPositive
                                      ? const Color(0xFF00FFA3)
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Price History',
                                  style: GoogleFonts.inter(
                                    fontSize: widget.isDesktop ? 10 : 8,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatPriceHistory(priceHistory),
                              style: GoogleFonts.inter(
                                fontSize: widget.isDesktop ? 9 : 7,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ).copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Enhanced Sparkline Chart - MUCH BIGGER
                    Expanded(
                      child: Container(
                        height: widget.isDesktop
                            ? 80
                            : 70, // Much bigger height
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.2),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Bigger border radius
                          border: Border.all(
                            color: isPositive
                                ? const Color(0xFF00FFA3).withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                            width: 2, // Thicker border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPositive
                                  ? const Color(0xFF00FFA3).withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8), // More padding
                          child: SparklineWidget(
                            prices: _extractPricesFromHistory(priceHistory),
                            lineColor: isPositive
                                ? const Color(0xFF00FFA3)
                                : Colors.red,
                            fillColor: isPositive
                                ? const Color(0xFF00FFA3).withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            height: widget.isDesktop
                                ? 60
                                : 50, // Explicit height
                            width: double.infinity, // Full width
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<double> _extractPricesFromHistory(List<dynamic>? priceHistory) {
    if (priceHistory == null || priceHistory.isEmpty) return [];

    try {
      return priceHistory.map<double>((e) {
        if (e is Map<String, dynamic>) {
          return (e['close'] ?? 0.0).toDouble();
        } else if (e is num) {
          return e.toDouble();
        } else {
          return 0.0;
        }
      }).toList();
    } catch (e) {
      print('Error extracting prices from history: $e');
      return [];
    }
  }

  String _formatPriceHistory(List<dynamic> priceHistory) {
    try {
      final prices = _extractPricesFromHistory(priceHistory);
      if (prices.isEmpty) return 'No data';

      // Show last 5 prices
      final recentPrices = prices.length > 5
          ? prices.sublist(prices.length - 5)
          : prices;

      return recentPrices
          .map((price) => '\$${price.toStringAsFixed(2)}')
          .join(' → ');
    } catch (e) {
      return 'Error loading data';
    }
  }
}
