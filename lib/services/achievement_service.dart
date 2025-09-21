import 'dart:math';
import '../models/achievement.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  // Predefined achievements
  static final List<Achievement> _allAchievements = [
    // Trading Achievements
    Achievement(
      id: 'first_trade',
      title: 'First Steps',
      description: 'Complete your first trade',
      icon: '🎯',
      type: AchievementType.trading,
      rarity: AchievementRarity.common,
      xpReward: 250,
      requirements: ['Complete 1 trade'],
      mascotMessage:
          'Great job on your first trade! 🎉 You\'re officially a trader now!',
    ),
    Achievement(
      id: 'daily_trader',
      title: 'Daily Trader',
      description: 'Make 3 trades in a single day',
      icon: '📈',
      type: AchievementType.trading,
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
      requirements: ['Make 3 trades in one day'],
      mascotMessage: 'Wow! You\'re really getting into the trading groove! 📊',
    ),
    Achievement(
      id: 'portfolio_milestone_150k',
      title: 'Rising Star',
      description: 'Grow your portfolio to \$150,000',
      icon: '⭐',
      type: AchievementType.milestone,
      rarity: AchievementRarity.rare,
      xpReward: 500,
      requirements: ['Reach \$150,000 portfolio value'],
      mascotMessage: 'Incredible! Your portfolio is growing like a rocket! 🚀',
    ),
    Achievement(
      id: 'portfolio_milestone_200k',
      title: 'Market Master',
      description: 'Grow your portfolio to \$200,000',
      icon: '👑',
      type: AchievementType.milestone,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      requirements: ['Reach \$200,000 portfolio value'],
      mascotMessage: 'You\'re a true market master! The crown is yours! 👑',
    ),
    Achievement(
      id: 'diversification_master',
      title: 'Diversification Master',
      description: 'Own stocks from 3+ different sectors',
      icon: '🌐',
      type: AchievementType.trading,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      requirements: ['Own stocks from 3+ sectors'],
      mascotMessage:
          'Smart investing! Diversification is the key to success! 🌟',
    ),
    Achievement(
      id: 'long_term_holder',
      title: 'Patient Investor',
      description: 'Hold a stock for 7+ days',
      icon: '⏰',
      type: AchievementType.trading,
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
      requirements: ['Hold any stock for 7+ days'],
      mascotMessage:
          'Patience pays off! You\'re thinking like a pro investor! 💎',
    ),
    Achievement(
      id: 'risk_manager',
      title: 'Risk Manager',
      description: 'Sell a losing position (stop-loss)',
      icon: '🛡️',
      type: AchievementType.trading,
      rarity: AchievementRarity.uncommon,
      xpReward: 100,
      requirements: ['Sell a losing position'],
      mascotMessage:
          'Smart risk management! Protecting your capital is crucial! 🛡️',
    ),
    Achievement(
      id: 'win_streak_5',
      title: 'Hot Streak',
      description: 'Make 5 profitable trades in a row',
      icon: '🔥',
      type: AchievementType.trading,
      rarity: AchievementRarity.rare,
      xpReward: 400,
      requirements: ['5 consecutive profitable trades'],
      mascotMessage: 'You\'re on fire! 🔥 This streak is incredible!',
    ),

    // Learning Achievements
    Achievement(
      id: 'first_ai_chat',
      title: 'Curious Learner',
      description: 'Have your first conversation with AI Mentor',
      icon: '🤖',
      type: AchievementType.learning,
      rarity: AchievementRarity.common,
      xpReward: 50,
      requirements: ['Chat with AI Mentor once'],
      mascotMessage:
          'Great question! Learning is the first step to success! 🎓',
    ),
    Achievement(
      id: 'knowledge_seeker',
      title: 'Knowledge Seeker',
      description: 'Read 5 educational articles',
      icon: '📚',
      type: AchievementType.learning,
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
      requirements: ['Read 5 articles'],
      mascotMessage: 'Knowledge is power! You\'re becoming a true expert! 📖',
    ),
    Achievement(
      id: 'quiz_master',
      title: 'Quiz Master',
      description: 'Score 100% on 3 quizzes',
      icon: '🧠',
      type: AchievementType.learning,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      requirements: ['Perfect score on 3 quizzes'],
      mascotMessage: 'Perfect scores! Your understanding is outstanding! 🎯',
    ),

    // Social Achievements
    Achievement(
      id: 'helpful_mentor',
      title: 'Helpful Mentor',
      description: 'Help 5 other users in the community',
      icon: '🤝',
      type: AchievementType.social,
      rarity: AchievementRarity.rare,
      xpReward: 400,
      requirements: ['Help 5 community members'],
      mascotMessage: 'You\'re making the community better for everyone! 🌟',
    ),
    Achievement(
      id: 'achievement_collector',
      title: 'Achievement Collector',
      description: 'Unlock 10 achievements',
      icon: '🏆',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      requirements: ['Unlock 10 achievements'],
      mascotMessage: 'You\'re a true achievement hunter! 🏆 Keep it up!',
    ),

    // Special Achievements
    Achievement(
      id: 'comeback_king',
      title: 'Comeback King',
      description: 'Recover from a 20% portfolio loss',
      icon: '💪',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      xpReward: 1000,
      requirements: ['Recover from 20% loss'],
      mascotMessage: 'What a comeback! You\'ve got the heart of a champion! 💪',
    ),
    Achievement(
      id: 'market_prophet',
      title: 'Market Prophet',
      description: 'Correctly predict market direction 5 times',
      icon: '🔮',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      xpReward: 800,
      requirements: ['5 correct market predictions'],
      mascotMessage: 'You\'re reading the market like a crystal ball! 🔮',
    ),
  ];

  // User's unlocked achievements (in real app, this would be stored in database)
  final Map<String, Achievement> _unlockedAchievements = {};

  // Get all available achievements
  List<Achievement> getAllAchievements() => List.unmodifiable(_allAchievements);

  // Get user's unlocked achievements
  List<Achievement> getUnlockedAchievements() =>
      List.unmodifiable(_unlockedAchievements.values);

  // Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _allAchievements
        .where((achievement) => achievement.type == type)
        .toList();
  }

  // Get achievements by rarity
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return _allAchievements
        .where((achievement) => achievement.rarity == rarity)
        .toList();
  }

  // Check if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements.containsKey(achievementId);
  }

  // Unlock an achievement
  Achievement? unlockAchievement(String achievementId) {
    final achievement = _allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    if (!_unlockedAchievements.containsKey(achievementId)) {
      final unlockedAchievement = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _unlockedAchievements[achievementId] = unlockedAchievement;
      return unlockedAchievement;
    }
    return null; // Already unlocked
  }

  // Check and unlock achievements based on user actions
  List<Achievement> checkAndUnlockAchievements({
    required int totalTrades,
    required double portfolioValue,
    required int daysSinceFirstTrade,
    required int aiChatCount,
    required int articlesRead,
    required int quizzesCompleted,
    required int perfectQuizzes,
    required int communityHelps,
    required int consecutiveWins,
    required bool hasSoldLosingPosition,
    required int sectorsInvested,
    required int correctPredictions,
    required double maxPortfolioLoss,
  }) {
    List<Achievement> newlyUnlocked = [];

    // First trade
    if (totalTrades >= 1 && !isAchievementUnlocked('first_trade')) {
      newlyUnlocked.add(unlockAchievement('first_trade')!);
    }

    // Daily trader
    if (totalTrades >= 3 && !isAchievementUnlocked('daily_trader')) {
      newlyUnlocked.add(unlockAchievement('daily_trader')!);
    }

    // Portfolio milestones
    if (portfolioValue >= 150000 &&
        !isAchievementUnlocked('portfolio_milestone_150k')) {
      newlyUnlocked.add(unlockAchievement('portfolio_milestone_150k')!);
    }
    if (portfolioValue >= 200000 &&
        !isAchievementUnlocked('portfolio_milestone_200k')) {
      newlyUnlocked.add(unlockAchievement('portfolio_milestone_200k')!);
    }

    // Diversification
    if (sectorsInvested >= 3 &&
        !isAchievementUnlocked('diversification_master')) {
      newlyUnlocked.add(unlockAchievement('diversification_master')!);
    }

    // Long-term holding
    if (daysSinceFirstTrade >= 7 &&
        !isAchievementUnlocked('long_term_holder')) {
      newlyUnlocked.add(unlockAchievement('long_term_holder')!);
    }

    // Risk management
    if (hasSoldLosingPosition && !isAchievementUnlocked('risk_manager')) {
      newlyUnlocked.add(unlockAchievement('risk_manager')!);
    }

    // Win streak
    if (consecutiveWins >= 5 && !isAchievementUnlocked('win_streak_5')) {
      newlyUnlocked.add(unlockAchievement('win_streak_5')!);
    }

    // Learning achievements
    if (aiChatCount >= 1 && !isAchievementUnlocked('first_ai_chat')) {
      newlyUnlocked.add(unlockAchievement('first_ai_chat')!);
    }
    if (articlesRead >= 5 && !isAchievementUnlocked('knowledge_seeker')) {
      newlyUnlocked.add(unlockAchievement('knowledge_seeker')!);
    }
    if (perfectQuizzes >= 3 && !isAchievementUnlocked('quiz_master')) {
      newlyUnlocked.add(unlockAchievement('quiz_master')!);
    }

    // Social achievements
    if (communityHelps >= 5 && !isAchievementUnlocked('helpful_mentor')) {
      newlyUnlocked.add(unlockAchievement('helpful_mentor')!);
    }

    // Special achievements
    if (correctPredictions >= 5 && !isAchievementUnlocked('market_prophet')) {
      newlyUnlocked.add(unlockAchievement('market_prophet')!);
    }
    if (maxPortfolioLoss <= -0.20 && !isAchievementUnlocked('comeback_king')) {
      newlyUnlocked.add(unlockAchievement('comeback_king')!);
    }

    // Achievement collector (check after all others)
    if (_unlockedAchievements.length >= 10 &&
        !isAchievementUnlocked('achievement_collector')) {
      newlyUnlocked.add(unlockAchievement('achievement_collector')!);
    }

    return newlyUnlocked;
  }

  // Get XP reward for specific actions
  int getXpForAction(String action) {
    switch (action) {
      case 'first_trade':
        return 250;
      case 'daily_trade':
        return 50;
      case 'portfolio_growth_5_percent':
        return 100;
      case 'diversification':
        return 200;
      case 'long_term_holding':
        return 150;
      case 'risk_management':
        return 100;
      case 'ai_chat':
        return 10;
      case 'read_article':
        return 25;
      case 'watch_video':
        return 50;
      case 'complete_quiz':
        return 100;
      case 'perfect_quiz':
        return 150;
      case 'help_community':
        return 50;
      case 'share_achievement':
        return 25;
      default:
        return 0;
    }
  }

  // Get random mascot encouragement message
  String getRandomEncouragement() {
    final messages = [
      'You\'re doing amazing! Keep up the great work! 🌟',
      'Every trade is a learning opportunity! 📚',
      'Your dedication to learning is inspiring! 🎓',
      'Great job on staying consistent! 💪',
      'You\'re becoming a trading expert! 🚀',
      'Keep exploring and learning! 🔍',
      'Your progress is impressive! 📈',
      'Don\'t stop now, you\'re on fire! 🔥',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // Reset achievements (for testing)
  void resetAchievements() {
    _unlockedAchievements.clear();
  }
}
