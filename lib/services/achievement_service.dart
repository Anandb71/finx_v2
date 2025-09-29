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

  /// Check for new achievements based on portfolio state
  Future<void> checkForAchievements(EnhancedPortfolioProvider portfolio) async {
    final List<String> newlyUnlocked = [];

    // Check first trade achievement
    if (!isAchievementUnlocked('first_trade') &&
        portfolio.transactions.isNotEmpty) {
      newlyUnlocked.add('first_trade');
    }

    // Check portfolio value achievement
    if (!isAchievementUnlocked('portfolio_master') &&
        portfolio.totalValue >= 100000) {
      newlyUnlocked.add('portfolio_master');
    }

    // Check diversified investor achievement
    if (!isAchievementUnlocked('diversified_investor') &&
        portfolio.holdings.length >= 5) {
      newlyUnlocked.add('diversified_investor');
    }

    // Check profit maker achievement
    if (!isAchievementUnlocked('profit_maker')) {
      for (final transaction in portfolio.transactions) {
        if (transaction.type == TransactionType.sell) {
          final avgPrice = portfolio.getAveragePurchasePrice(
            transaction.symbol,
          );
          final profit = (transaction.price - avgPrice) * transaction.quantity;
          if (profit >= 1000) {
            newlyUnlocked.add('profit_maker');
            break;
          }
        }
      }
    }

    // Unlock new achievements
    for (final achievementId in newlyUnlocked) {
      final achievement = _allAchievements.firstWhere(
        (a) => a.id == achievementId,
      );
      _unlockedAchievements.add(achievement);

      // Save to Firestore
      try {
        await _firestore.collection('achievements').doc(achievementId).set({
          'id': achievement.id,
          'title': achievement.title,
          'description': achievement.description,
          'icon': achievement.icon,
          'points': achievement.points,
          'category': achievement.category,
          'unlockedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Error saving achievement: $e');
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      notifyListeners();
    }
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
