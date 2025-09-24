import 'dart:math';
import 'dart:convert';
import '../models/challenge.dart';
import 'gemini_ai_service.dart';

class DynamicQuestGenerator {
  static final Random _random = Random();

  /// Generates personalized quests based on user's portfolio and activity
  static Future<List<Challenge>> generatePersonalizedQuests({
    required Map<String, int> holdings,
    required double virtualCash,
    required double totalPortfolioValue,
    required int userLevel,
    required int totalTrades,
    required List<Map<String, dynamic>> transactionHistory,
    required Map<String, double> currentPrices,
  }) async {
    List<Challenge> quests = [];

    // Analyze portfolio composition
    final portfolioAnalysis = _analyzePortfolio(holdings, currentPrices);

    // Generate AI-powered quests
    try {
      final aiQuests = await _generateAIQuests(
        portfolioAnalysis: portfolioAnalysis,
        userLevel: userLevel,
        totalTrades: totalTrades,
        virtualCash: virtualCash,
        totalPortfolioValue: totalPortfolioValue,
      );
      quests.addAll(aiQuests);
    } catch (e) {
      print('Error generating AI quests: $e');
      // Fallback to static quests if AI fails
      quests.addAll(_getFallbackQuests(userLevel, totalTrades));
    }

    // Add level-appropriate quests
    quests.addAll(_generateLevelBasedQuests(userLevel, totalTrades));

    // Add diversification quests based on portfolio analysis
    if (portfolioAnalysis['needsDiversification'] == true) {
      quests.addAll(_generateDiversificationQuests(portfolioAnalysis));
    }

    // Add risk management quests
    if (portfolioAnalysis['riskLevel'] == 'high') {
      quests.addAll(_generateRiskManagementQuests());
    }

    // Shuffle and return top 4 quests
    quests.shuffle(_random);
    return quests.take(4).toList();
  }

  /// Analyzes the user's portfolio to identify patterns and opportunities
  static Map<String, dynamic> _analyzePortfolio(
    Map<String, int> holdings,
    Map<String, double> currentPrices,
  ) {
    if (holdings.isEmpty) {
      return {
        'sectorDistribution': {},
        'needsDiversification': true,
        'riskLevel': 'low',
        'concentration': 0.0,
        'sectors': [],
        'topHolding': null,
        'portfolioSize': 0,
      };
    }

    // Define sector mapping
    final sectorMapping = {
      'AAPL': 'Technology',
      'MSFT': 'Technology',
      'GOOGL': 'Technology',
      'META': 'Technology',
      'NVDA': 'Technology',
      'AMD': 'Technology',
      'INTC': 'Technology',
      'TSLA': 'Automotive',
      'AMZN': 'Consumer Discretionary',
      'NFLX': 'Communication Services',
      'JPM': 'Financial',
      'JNJ': 'Healthcare',
      'PG': 'Consumer Staples',
      'KO': 'Consumer Staples',
      'WMT': 'Consumer Staples',
      'XOM': 'Energy',
      'CVX': 'Energy',
    };

    // Calculate sector distribution
    Map<String, double> sectorDistribution = {};
    double totalValue = 0;
    String? topHolding;
    double maxValue = 0;

    for (final entry in holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final price = currentPrices[symbol] ?? 0.0;
      final value = quantity * price;
      totalValue += value;

      if (value > maxValue) {
        maxValue = value;
        topHolding = symbol;
      }

      final sector = sectorMapping[symbol] ?? 'Other';
      sectorDistribution[sector] = (sectorDistribution[sector] ?? 0) + value;
    }

    // Calculate concentration (largest holding percentage)
    final concentration = totalValue > 0 ? maxValue / totalValue : 0.0;

    // Determine if diversification is needed
    final needsDiversification =
        sectorDistribution.length < 2 || concentration > 0.5;

    // Determine risk level
    String riskLevel = 'low';
    if (concentration > 0.7) {
      riskLevel = 'high';
    } else if (concentration > 0.4 || sectorDistribution.length < 3) {
      riskLevel = 'medium';
    }

    return {
      'sectorDistribution': sectorDistribution,
      'needsDiversification': needsDiversification,
      'riskLevel': riskLevel,
      'concentration': concentration,
      'sectors': sectorDistribution.keys.toList(),
      'topHolding': topHolding,
      'portfolioSize': holdings.length,
      'totalValue': totalValue,
    };
  }

  /// Generates AI-powered quests using Gemini
  static Future<List<Challenge>> _generateAIQuests({
    required Map<String, dynamic> portfolioAnalysis,
    required int userLevel,
    required int totalTrades,
    required double virtualCash,
    required double totalPortfolioValue,
  }) async {
    final prompt = _createQuestGenerationPrompt(
      portfolioAnalysis: portfolioAnalysis,
      userLevel: userLevel,
      totalTrades: totalTrades,
      virtualCash: virtualCash,
      totalPortfolioValue: totalPortfolioValue,
    );

    try {
      final aiResponse = await GeminiAIService.getFinancialAdvice(prompt);
      return _parseAIQuests(aiResponse);
    } catch (e) {
      print('Error generating AI quests: $e');
      return [];
    }
  }

  /// Creates a detailed prompt for AI quest generation
  static String _createQuestGenerationPrompt({
    required Map<String, dynamic> portfolioAnalysis,
    required int userLevel,
    required int totalTrades,
    required double virtualCash,
    required double totalPortfolioValue,
  }) {
    return '''
You are an expert financial mentor creating personalized trading quests for a gamified investment learning app.

USER PROFILE:
- Level: $userLevel
- Total Trades: $totalTrades
- Virtual Cash: \$${virtualCash.toStringAsFixed(2)}
- Portfolio Value: \$${totalPortfolioValue.toStringAsFixed(2)}

PORTFOLIO ANALYSIS:
- Sectors: ${portfolioAnalysis['sectors']?.join(', ') ?? 'None'}
- Risk Level: ${portfolioAnalysis['riskLevel']}
- Needs Diversification: ${portfolioAnalysis['needsDiversification']}
- Top Holding: ${portfolioAnalysis['topHolding'] ?? 'None'}
- Portfolio Size: ${portfolioAnalysis['portfolioSize']} stocks

Create 2-3 personalized quests that:
1. Are appropriate for their level and experience
2. Address specific portfolio weaknesses or opportunities
3. Are educational and help them learn
4. Have clear, achievable objectives
5. Offer meaningful rewards

Format each quest as JSON:
{
  "title": "Quest Title",
  "description": "Clear description of what to do",
  "objective": "Specific measurable goal",
  "reward": "XP amount",
  "difficulty": "Easy/Medium/Hard",
  "category": "Diversification/Risk Management/Learning/Trading"
}

Return only the JSON array, no other text.
''';
  }

  /// Parses AI response into Challenge objects
  static List<Challenge> _parseAIQuests(String aiResponse) {
    try {
      // Extract JSON from response (remove any markdown formatting)
      String jsonString = aiResponse.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      // Parse JSON and create challenges
      final List<dynamic> questsJson = json.decode(jsonString);
      return questsJson
          .map(
            (quest) => Challenge(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
              title: quest['title'] ?? 'AI Generated Quest',
              description:
                  quest['description'] ?? 'Complete this quest to earn rewards',
              type: ChallengeType.daily,
              status: ChallengeStatus.available,
              xpReward: quest['reward'] ?? 100,
              coinReward: 0,
              requirements: {
                'objective': quest['objective'] ?? 'Complete the objective',
                'target': 1,
              },
              progress: {'current': 0, 'target': 1},
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 7)),
              icon: _getQuestIcon(quest['category'] ?? 'Learning'),
              mascotMessage: 'Complete this quest to earn rewards!',
            ),
          )
          .toList();
    } catch (e) {
      print('Error parsing AI quests: $e');
      return [];
    }
  }

  /// Generates level-appropriate quests
  static List<Challenge> _generateLevelBasedQuests(
    int userLevel,
    int totalTrades,
  ) {
    List<Challenge> quests = [];

    if (userLevel <= 2) {
      quests.add(
        Challenge(
          id: 'level_1_first_trade',
          title: 'Make Your First Trade',
          description:
              'Start your investment journey by making your first trade',
          type: ChallengeType.daily,
          status: totalTrades > 0
              ? ChallengeStatus.completed
              : ChallengeStatus.available,
          xpReward: 250,
          coinReward: 0,
          requirements: {'trades': 1},
          progress: {'trades': totalTrades > 0 ? 1 : 0},
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          icon: '💰',
          mascotMessage: 'Make your first trade to start earning!',
        ),
      );
    }

    if (userLevel <= 5) {
      quests.add(
        Challenge(
          id: 'level_3_diversify',
          title: 'Diversify Your Portfolio',
          description: 'Own stocks from at least 2 different sectors',
          type: ChallengeType.daily,
          status: ChallengeStatus.available,
          xpReward: 300,
          coinReward: 0,
          requirements: {'sectors': 2},
          progress: {'sectors': 0},
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          icon: '🌐',
          mascotMessage: 'Diversify your portfolio to reduce risk!',
        ),
      );
    }

    if (userLevel >= 3) {
      quests.add(
        Challenge(
          id: 'level_3_risk_management',
          title: 'Risk Management Master',
          description:
              'Learn to manage risk by not putting all your money in one stock',
          type: ChallengeType.daily,
          status: ChallengeStatus.available,
          xpReward: 400,
          coinReward: 0,
          requirements: {'max_concentration': 0.4},
          progress: {'max_concentration': 1.0},
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          icon: '🛡️',
          mascotMessage: 'Keep your largest holding under 40%!',
        ),
      );
    }

    return quests;
  }

  /// Generates diversification-focused quests
  static List<Challenge> _generateDiversificationQuests(
    Map<String, dynamic> portfolioAnalysis,
  ) {
    List<Challenge> quests = [];

    final sectors = portfolioAnalysis['sectors'] as List<String>? ?? [];
    final neededSectors = [
      'Technology',
      'Healthcare',
      'Financial',
      'Consumer Staples',
      'Energy',
    ].where((sector) => !sectors.contains(sector)).toList();

    if (neededSectors.isNotEmpty) {
      quests.add(
        Challenge(
          id: 'diversify_${neededSectors.first.toLowerCase()}',
          title: 'Explore ${neededSectors.first} Sector',
          description:
              'Add a stock from the ${neededSectors.first} sector to diversify your portfolio',
          type: ChallengeType.daily,
          status: ChallengeStatus.available,
          xpReward: 350,
          coinReward: 0,
          requirements: {'sector_stocks': 1, 'sector': neededSectors.first},
          progress: {'sector_stocks': 0},
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          icon: '🌐',
          mascotMessage: 'Explore the ${neededSectors.first} sector!',
        ),
      );
    }

    return quests;
  }

  /// Generates risk management quests
  static List<Challenge> _generateRiskManagementQuests() {
    return [
      Challenge(
        id: 'risk_reduce_concentration',
        title: 'Reduce Concentration Risk',
        description:
            'No single stock should be more than 30% of your portfolio',
        type: ChallengeType.daily,
        status: ChallengeStatus.available,
        xpReward: 500,
        coinReward: 0,
        requirements: {'max_concentration': 0.3},
        progress: {'max_concentration': 1.0},
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        icon: '🛡️',
        mascotMessage: 'Keep your largest holding under 30%!',
      ),
    ];
  }

  /// Fallback quests if AI generation fails
  static List<Challenge> _getFallbackQuests(int userLevel, int totalTrades) {
    return [
      Challenge(
        id: 'fallback_trade_more',
        title: 'Active Trader',
        description: 'Make 3 trades this week to stay active',
        type: ChallengeType.daily,
        status: ChallengeStatus.available,
        xpReward: 200,
        coinReward: 0,
        requirements: {'trades': 3},
        progress: {'trades': 0},
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        icon: '📈',
        mascotMessage: 'Stay active with 3 trades this week!',
      ),
      Challenge(
        id: 'fallback_learn',
        title: 'Learning Journey',
        description: 'Read 2 educational articles to expand your knowledge',
        type: ChallengeType.daily,
        status: ChallengeStatus.available,
        xpReward: 150,
        coinReward: 0,
        requirements: {'articles': 2},
        progress: {'articles': 0},
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        icon: '📚',
        mascotMessage: 'Keep learning with educational articles!',
      ),
    ];
  }

  /// Helper method to get quest icon based on category
  static String _getQuestIcon(String category) {
    switch (category.toLowerCase()) {
      case 'diversification':
        return '🌐';
      case 'risk management':
        return '🛡️';
      case 'learning':
        return '📚';
      case 'trading':
        return '📈';
      default:
        return '🎯';
    }
  }
}
