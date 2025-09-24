import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'gemini_ai_service.dart';

enum MascotType { trader, investor, analyst, banker, entrepreneur, broker }

enum MascotTrigger {
  tradeSuccess,
  tradeSellSuccess,
  analyticsView,
  questComplete,
  notEnoughCash,
  firstTrade,
  portfolioGrowth,
  marketCrash,
  dailyTip,
  achievementUnlocked,
  levelUp,
  welcome,
}

class MascotMessage {
  final String message;
  final MascotType mascot;
  final String emoji;
  final Color backgroundColor;
  final Duration duration;

  const MascotMessage({
    required this.message,
    required this.mascot,
    required this.emoji,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 3),
  });
}

class MascotManagerService {
  static final MascotManagerService _instance =
      MascotManagerService._internal();
  factory MascotManagerService() => _instance;
  MascotManagerService._internal();

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

  static const Map<MascotTrigger, MascotMessage> _contextMessages = {
    MascotTrigger.tradeSuccess: MascotMessage(
      message:
          "Boom! That's how you do it! Every trade is a step closer to becoming a market master. Keep it up!",
      mascot: MascotType.trader,
      emoji: "💰",
      backgroundColor: Color(0xFF4CAF50),
    ),
    MascotTrigger.tradeSellSuccess: MascotMessage(
      message:
          "Smart move, champ! Knowing when to sell is just as important as knowing when to buy. You're learning fast!",
      mascot: MascotType.investor,
      emoji: "📈",
      backgroundColor: Color(0xFF4CAF50),
    ),
    MascotTrigger.analyticsView: MascotMessage(
      message:
          "Excellent choice! Analytics are your best friend in investing. The more you understand the data, the better your decisions become!",
      mascot: MascotType.analyst,
      emoji: "📊",
      backgroundColor: Color(0xFF2196F3),
    ),
    MascotTrigger.questComplete: MascotMessage(
      message:
          "Quest completed! You're on fire! +100 XP earned. Keep completing quests to level up faster!",
      mascot: MascotType.trader, // Will be randomized
      emoji: "🎉",
      backgroundColor: Color(0xFF2196F3),
    ),
    MascotTrigger.notEnoughCash: MascotMessage(
      message:
          "Whoa there! Your virtual wallet is running low. Try a smaller amount or wait for some profits to roll in!",
      mascot: MascotType.banker,
      emoji: "💸",
      backgroundColor: Color(0xFF9C27B0),
    ),
    MascotTrigger.firstTrade: MascotMessage(
      message:
          "Hey there, future investor! I see you just made your first trade! Welcome to the exciting world of investing - you're gonna love it here!",
      mascot: MascotType.entrepreneur,
      emoji: "🚀",
      backgroundColor: Color(0xFFFF9800),
    ),
    MascotTrigger.portfolioGrowth: MascotMessage(
      message: "Your portfolio is growing! Keep up the great work!",
      mascot: MascotType.investor,
      emoji: "📈",
      backgroundColor: Color(0xFF00FFA3),
    ),
    MascotTrigger.marketCrash: MascotMessage(
      message:
          "Don't panic! Market dips are opportunities for smart investors.",
      mascot: MascotType.analyst,
      emoji: "💪",
      backgroundColor: Color(0xFF607D8B),
    ),
    MascotTrigger.achievementUnlocked: MascotMessage(
      message: "Achievement Unlocked! You're on fire! 🔥",
      mascot: MascotType.broker,
      emoji: "🏆",
      backgroundColor: Color(0xFFFFD700),
    ),
    MascotTrigger.levelUp: MascotMessage(
      message: "Level Up! You're becoming a financial wizard!",
      mascot: MascotType.entrepreneur,
      emoji: "⭐",
      backgroundColor: Color(0xFF00D4FF),
    ),
    MascotTrigger.welcome: MascotMessage(
      message: "Welcome back! Ready to make some smart moves today?",
      mascot: MascotType.trader,
      emoji: "👋",
      backgroundColor: Color(0xFF00FFA3),
    ),
  };

  // Daily tips for Mascot of the Day
  static const Map<MascotType, List<String>> _dailyTips = {
    MascotType.trader: [
      "Quick trades can be profitable, but always set stop-losses!",
      "Day trading requires discipline and risk management!",
      "Don't let emotions drive your trading decisions!",
      "Keep a trading journal to track your performance!",
      "Market volatility is your friend if you know how to use it!",
    ],
    MascotType.investor: [
      "Diversification is the key to long-term success!",
      "Time in the market beats timing the market!",
      "Invest in companies you understand and believe in!",
      "Compound interest is your best friend!",
      "A good portfolio is like a strong house—it's all about the foundation!",
    ],
    MascotType.analyst: [
      "Always do your research before making investment decisions!",
      "Technical analysis helps identify trends and patterns!",
      "Fundamental analysis reveals a company's true value!",
      "Market sentiment can be as important as fundamentals!",
      "Look for trends in the charts. Past performance can give clues!",
    ],
    MascotType.banker: [
      "Building good credit is essential for financial success!",
      "Emergency funds should cover 3-6 months of expenses!",
      "Understanding interest rates helps with loan decisions!",
      "Banking relationships can provide valuable financial services!",
      "A good portfolio is like a strong house—it's all about the foundation!",
    ],
    MascotType.entrepreneur: [
      "Start with a solid business plan and clear goals!",
      "Cash flow management is crucial for business survival!",
      "Network with other entrepreneurs and investors!",
      "Be prepared to pivot when market conditions change!",
      "Innovation is the key to staying ahead in business!",
    ],
    MascotType.broker: [
      "Execution speed matters in volatile markets!",
      "Always verify trade details before confirming!",
      "Keep clients informed about market conditions!",
      "Risk management is paramount in brokerage!",
      "Precision and speed are your greatest assets!",
    ],
  };

  static String getMascotImage(MascotType type) {
    return _mascotImages[type] ?? 'assets/images/Trader.png';
  }

  static String getMascotName(MascotType type) {
    return _mascotNames[type] ?? 'Trader Fox';
  }

  static MascotMessage getMessageForContext(MascotTrigger trigger) {
    final message =
        _contextMessages[trigger] ?? _contextMessages[MascotTrigger.welcome]!;

    // Randomize mascot for quest complete
    if (trigger == MascotTrigger.questComplete) {
      final randomMascots = [
        MascotType.trader,
        MascotType.investor,
        MascotType.entrepreneur,
      ];
      final randomMascot =
          randomMascots[math.Random().nextInt(randomMascots.length)];
      return MascotMessage(
        message: message.message,
        mascot: randomMascot,
        emoji: message.emoji,
        backgroundColor: message.backgroundColor,
        duration: message.duration,
      );
    }

    return message;
  }

  static MascotType getMascotOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final mascots = MascotType.values;
    return mascots[dayOfYear % mascots.length];
  }

  static String getDailyTip(MascotType mascot) {
    final tips = _dailyTips[mascot] ?? ['Keep learning and growing!'];
    final random = math.Random();
    return tips[random.nextInt(tips.length)];
  }

  static MascotMessage getPortfolioAdvice(Map<String, dynamic> portfolioData) {
    final virtualCash = portfolioData['virtualCash'] ?? 100000.0;
    final holdings = portfolioData['holdings'] ?? <String, int>{};
    final totalValue = portfolioData['totalValue'] ?? virtualCash;
    final gainLoss = totalValue - 100000.0;
    final gainLossPercent = (gainLoss / 100000.0) * 100;

    // Analyze portfolio and provide specific advice
    if (holdings.isEmpty) {
      return MascotMessage(
        mascot: MascotType.investor,
        emoji: "🚀",
        message:
            "Ready to start investing? Consider buying your first stock to begin building your portfolio!",
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 5),
      );
    } else if (holdings.length == 1) {
      return MascotMessage(
        mascot: MascotType.analyst,
        emoji: "📈",
        message:
            "Good start! Consider diversifying with stocks from different sectors to reduce risk.",
        backgroundColor: const Color(0xFF2196F3),
        duration: const Duration(seconds: 5),
      );
    } else if (gainLossPercent > 5) {
      return MascotMessage(
        mascot: MascotType.trader,
        emoji: "🎉",
        message:
            "Excellent performance! You're up ${gainLossPercent.toStringAsFixed(1)}%. Consider taking some profits!",
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 5),
      );
    } else if (gainLossPercent < -5) {
      return MascotMessage(
        mascot: MascotType.banker,
        emoji: "💪",
        message:
            "Don't worry about the dip! This is normal market behavior. Stay patient and think long-term.",
        backgroundColor: const Color(0xFF9C27B0),
        duration: const Duration(seconds: 5),
      );
    } else {
      return MascotMessage(
        mascot: MascotType.entrepreneur,
        emoji: "⚖️",
        message:
            "Your portfolio is well-balanced! Keep monitoring and adjusting as needed.",
        backgroundColor: const Color(0xFFFF9800),
        duration: const Duration(seconds: 5),
      );
    }
  }

  static Widget buildMascotPopup({
    required MascotMessage message,
    required VoidCallback onDismiss,
    required AnimationController animationController,
  }) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - animationController.value)),
          child: Opacity(
            opacity: animationController.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: message.backgroundColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mascot Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        getMascotImage(message.mascot),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.pets,
                              size: 30,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${message.emoji} ${getMascotName(message.mascot)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.message,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dismiss button
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget buildMascotOfTheDay({
    required MascotType mascot,
    required String tip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mascot Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  getMascotImage(mascot),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mascot of the Day',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FFA3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFFD700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getMascotName(mascot),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"$tip"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  // Generate AI-powered mascot message based on context
  static Future<MascotMessage> generateAIMascotMessage(
    MascotTrigger trigger, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // Get base message from static context
      final baseMessage =
          _contextMessages[trigger] ?? _contextMessages[MascotTrigger.welcome]!;

      // Create context-aware prompt for Gemini
      String prompt = _createContextPrompt(trigger, context);

      // Get AI response
      final aiResponse = await GeminiAIService.getFinancialAdvice(prompt);

      // Create mascot message with AI response but keep original mascot, emoji, and color
      return MascotMessage(
        message: aiResponse,
        mascot: baseMessage.mascot,
        emoji: baseMessage.emoji,
        backgroundColor: baseMessage.backgroundColor,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('Error generating AI mascot message: $e');
      // Fallback to static message if AI fails
      return _contextMessages[trigger] ??
          _contextMessages[MascotTrigger.welcome]!;
    }
  }

  // Create context-aware prompt for different triggers
  static String _createContextPrompt(
    MascotTrigger trigger,
    Map<String, dynamic>? context,
  ) {
    String basePrompt =
        "You are a friendly, encouraging financial mentor mascot in the Finx trading simulation app. ";

    switch (trigger) {
      case MascotTrigger.firstTrade:
        return basePrompt +
            "A user just made their very first trade! Give them an excited, welcoming message (under 30 words) celebrating this milestone and encouraging them to keep learning.";

      case MascotTrigger.tradeSuccess:
        final symbol = context?['symbol'] ?? 'stocks';
        final quantity = context?['quantity'] ?? 'some';
        return basePrompt +
            "A user just successfully bought $quantity shares of $symbol! Give them an encouraging message (under 30 words) celebrating their trade and motivating them to continue learning.";

      case MascotTrigger.tradeSellSuccess:
        final symbol = context?['symbol'] ?? 'stocks';
        final quantity = context?['quantity'] ?? 'some';
        return basePrompt +
            "A user just successfully sold $quantity shares of $symbol! Give them a smart, encouraging message (under 30 words) about the importance of knowing when to sell.";

      case MascotTrigger.analyticsView:
        return basePrompt +
            "A user is viewing their analytics dashboard! Give them an encouraging message (under 30 words) about the importance of data analysis in investing.";

      case MascotTrigger.questComplete:
        final questTitle = context?['questTitle'] ?? 'a quest';
        return basePrompt +
            "A user just completed '$questTitle' quest! Give them a congratulatory message (under 30 words) celebrating their achievement and encouraging them to keep going.";

      case MascotTrigger.notEnoughCash:
        return basePrompt +
            "A user tried to make a trade but doesn't have enough virtual cash! Give them a helpful, encouraging message (under 30 words) about money management and risk control.";

      case MascotTrigger.portfolioGrowth:
        final growthPercent = context?['growthPercent'] ?? 'positive';
        return basePrompt +
            "A user's portfolio is showing $growthPercent growth! Give them a congratulatory message (under 30 words) celebrating their success and encouraging continued learning.";

      case MascotTrigger.marketCrash:
        return basePrompt +
            "The market is experiencing volatility! Give users a reassuring, educational message (under 30 words) about staying calm during market dips and seeing opportunities.";

      case MascotTrigger.achievementUnlocked:
        final achievement = context?['achievement'] ?? 'an achievement';
        return basePrompt +
            "A user just unlocked '$achievement'! Give them a celebratory message (under 30 words) congratulating them and encouraging them to earn more achievements.";

      case MascotTrigger.levelUp:
        final newLevel = context?['newLevel'] ?? 'a new level';
        return basePrompt +
            "A user just leveled up to $newLevel! Give them a congratulatory message (under 30 words) celebrating their progress and encouraging continued learning.";

      case MascotTrigger.welcome:
        return basePrompt +
            "A user is logging into the app! Give them a warm, welcoming message (under 30 words) encouraging them to start their trading journey.";

      case MascotTrigger.dailyTip:
        return basePrompt +
            "Give users a helpful daily trading tip (under 30 words) that's educational and encouraging for beginners learning about investing.";
    }
  }
}
