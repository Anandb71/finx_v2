// lib/services/quest_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'enhanced_portfolio_provider.dart';

class QuestService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Quest> _activeQuests = [];
  final List<Quest> _completedQuests = [];
  final List<Quest> _allQuests = [];

  List<Quest> get activeQuests => List.unmodifiable(_activeQuests);
  List<Quest> get completedQuests => List.unmodifiable(_completedQuests);
  List<Quest> get allQuests => List.unmodifiable(_allQuests);

  QuestService() {
    _initializeQuests();
  }

  void _initializeQuests() {
    _allQuests.addAll([
      Quest(
        id: 'first_trade_quest',
        title: 'Make Your First Trade',
        description: 'Buy or sell your first stock to get started',
        icon: '🎯',
        points: 20,
        category: 'Trading',
        difficulty: 'Easy',
        requirements: {'trades': 1},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'diversify_portfolio',
        title: 'Diversify Your Portfolio',
        description: 'Hold at least 3 different stocks',
        icon: '🌐',
        points: 30,
        category: 'Strategy',
        difficulty: 'Medium',
        requirements: {'holdings': 3},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'profit_quest',
        title: 'Make a Profit',
        description: 'Earn \$500 profit from trading',
        icon: '💰',
        points: 40,
        category: 'Trading',
        difficulty: 'Medium',
        requirements: {'profit': 500},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'learning_quest',
        title: 'Complete Your First Quiz',
        description: 'Take and complete any quiz in the Quiz Center',
        icon: '🧠',
        points: 15,
        category: 'Learning',
        difficulty: 'Easy',
        requirements: {'quizzes_completed': 1},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'analysis_quest',
        title: 'Analyze the Market',
        description: 'Use the Chart Analysis tool 3 times',
        icon: '📊',
        points: 25,
        category: 'Learning',
        difficulty: 'Medium',
        requirements: {'chart_analysis': 3},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'simulation_quest',
        title: 'Plan Your Future',
        description: 'Use the Portfolio Simulator to plan your investments',
        icon: '🔮',
        points: 20,
        category: 'Learning',
        difficulty: 'Easy',
        requirements: {'simulations': 1},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'consistent_trader_quest',
        title: 'Become a Consistent Trader',
        description: 'Complete 5 trades in total',
        icon: '📈',
        points: 35,
        category: 'Trading',
        difficulty: 'Medium',
        requirements: {'trades': 5},
        progress: 0,
        isCompleted: false,
      ),
      Quest(
        id: 'wealth_builder_quest',
        title: 'Build Your Wealth',
        description: 'Grow your portfolio to \$50,000',
        icon: '💎',
        points: 50,
        category: 'Wealth',
        difficulty: 'Hard',
        requirements: {'portfolio_value': 50000},
        progress: 0,
        isCompleted: false,
      ),
    ]);
  }

  Future<void> _checkForNewQuests(EnhancedPortfolioProvider portfolio) async {
    // Auto-start certain quests based on portfolio state
    final availableQuests = _allQuests
        .where(
          (quest) =>
              !_activeQuests.any((a) => a.id == quest.id) &&
              !_completedQuests.any((c) => c.id == quest.id),
        )
        .toList();

    for (final quest in availableQuests) {
      bool shouldStart = false;

      switch (quest.id) {
        case 'first_trade_quest':
          shouldStart = portfolio.transactionHistory.isEmpty;
          break;
        case 'diversify_portfolio':
          shouldStart =
              portfolio.holdings.length >= 1 && portfolio.holdings.length < 3;
          break;
        case 'profit_quest':
          shouldStart = portfolio.transactionHistory.isNotEmpty;
          break;
        case 'learning_quest':
          shouldStart = true; // Always available
          break;
        case 'analysis_quest':
          shouldStart = true; // Always available
          break;
        case 'simulation_quest':
          shouldStart = true; // Always available
          break;
        case 'consistent_trader_quest':
          shouldStart = portfolio.transactionHistory.length >= 1;
          break;
        case 'wealth_builder_quest':
          shouldStart = portfolio.totalValue >= 10000;
          break;
      }

      if (shouldStart) {
        await _startQuest(quest);
      }
    }
  }

  Future<void> _startQuest(Quest quest) async {
    _activeQuests.add(quest);
    notifyListeners();

    // Save to Firebase
    try {
      final userId = 'current_user';
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(quest.id)
          .set({
            'id': quest.id,
            'title': quest.title,
            'description': quest.description,
            'icon': quest.icon,
            'points': quest.points,
            'category': quest.category,
            'difficulty': quest.difficulty,
            'requirements': quest.requirements,
            'progress': quest.progress,
            'isCompleted': quest.isCompleted,
            'startedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving quest to Firebase: $e');
    }
  }

  Future<void> _completeQuest(Quest quest) async {
    _activeQuests.remove(quest);
    _completedQuests.add(quest);
    notifyListeners();

    // Save to Firebase
    try {
      final userId = 'current_user';
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_quests')
          .doc(quest.id)
          .set({
            'id': quest.id,
            'title': quest.title,
            'description': quest.description,
            'icon': quest.icon,
            'points': quest.points,
            'category': quest.category,
            'difficulty': quest.difficulty,
            'completedAt': FieldValue.serverTimestamp(),
          });

      // Remove from active quests
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(quest.id)
          .delete();
    } catch (e) {
      print('Error completing quest in Firebase: $e');
    }

    print('🎉 Quest completed: ${quest.title}');
  }

  Future<void> loadUserQuests(String userId) async {
    try {
      // Load active quests
      final activeSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .get();

      _activeQuests.clear();
      for (final doc in activeSnapshot.docs) {
        final data = doc.data();
        final quest = Quest(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          icon: data['icon'],
          points: data['points'],
          category: data['category'],
          difficulty: data['difficulty'],
          requirements: Map<String, int>.from(data['requirements']),
          progress: data['progress'],
          isCompleted: data['isCompleted'],
        );
        _activeQuests.add(quest);
      }

      // Load completed quests
      final completedSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_quests')
          .get();

      _completedQuests.clear();
      for (final doc in completedSnapshot.docs) {
        final data = doc.data();
        final quest = Quest(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          icon: data['icon'],
          points: data['points'],
          category: data['category'],
          difficulty: data['difficulty'],
          requirements: Map<String, int>.from(data['requirements']),
          progress: data['progress'] ?? 0,
          isCompleted: true,
        );
        _completedQuests.add(quest);
      }

      notifyListeners();
    } catch (e) {
      print('Error loading quests: $e');
    }
  }

  int get totalPoints {
    return _completedQuests.fold(0, (sum, quest) => sum + quest.points);
  }

  List<Quest> getQuestsByCategory(String category) {
    return _allQuests.where((q) => q.category == category).toList();
  }

  List<Quest> getActiveQuestsByCategory(String category) {
    return _activeQuests.where((q) => q.category == category).toList();
  }

  /// Check quest progress based on portfolio state
  Future<void> checkQuests(EnhancedPortfolioProvider portfolio) async {
    final List<Quest> newlyCompleted = [];

    for (final quest in _activeQuests) {
      if (quest.isCompleted) continue;

      bool isCompleted = false;
      int newProgress = 0;

      switch (quest.id) {
        case 'first_trade_quest':
          newProgress = portfolio.transactions.length;
          isCompleted = newProgress >= quest.requirements['trades']!;
          break;

        case 'diversify_portfolio':
          newProgress = portfolio.holdings.length;
          isCompleted = newProgress >= quest.requirements['holdings']!;
          break;

        case 'profit_quest':
          // Calculate total profit from sell transactions
          double totalProfit = 0;
          for (final transaction in portfolio.transactions) {
            if (transaction.type == TransactionType.sell) {
              final avgPrice = portfolio.getAveragePurchasePrice(
                transaction.symbol,
              );
              final profit =
                  (transaction.price - avgPrice) * transaction.quantity;
              totalProfit += profit;
            }
          }
          newProgress = totalProfit.toInt();
          isCompleted = totalProfit >= quest.requirements['profit']!;
          break;

        case 'portfolio_value_quest':
          newProgress = portfolio.totalValue.toInt();
          isCompleted = portfolio.totalValue >= quest.requirements['value']!;
          break;
      }

      // Update quest progress
      quest.progress = newProgress;
      if (isCompleted && !quest.isCompleted) {
        quest.isCompleted = true;
        newlyCompleted.add(quest);
        _completedQuests.add(quest);
        _activeQuests.remove(quest);

        // Save to Firestore
        try {
          await _firestore.collection('quests').doc(quest.id).set({
            'id': quest.id,
            'title': quest.title,
            'description': quest.description,
            'icon': quest.icon,
            'points': quest.points,
            'category': quest.category,
            'difficulty': quest.difficulty,
            'requirements': quest.requirements,
            'progress': quest.progress,
            'isCompleted': quest.isCompleted,
            'completedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Error saving quest: $e');
        }
      }
    }

    if (newlyCompleted.isNotEmpty) {
      notifyListeners();
    }
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final String category;
  final String difficulty;
  final Map<String, int> requirements;
  int progress;
  bool isCompleted;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    required this.difficulty,
    required this.requirements,
    required this.progress,
    required this.isCompleted,
  });

  double get progressPercentage {
    if (requirements.isEmpty) return 0.0;

    final totalRequired = requirements.values.reduce((a, b) => a + b);
    return (progress / totalRequired).clamp(0.0, 1.0);
  }
}
