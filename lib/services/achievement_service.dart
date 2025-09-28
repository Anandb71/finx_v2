// lib/services/achievement_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'enhanced_portfolio_provider.dart';

class AchievementService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Achievement> _unlockedAchievements = [];
  final List<Achievement> _allAchievements = [];

  List<Achievement> get unlockedAchievements =>
      List.unmodifiable(_unlockedAchievements);
  List<Achievement> get allAchievements => List.unmodifiable(_allAchievements);

  AchievementService() {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    _allAchievements.addAll([
      Achievement(
        id: 'first_trade',
        title: 'First Steps',
        description: 'Complete your first trade',
        icon: '🎯',
        points: 10,
        category: 'Trading',
      ),
      Achievement(
        id: 'portfolio_master',
        title: 'Portfolio Master',
        description: 'Reach \$100,000 portfolio value',
        icon: '💎',
        points: 50,
        category: 'Wealth',
      ),
      Achievement(
        id: 'diversified_investor',
        title: 'Diversified Investor',
        description: 'Hold 5 different stocks',
        icon: '🌐',
        points: 25,
        category: 'Strategy',
      ),
      Achievement(
        id: 'profit_maker',
        title: 'Profit Maker',
        description: 'Make \$1,000 profit in a single trade',
        icon: '💰',
        points: 30,
        category: 'Trading',
      ),
      Achievement(
        id: 'consistent_trader',
        title: 'Consistent Trader',
        description: 'Complete 10 trades',
        icon: '📈',
        points: 20,
        category: 'Trading',
      ),
      Achievement(
        id: 'risk_taker',
        title: 'Risk Taker',
        description: 'Invest more than 50% of your cash',
        icon: '⚡',
        points: 15,
        category: 'Strategy',
      ),
      Achievement(
        id: 'patient_investor',
        title: 'Patient Investor',
        description: 'Hold a stock for 7 days',
        icon: '⏰',
        points: 20,
        category: 'Strategy',
      ),
      Achievement(
        id: 'market_analyst',
        title: 'Market Analyst',
        description: 'Use chart analysis 5 times',
        icon: '📊',
        points: 25,
        category: 'Learning',
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Score 100% on any quiz',
        icon: '🧠',
        points: 15,
        category: 'Learning',
      ),
      Achievement(
        id: 'simulation_expert',
        title: 'Simulation Expert',
        description: 'Use portfolio simulator 3 times',
        icon: '🔮',
        points: 20,
        category: 'Learning',
      ),
    ]);
  }

  Future<void> checkForAchievements(EnhancedPortfolioProvider portfolio) async {
    final userId = 'current_user'; // In a real app, get from auth

    // Check each achievement
    for (final achievement in _allAchievements) {
      if (!_unlockedAchievements.any((a) => a.id == achievement.id)) {
        bool shouldUnlock = false;

        switch (achievement.id) {
          case 'first_trade':
            shouldUnlock = portfolio.transactionHistory.isNotEmpty;
            break;
          case 'portfolio_master':
            shouldUnlock = portfolio.totalValue >= 100000;
            break;
          case 'diversified_investor':
            shouldUnlock = portfolio.holdings.length >= 5;
            break;
          case 'profit_maker':
            shouldUnlock = portfolio.transactionHistory.any(
              (t) => t.type == TransactionType.sell && t.totalValue > 1000,
            );
            break;
          case 'consistent_trader':
            shouldUnlock = portfolio.transactionHistory.length >= 10;
            break;
          case 'risk_taker':
            final investedAmount = portfolio.totalValue - portfolio.virtualCash;
            shouldUnlock = investedAmount > (portfolio.virtualCash * 0.5);
            break;
          case 'patient_investor':
            // This would need more complex logic to track holding duration
            shouldUnlock = false; // Placeholder
            break;
          case 'market_analyst':
            // This would need to track chart analysis usage
            shouldUnlock = false; // Placeholder
            break;
          case 'quiz_master':
            // This would need to track quiz scores
            shouldUnlock = false; // Placeholder
            break;
          case 'simulation_expert':
            // This would need to track simulator usage
            shouldUnlock = false; // Placeholder
            break;
        }

        if (shouldUnlock) {
          await unlockAchievement(achievement, userId);
        }
      }
    }
  }

  Future<void> unlockAchievement(Achievement achievement, String userId) async {
    if (_unlockedAchievements.any((a) => a.id == achievement.id)) {
      return; // Already unlocked
    }

    _unlockedAchievements.add(achievement);
    notifyListeners();

    // Save to Firebase
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .set({
            'id': achievement.id,
            'title': achievement.title,
            'description': achievement.description,
            'icon': achievement.icon,
            'points': achievement.points,
            'category': achievement.category,
            'unlockedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving achievement to Firebase: $e');
    }

    print('🎉 Unlocked achievement: ${achievement.title}');
  }

  Future<void> loadUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      _unlockedAchievements.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final achievement = Achievement(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          icon: data['icon'],
          points: data['points'],
          category: data['category'],
        );
        _unlockedAchievements.add(achievement);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  bool isAchievementUnlocked(String id) {
    return _unlockedAchievements.any((a) => a.id == id);
  }

  int get totalPoints {
    return _unlockedAchievements.fold(
      0,
      (sum, achievement) => sum + achievement.points,
    );
  }

  List<Achievement> getAchievementsByCategory(String category) {
    return _allAchievements.where((a) => a.category == category).toList();
  }

  List<Achievement> getUnlockedAchievementsByCategory(String category) {
    return _unlockedAchievements.where((a) => a.category == category).toList();
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
  });
}
