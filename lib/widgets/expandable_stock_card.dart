import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sparkline_widget.dart';

class ExpandableStockCard extends StatefulWidget {
  final Map<String, dynamic> stockData;
  final bool isDesktop;

  const ExpandableStockCard({
    super.key,
    required this.stockData,
    required this.isDesktop,
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

  @override
  Widget build(BuildContext context) {
    final symbol = widget.stockData['symbol'] ?? 'N/A';
    final name = widget.stockData['name'] ?? 'Unknown Company';
    final price = (widget.stockData['currentPrice'] ?? 0.0).toDouble();
    final change = (widget.stockData['change'] ?? 0.0).toDouble();
    final changePercent = (widget.stockData['changePercent'] ?? 0.0).toDouble();
    final priceHistory = widget.stockData['priceHistory'] as List<dynamic>?;
    final volume = (widget.stockData['volume'] ?? 0).toInt();

    // Calculate percentage from price history if available
    double calculatedChangePercent = changePercent;
    if (priceHistory != null && priceHistory.length >= 2) {
      final prices = priceHistory.map((p) => (p as num).toDouble()).toList();
      final currentPrice = prices.last;
      final previousPrice = prices[prices.length - 2];
      calculatedChangePercent =
          ((currentPrice - previousPrice) / previousPrice) * 100;
    }

    final cardWidth = widget.isDesktop ? 200.0 : 160.0;
    final cardHeight = widget.isDesktop ? 140.0 : 120.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
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
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF00FFA3).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00FFA3).withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
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
                  // Header with symbol and name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          symbol,
                          style: GoogleFonts.inter(
                            fontSize: widget.isDesktop ? 16 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_isHovered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: calculatedChangePercent >= 0
                                ? const Color(0xFF00FFA3).withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            calculatedChangePercent >= 0 ? 'GAINER' : 'LOSER',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: calculatedChangePercent >= 0
                                  ? const Color(0xFF00FFA3)
                                  : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: widget.isDesktop ? 11 : 9,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price History Sparkline
                  if (priceHistory != null && priceHistory.isNotEmpty)
                    Expanded(
                      child: SparklineWidget(
                        prices: priceHistory
                            .map((p) => (p as num).toDouble())
                            .toList(),
                        width: cardWidth - 24,
                        height: 30,
                        lineColor: calculatedChangePercent >= 0
                            ? const Color(0xFF00FFA3)
                            : Colors.red,
                        fillColor: calculatedChangePercent >= 0
                            ? const Color(0x1A00FFA3)
                            : Colors.red.withOpacity(0.1),
                        strokeWidth: 2.0,
                      ),
                    )
                  else
                    Container(
                      height: 30,
                      width: cardWidth - 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '—',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Price and change info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: widget.isDesktop ? 14 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            calculatedChangePercent >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: widget.isDesktop ? 12 : 8,
                            color: calculatedChangePercent >= 0
                                ? const Color(0xFF00FFA3)
                                : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${calculatedChangePercent >= 0 ? '+' : ''}${calculatedChangePercent.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                              fontSize: widget.isDesktop ? 12 : 9,
                              color: calculatedChangePercent >= 0
                                  ? const Color(0xFF00FFA3)
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Additional info on hover
                  if (_isHovered) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Volume: ${_formatVolume(volume)}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${priceHistory?.length ?? 0} data points',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toString();
    }
  }
}
