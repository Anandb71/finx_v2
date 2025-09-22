import 'package:flutter/material.dart';

enum MascotType { trader, investor, analyst, banker, entrepreneur, broker }

class MascotService {
  static const Map<MascotType, String> _mascotImages = {
    MascotType.trader: 'assets/images/Trader.png',
    MascotType.investor: 'assets/images/Investor.png',
    MascotType.analyst: 'assets/images/Analyst.png',
    MascotType.banker: 'assets/images/Banker.png',
    MascotType.entrepreneur: 'assets/images/Enterpreneur.png',
    MascotType.broker: 'assets/images/Broker.png',
  };

  static const Map<MascotType, String> _mascotNames = {
    MascotType.trader: 'Trader Fox',
    MascotType.investor: 'Investor Fox',
    MascotType.analyst: 'Analyst Fox',
    MascotType.banker: 'Banker Fox',
    MascotType.entrepreneur: 'Entrepreneur Fox',
    MascotType.broker: 'Broker Fox',
  };

  static const Map<MascotType, String> _mascotPersonalities = {
    MascotType.trader: 'Excited and energetic about quick trades!',
    MascotType.investor: 'Proud and confident about long-term investments!',
    MascotType.analyst: 'Focused and analytical about market data!',
    MascotType.banker: 'Confident and professional about financial services!',
    MascotType.entrepreneur:
        'Optimistic and innovative about business ventures!',
    MascotType.broker: 'Stressed but determined about market execution!',
  };

  static const Map<MascotType, List<String>> _mascotTips = {
    MascotType.trader: [
      "Quick trades can be profitable, but always set stop-losses!",
      "Day trading requires discipline and risk management!",
      "Don't let emotions drive your trading decisions!",
      "Keep a trading journal to track your performance!",
    ],
    MascotType.investor: [
      "Diversification is the key to long-term success!",
      "Time in the market beats timing the market!",
      "Invest in companies you understand and believe in!",
      "Compound interest is your best friend!",
    ],
    MascotType.analyst: [
      "Always do your research before making investment decisions!",
      "Technical analysis helps identify trends and patterns!",
      "Fundamental analysis reveals a company's true value!",
      "Market sentiment can be as important as fundamentals!",
    ],
    MascotType.banker: [
      "Building good credit is essential for financial success!",
      "Emergency funds should cover 3-6 months of expenses!",
      "Understanding interest rates helps with loan decisions!",
      "Banking relationships can provide valuable financial services!",
    ],
    MascotType.entrepreneur: [
      "Start with a solid business plan and clear goals!",
      "Cash flow management is crucial for business survival!",
      "Network with other entrepreneurs and investors!",
      "Be prepared to pivot when market conditions change!",
    ],
    MascotType.broker: [
      "Execution speed matters in volatile markets!",
      "Always verify trade details before confirming!",
      "Keep clients informed about market conditions!",
      "Risk management is paramount in brokerage!",
    ],
  };

  static String getMascotImage(MascotType type) {
    return _mascotImages[type] ?? 'assets/images/Trader.png';
  }

  static String getMascotName(MascotType type) {
    return _mascotNames[type] ?? 'Trader Fox';
  }

  static String getMascotPersonality(MascotType type) {
    return _mascotPersonalities[type] ?? 'Excited and energetic!';
  }

  static List<String> getMascotTips(MascotType type) {
    return _mascotTips[type] ?? ['Keep learning and growing!'];
  }

  static MascotType getMascotForContext(String context) {
    switch (context.toLowerCase()) {
      case 'trading':
      case 'trade':
      case 'day trading':
        return MascotType.trader;
      case 'investing':
      case 'investment':
      case 'portfolio':
        return MascotType.investor;
      case 'analysis':
      case 'analytics':
      case 'charts':
        return MascotType.analyst;
      case 'banking':
      case 'loans':
      case 'credit':
        return MascotType.banker;
      case 'entrepreneurship':
      case 'business':
      case 'startup':
        return MascotType.entrepreneur;
      case 'brokerage':
      case 'execution':
      case 'orders':
        return MascotType.broker;
      default:
        return MascotType.trader;
    }
  }

  static Widget buildMascotWidget({
    required MascotType type,
    double size = 100,
    bool showName = true,
    bool showPersonality = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  getMascotImage(type),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (showName) ...[
              const SizedBox(height: 8),
              Text(
                getMascotName(type),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showPersonality) ...[
              const SizedBox(height: 4),
              Text(
                getMascotPersonality(type),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
