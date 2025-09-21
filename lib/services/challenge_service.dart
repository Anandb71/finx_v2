import 'dart:math';
import '../models/challenge.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  // Active challenges
  final Map<String, Challenge> _activeChallenges = {};

  // Challenge templates for generating new challenges
  final List<Map<String, dynamic>> _dailyChallengeTemplates = [
    {
      'title': 'Daily Trader',
      'description': 'Make 3 trades today',
      'icon': '📈',
      'requirements': {'trades': 3},
      'xpReward': 200,
      'coinReward': 50,
      'mascotMessage': 'Ready to make some moves today? Let\'s trade! 📊',
    },
    {
      'title': 'Portfolio Growth',
      'description': 'Grow your portfolio by 2% today',
      'icon': '📊',
      'requirements': {'portfolio_growth': 2.0},
      'xpReward': 300,
      'coinReward': 75,
      'mascotMessage': 'Time to watch your portfolio grow! 🌱',
    },
    {
      'title': 'Diversification Master',
      'description': 'Invest in 2 different sectors today',
      'icon': '🌐',
      'requirements': {'sectors': 2},
      'xpReward': 250,
      'coinReward': 60,
      'mascotMessage': 'Spread your investments wisely! 🎯',
    },
    {
      'title': 'Learning Seeker',
      'description': 'Read 2 articles or chat with AI Mentor',
      'icon': '📚',
      'requirements': {'learning_actions': 2},
      'xpReward': 150,
      'coinReward': 40,
      'mascotMessage': 'Knowledge is power! Keep learning! 🎓',
    },
    {
      'title': 'Risk Manager',
      'description': 'Sell a losing position today',
      'icon': '🛡️',
      'requirements': {'risk_management': 1},
      'xpReward': 200,
      'coinReward': 50,
      'mascotMessage': 'Smart risk management! Protect your capital! 💪',
    },
  ];

  final List<Map<String, dynamic>> _weeklyChallengeTemplates = [
    {
      'title': 'Trading Marathon',
      'description': 'Make 15 trades this week',
      'icon': '🏃',
      'requirements': {'trades': 15},
      'xpReward': 1000,
      'coinReward': 250,
      'mascotMessage': 'You\'re a trading machine! Keep it up! 🚀',
    },
    {
      'title': 'Portfolio Master',
      'description': 'Grow your portfolio by 10% this week',
      'icon': '👑',
      'requirements': {'portfolio_growth': 10.0},
      'xpReward': 1500,
      'coinReward': 350,
      'mascotMessage': 'Incredible growth! You\'re mastering the market! 🌟',
    },
    {
      'title': 'Knowledge Hunter',
      'description': 'Complete 10 learning activities this week',
      'icon': '🔍',
      'requirements': {'learning_actions': 10},
      'xpReward': 800,
      'coinReward': 200,
      'mascotMessage': 'Your thirst for knowledge is inspiring! 📖',
    },
    {
      'title': 'Community Helper',
      'description': 'Help 5 other users this week',
      'icon': '🤝',
      'requirements': {'community_helps': 5},
      'xpReward': 1200,
      'coinReward': 300,
      'mascotMessage': 'You\'re making the community better for everyone! 🌟',
    },
    {
      'title': 'Achievement Collector',
      'description': 'Unlock 5 achievements this week',
      'icon': '🏆',
      'requirements': {'achievements': 5},
      'xpReward': 1000,
      'coinReward': 250,
      'mascotMessage': 'You\'re collecting achievements like a pro! 🎯',
    },
  ];

  // Get all active challenges
  List<Challenge> getActiveChallenges() {
    return _activeChallenges.values.toList();
  }

  // Get challenges by type
  List<Challenge> getChallengesByType(ChallengeType type) {
    return _activeChallenges.values
        .where((challenge) => challenge.type == type)
        .toList();
  }

  // Generate daily challenges
  List<Challenge> generateDailyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Clear expired daily challenges
    _activeChallenges.removeWhere(
      (key, challenge) =>
          challenge.type == ChallengeType.daily && challenge.isExpired,
    );

    // Generate 2-3 random daily challenges
    final random = Random();
    final numChallenges = 2 + random.nextInt(2); // 2-3 challenges
    final selectedTemplates = _dailyChallengeTemplates.toList()
      ..shuffle(random);

    for (int i = 0; i < numChallenges && i < selectedTemplates.length; i++) {
      final template = selectedTemplates[i];
      final challengeId = 'daily_${today.millisecondsSinceEpoch}_$i';

      final challenge = Challenge(
        id: challengeId,
        title: template['title'],
        description: template['description'],
        type: ChallengeType.daily,
        status: ChallengeStatus.available,
        xpReward: template['xpReward'],
        coinReward: template['coinReward'],
        requirements: Map<String, dynamic>.from(template['requirements']),
        progress: {},
        startDate: today,
        endDate: tomorrow,
        icon: template['icon'],
        mascotMessage: template['mascotMessage'],
      );

      _activeChallenges[challengeId] = challenge;
    }

    return getChallengesByType(ChallengeType.daily);
  }

  // Generate weekly challenges
  List<Challenge> generateWeeklyChallenges() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    // Clear expired weekly challenges
    _activeChallenges.removeWhere(
      (key, challenge) =>
          challenge.type == ChallengeType.weekly && challenge.isExpired,
    );

    // Generate 1-2 random weekly challenges
    final random = Random();
    final numChallenges = 1 + random.nextInt(2); // 1-2 challenges
    final selectedTemplates = _weeklyChallengeTemplates.toList()
      ..shuffle(random);

    for (int i = 0; i < numChallenges && i < selectedTemplates.length; i++) {
      final template = selectedTemplates[i];
      final challengeId = 'weekly_${startOfWeekDay.millisecondsSinceEpoch}_$i';

      final challenge = Challenge(
        id: challengeId,
        title: template['title'],
        description: template['description'],
        type: ChallengeType.weekly,
        status: ChallengeStatus.available,
        xpReward: template['xpReward'],
        coinReward: template['coinReward'],
        requirements: Map<String, dynamic>.from(template['requirements']),
        progress: {},
        startDate: startOfWeekDay,
        endDate: endOfWeek,
        icon: template['icon'],
        mascotMessage: template['mascotMessage'],
      );

      _activeChallenges[challengeId] = challenge;
    }

    return getChallengesByType(ChallengeType.weekly);
  }

  // Update challenge progress
  void updateChallengeProgress(
    String challengeId,
    Map<String, dynamic> progressUpdate,
  ) {
    final challenge = _activeChallenges[challengeId];
    if (challenge == null) return;

    final newProgress = Map<String, dynamic>.from(challenge.progress);
    progressUpdate.forEach((key, value) {
      final currentValue = newProgress[key] ?? 0;
      final updateValue = value as num;
      newProgress[key] = (currentValue as num) + updateValue;
    });

    final updatedChallenge = challenge.copyWith(progress: newProgress);
    _activeChallenges[challengeId] = updatedChallenge;
  }

  // Complete a challenge
  Challenge? completeChallenge(String challengeId) {
    final challenge = _activeChallenges[challengeId];
    if (challenge == null || !challenge.isCompleted) return null;

    final completedChallenge = challenge.copyWith(
      status: ChallengeStatus.completed,
    );
    _activeChallenges[challengeId] = completedChallenge;
    return completedChallenge;
  }

  // Get challenge by ID
  Challenge? getChallenge(String challengeId) {
    return _activeChallenges[challengeId];
  }

  // Check if user has completed all daily challenges
  bool hasCompletedAllDailyChallenges() {
    final dailyChallenges = getChallengesByType(ChallengeType.daily);
    if (dailyChallenges.isEmpty) return false;

    return dailyChallenges.every((challenge) => challenge.isCompleted);
  }

  // Check if user has completed all weekly challenges
  bool hasCompletedAllWeeklyChallenges() {
    final weeklyChallenges = getChallengesByType(ChallengeType.weekly);
    if (weeklyChallenges.isEmpty) return false;

    return weeklyChallenges.every((challenge) => challenge.isCompleted);
  }

  // Get total XP reward for completed challenges
  int getTotalXpReward() {
    return _activeChallenges.values
        .where((challenge) => challenge.status == ChallengeStatus.completed)
        .fold(0, (total, challenge) => total + challenge.xpReward);
  }

  // Get total coin reward for completed challenges
  int getTotalCoinReward() {
    return _activeChallenges.values
        .where((challenge) => challenge.status == ChallengeStatus.completed)
        .fold(0, (total, challenge) => total + challenge.coinReward);
  }

  // Clear completed challenges
  void clearCompletedChallenges() {
    _activeChallenges.removeWhere(
      (key, challenge) => challenge.status == ChallengeStatus.completed,
    );
  }

  // Reset all challenges (for testing)
  void resetChallenges() {
    _activeChallenges.clear();
  }

  // Get random encouragement for challenges
  String getRandomChallengeEncouragement() {
    final messages = [
      'You\'re crushing these challenges! 🔥',
      'Keep up the amazing work! 💪',
      'You\'re on fire today! 🚀',
      'Every challenge makes you stronger! ⚡',
      'You\'re becoming a trading legend! 👑',
      'Don\'t stop now, you\'re unstoppable! 🌟',
      'Your dedication is inspiring! 🎯',
      'You\'re mastering the art of investing! 📈',
    ];
    return messages[Random().nextInt(messages.length)];
  }
}
