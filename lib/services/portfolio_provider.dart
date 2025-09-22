import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import '../models/achievement.dart';
import '../models/challenge.dart';
import '../services/achievement_service.dart';
import '../services/challenge_service.dart';
import '../services/real_time_data_service.dart';

class PortfolioProvider extends ChangeNotifier {
  // Starting virtual cash
  double _virtualCash = 100000.00;

  // Portfolio holdings: {symbol: quantity}
  Map<String, int> _portfolio = {};

  // Player progression system
  int _userLevel = 1;
  int _userXp = 0;
  int _xpForNextLevel = 1000;

  // Achievement and XP tracking
  final AchievementService _achievementService = AchievementService();
  final ChallengeService _challengeService = ChallengeService();
  List<Achievement> _recentlyUnlockedAchievements = [];
  List<Challenge> _recentlyCompletedChallenges = [];

  // User activity tracking for achievements
  int _totalTrades = 0;
  int _dailyTrades = 0;
  DateTime _lastTradeDate = DateTime.now();
  int _consecutiveWins = 0;
  // int _consecutiveLosses = 0; // Currently not used but kept for future features
  bool _hasSoldLosingPosition = false;
  double _maxPortfolioLoss = 0.0;
  DateTime _firstTradeDate = DateTime.now();

  // Learning and social tracking
  int _aiChatCount = 0;
  int _articlesRead = 0;
  int _videosWatched = 0;
  int _quizzesCompleted = 0;
  int _perfectQuizzes = 0;
  int _communityHelps = 0;
  // int _achievementsShared = 0; // Currently not used but kept for future features
  int _correctPredictions = 0;

  // Transaction history for analytics
  List<Transaction> _transactionHistory = [];

  // Portfolio value history for charts
  final List<PortfolioValuePoint> _portfolioValueHistory = [];

  // Purchase prices for each stock (for P&L calculations)
  final Map<String, double> _purchasePrices = {};

  // Real-time data service
  final RealTimeDataService _realTimeService = RealTimeDataService();

  // Current stock prices (real-time data)
  Map<String, double> _currentPrices = {
    'AAPL': 175.43,
    'GOOGL': 142.56,
    'MSFT': 378.85,
    'TSLA': 248.50,
    'AMZN': 155.12,
    'META': 485.20,
    'NVDA': 875.28,
    'NFLX': 485.33,
    'AMD': 128.45,
    'INTC': 43.21,
  };

  // Real-time update timer
  Timer? _realTimeTimer;
  bool _isRealTimeEnabled = true;

  // Getters
  double get virtualCash => _virtualCash;
  Map<String, int> get portfolio => Map.from(_portfolio);
  Map<String, int> get holdings => Map.from(_portfolio);
  Map<String, double> get currentPrices => Map.from(_currentPrices);
  List<Transaction> get transactionHistory => List.from(_transactionHistory);

  // Player progression getters
  int get userLevel => _userLevel;
  int get userXp => _userXp;
  int get xpForNextLevel => _xpForNextLevel;
  double get xpProgress => _userXp / _xpForNextLevel;

  // Achievement getters
  List<Achievement> get recentlyUnlockedAchievements =>
      List.from(_recentlyUnlockedAchievements);
  List<Achievement> get recentAchievements =>
      _achievementService.getUnlockedAchievements().take(4).toList();
  List<Achievement> get allAchievements =>
      _achievementService.getAllAchievements();
  List<Achievement> get unlockedAchievements =>
      _achievementService.getUnlockedAchievements();

  // Challenge getters
  List<Challenge> get activeChallenges =>
      _challengeService.getActiveChallenges();
  List<Challenge> get recentlyCompletedChallenges =>
      List.from(_recentlyCompletedChallenges);
  List<Challenge> get dailyChallenges =>
      _challengeService.getChallengesByType(ChallengeType.daily);
  List<Challenge> get weeklyChallenges =>
      _challengeService.getChallengesByType(ChallengeType.weekly);

  // Activity tracking getters
  int get totalTrades => _totalTrades;
  int get dailyTrades => _dailyTrades;
  int get consecutiveWins => _consecutiveWins;
  int get aiChatCount => _aiChatCount;
  int get articlesRead => _articlesRead;
  int get videosWatched => _videosWatched;
  int get quizzesCompleted => _quizzesCompleted;
  int get perfectQuizzes => _perfectQuizzes;
  int get communityHelps => _communityHelps;

  // Get total portfolio value
  double get totalPortfolioValue {
    double total = _virtualCash;
    _portfolio.forEach((symbol, quantity) {
      final price = _currentPrices[symbol] ?? 0.0;
      total += quantity * price;
    });
    return total;
  }

  double get totalValue => totalPortfolioValue;

  // Get portfolio value for a specific stock
  double getStockValue(String symbol) {
    final quantity = _portfolio[symbol] ?? 0;
    final price = _currentPrices[symbol] ?? 0.0;
    return quantity * price;
  }

  // Get quantity of a specific stock
  int getStockQuantity(String symbol) {
    return _portfolio[symbol] ?? 0;
  }

  // Get total gain/loss
  double get totalGainLoss {
    double totalInvested = 0.0;
    double currentValue = _virtualCash;

    _transactionHistory.where((t) => t.type == TransactionType.buy).forEach((
      transaction,
    ) {
      totalInvested += transaction.quantity * transaction.price;
    });

    _portfolio.forEach((symbol, quantity) {
      final price = _currentPrices[symbol] ?? 0.0;
      currentValue += quantity * price;
    });

    return currentValue - totalInvested;
  }

  // Get gain/loss percentage
  double get totalGainLossPercentage {
    final totalInvested = 100000.00; // Starting amount
    final currentValue = totalPortfolioValue;
    return ((currentValue - totalInvested) / totalInvested) * 100;
  }

  // Execute a trade
  Future<bool> executeTrade({
    required String symbol,
    required int quantity,
    required double price,
    required TransactionType type,
  }) async {
    if (quantity <= 0) return false;

    final totalCost = quantity * price;
    final currentHolding = _portfolio[symbol] ?? 0;
    final purchasePrice = _purchasePrices[symbol] ?? 0.0;

    // Validate trade
    if (type == TransactionType.buy) {
      if (_virtualCash < totalCost) {
        return false; // Not enough cash
      }
    } else if (type == TransactionType.sell) {
      if (currentHolding < quantity) {
        return false; // Not enough shares
      }
    }

    // Execute the trade
    if (type == TransactionType.buy) {
      _virtualCash -= totalCost;
      _portfolio[symbol] = currentHolding + quantity;

      // Update purchase price (weighted average)
      final currentValue = currentHolding * purchasePrice;
      final newValue = currentValue + totalCost;
      _purchasePrices[symbol] = newValue / (currentHolding + quantity);
    } else {
      _virtualCash += totalCost;
      _portfolio[symbol] = currentHolding - quantity;

      // Check if this was a losing position (for risk management achievement)
      if (purchasePrice > 0 && price < purchasePrice) {
        _hasSoldLosingPosition = true;
        _updateChallengesForRiskManagement();
      }

      // Remove from portfolio if quantity reaches 0
      if (_portfolio[symbol] == 0) {
        _portfolio.remove(symbol);
        _purchasePrices.remove(symbol);
      }
    }

    // Update trade tracking
    _totalTrades++;
    _updateDailyTradeCount();

    // Track first trade date
    if (_totalTrades == 1) {
      _firstTradeDate = DateTime.now();
    }

    // Track consecutive wins/losses
    _updateConsecutiveTrades(type, purchasePrice, price);

    // Add to transaction history
    _transactionHistory.add(
      Transaction(
        symbol: symbol,
        quantity: quantity,
        price: price,
        type: type,
        timestamp: DateTime.now(),
      ),
    );

    // Award XP for trading actions
    _awardTradingXp(type, quantity, price);

    // Update challenges
    _updateChallengesForTrade();
    _updateChallengesForPortfolioGrowth();
    _updateChallengesForDiversification();

    // Check for new achievements
    _checkAndUnlockAchievements();

    // Simulate price movement (small random change)
    _simulatePriceMovement(symbol);

    notifyListeners();
    return true;
  }

  // Simulate small price movements
  void _simulatePriceMovement(String symbol) {
    final currentPrice = _currentPrices[symbol] ?? 0.0;
    final random = math.Random();
    final changePercent = (random.nextDouble() - 0.5) * 0.02; // ±1% change
    final newPrice = currentPrice * (1 + changePercent);
    _currentPrices[symbol] = newPrice;
  }

  // Update price for a specific stock (for real-time updates)
  void updateStockPrice(String symbol, double newPrice) {
    _currentPrices[symbol] = newPrice;
    notifyListeners();
  }

  // Initialize real-time updates
  void initializeRealTimeUpdates() {
    if (!_isRealTimeEnabled) return;

    // Start real-time timer (update every 30 seconds)
    _realTimeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateAllStockPrices(),
    );

    // Initial update
    _updateAllStockPrices();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = null;
  }

  // Toggle real-time updates
  void toggleRealTimeUpdates() {
    _isRealTimeEnabled = !_isRealTimeEnabled;
    if (_isRealTimeEnabled) {
      initializeRealTimeUpdates();
    } else {
      stopRealTimeUpdates();
    }
    notifyListeners();
  }

  // Get real-time status
  bool get isRealTimeEnabled => _isRealTimeEnabled;

  // Update all stock prices from real-time service
  Future<void> _updateAllStockPrices() async {
    if (!_isRealTimeEnabled) return;

    try {
      // Get all symbols in portfolio plus some popular ones
      final symbols = <String>{
        ..._portfolio.keys,
        'AAPL',
        'GOOGL',
        'MSFT',
        'TSLA',
        'AMZN',
        'META',
        'NVDA',
        'NFLX',
        'AMD',
        'INTC',
      };

      final stockData = await _realTimeService.getMultipleStocks(
        symbols.toList(),
      );

      bool hasUpdates = false;
      for (final entry in stockData.entries) {
        final symbol = entry.key;
        final data = entry.value;

        if (data.currentPrice > 0 &&
            _currentPrices[symbol] != data.currentPrice) {
          _currentPrices[symbol] = data.currentPrice;
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        print('🔄 Real-time update: Portfolio prices updated');
        // Update portfolio value history
        updatePortfolioValueHistory();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating real-time prices: $e');
    }
  }

  // Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 10}) {
    final sorted = List<Transaction>.from(_transactionHistory);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  // Get portfolio performance summary
  Map<String, dynamic> getPortfolioSummary() {
    return {
      'totalValue': totalPortfolioValue,
      'virtualCash': _virtualCash,
      'totalGainLoss': totalGainLoss,
      'totalGainLossPercentage': totalGainLossPercentage,
      'totalStocks': _portfolio.length,
      'totalTransactions': _transactionHistory.length,
    };
  }

  // Get portfolio value history
  List<PortfolioValuePoint> get portfolioValueHistory =>
      List.from(_portfolioValueHistory);

  // Get purchase price for a stock
  double getPurchasePrice(String symbol) {
    return _purchasePrices[symbol] ?? 0.0;
  }

  // Calculate today's P&L for a stock
  double getTodayPnL(String symbol) {
    final quantity = _portfolio[symbol] ?? 0;
    final currentPrice = _currentPrices[symbol] ?? 0.0;
    final purchasePrice = _purchasePrices[symbol] ?? 0.0;

    if (quantity == 0 || purchasePrice == 0) return 0.0;

    // Mock today's change (in real app, this would be actual market data)
    final todayChangePercent =
        (math.Random().nextDouble() - 0.5) * 0.1; // ±5% change
    final todayPrice = currentPrice * (1 + todayChangePercent);

    return quantity * (todayPrice - currentPrice);
  }

  // Calculate total P&L for a stock
  double getTotalPnL(String symbol) {
    final quantity = _portfolio[symbol] ?? 0;
    final currentPrice = _currentPrices[symbol] ?? 0.0;
    final purchasePrice = _purchasePrices[symbol] ?? 0.0;

    if (quantity == 0 || purchasePrice == 0) return 0.0;

    return quantity * (currentPrice - purchasePrice);
  }

  // Get portfolio diversification by sector
  Map<String, double> getPortfolioDiversification() {
    final Map<String, double> sectorAllocation = {};
    double totalValue = 0.0;

    _portfolio.forEach((symbol, quantity) {
      final price = _currentPrices[symbol] ?? 0.0;
      final value = quantity * price;
      totalValue += value;

      // Mock sector data (in real app, this would come from stock data)
      final sector = _getSectorForSymbol(symbol);
      sectorAllocation[sector] = (sectorAllocation[sector] ?? 0.0) + value;
    });

    // Convert to percentages
    if (totalValue > 0) {
      sectorAllocation.forEach((sector, value) {
        sectorAllocation[sector] = (value / totalValue) * 100;
      });
    }

    return sectorAllocation;
  }

  // Mock sector assignment (in real app, this would come from stock data)
  String _getSectorForSymbol(String symbol) {
    const sectorMap = {
      'AAPL': 'Technology',
      'GOOGL': 'Technology',
      'MSFT': 'Technology',
      'TSLA': 'Automotive',
      'AMZN': 'Consumer Discretionary',
      'META': 'Technology',
      'NVDA': 'Technology',
      'NFLX': 'Communication Services',
      'AMD': 'Technology',
      'INTC': 'Technology',
    };
    return sectorMap[symbol] ?? 'Other';
  }

  // Calculate portfolio diversification score
  int getPortfolioDiversificationScore() {
    final diversification = getPortfolioDiversification();
    final sectorCount = diversification.length;

    if (sectorCount == 0) return 0;
    if (sectorCount == 1) return 20;
    if (sectorCount == 2) return 40;
    if (sectorCount == 3) return 60;
    if (sectorCount == 4) return 80;
    return 100; // 5+ sectors
  }

  // Get diversification score description
  String getDiversificationDescription() {
    final score = getPortfolioDiversificationScore();
    if (score >= 80)
      return "Excellent diversification! Your portfolio is well-balanced across multiple sectors.";
    if (score >= 60)
      return "Good diversification. Consider adding stocks from more sectors.";
    if (score >= 40)
      return "Moderate diversification. Try to spread investments across different industries.";
    return "Low diversification. Consider diversifying across multiple sectors to reduce risk.";
  }

  // Update portfolio value history (called periodically)
  void updatePortfolioValueHistory() {
    final now = DateTime.now();
    final totalValue = totalPortfolioValue;

    _portfolioValueHistory.add(
      PortfolioValuePoint(timestamp: now, value: totalValue),
    );

    // Keep only last 365 days of data
    final cutoffDate = now.subtract(const Duration(days: 365));
    _portfolioValueHistory.removeWhere(
      (point) => point.timestamp.isBefore(cutoffDate),
    );

    notifyListeners();
  }

  // Initialize with some mock history data
  void initializeMockHistory() {
    final now = DateTime.now();
    final baseValue = 100000.0;

    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final random = math.Random(i);
      final variation =
          (random.nextDouble() - 0.5) * 0.1; // ±5% daily variation
      final value = baseValue * (1 + variation * (30 - i) / 30);

      _portfolioValueHistory.add(
        PortfolioValuePoint(timestamp: date, value: value),
      );
    }
  }

  // XP and Leveling System
  void addXp(int amount) {
    _userXp += amount;

    // Check if user should level up
    while (_userXp >= _xpForNextLevel) {
      _userXp -= _xpForNextLevel;
      _userLevel++;
      _xpForNextLevel = (_xpForNextLevel * 1.2)
          .round(); // Increase XP requirement by 20% each level
    }

    notifyListeners();
  }

  // Award XP for trading actions
  void _awardTradingXp(TransactionType type, int quantity, double price) {
    int xpToAward = 0;

    // First trade bonus
    if (_totalTrades == 1) {
      xpToAward += _achievementService.getXpForAction('first_trade');
    }

    // Daily trading bonus (max 3 trades per day)
    if (_dailyTrades <= 3) {
      xpToAward += _achievementService.getXpForAction('daily_trade');
    }

    // Portfolio growth bonus (check if portfolio grew by 5%+)
    final currentValue = totalPortfolioValue;
    if (currentValue > 105000) {
      // 5% growth from starting $100k
      xpToAward += _achievementService.getXpForAction(
        'portfolio_growth_5_percent',
      );
    }

    // Diversification bonus
    final sectors = getPortfolioDiversification().keys.length;
    if (sectors >= 3) {
      xpToAward += _achievementService.getXpForAction('diversification');
    }

    // Long-term holding bonus
    final daysSinceFirstTrade = DateTime.now()
        .difference(_firstTradeDate)
        .inDays;
    if (daysSinceFirstTrade >= 7) {
      xpToAward += _achievementService.getXpForAction('long_term_holding');
    }

    // Risk management bonus
    if (_hasSoldLosingPosition) {
      xpToAward += _achievementService.getXpForAction('risk_management');
    }

    if (xpToAward > 0) {
      addXp(xpToAward);
    }
  }

  // Update daily trade count
  void _updateDailyTradeCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastTradeDay = DateTime(
      _lastTradeDate.year,
      _lastTradeDate.month,
      _lastTradeDate.day,
    );

    if (today.isAfter(lastTradeDay)) {
      _dailyTrades = 1; // New day, reset counter
    } else {
      _dailyTrades++;
    }
    _lastTradeDate = now;
  }

  // Update consecutive wins/losses tracking
  void _updateConsecutiveTrades(
    TransactionType type,
    double purchasePrice,
    double sellPrice,
  ) {
    if (type == TransactionType.sell && purchasePrice > 0) {
      final isProfitable = sellPrice > purchasePrice;

      if (isProfitable) {
        _consecutiveWins++;
        // _consecutiveLosses = 0; // Commented out as not currently used
      } else {
        // _consecutiveLosses++; // Commented out as not currently used
        _consecutiveWins = 0;
      }
    }
  }

  // Check and unlock achievements
  void _checkAndUnlockAchievements() {
    final daysSinceFirstTrade = DateTime.now()
        .difference(_firstTradeDate)
        .inDays;
    final sectorsInvested = getPortfolioDiversification().keys.length;

    // Update max portfolio loss tracking
    final currentLoss = totalGainLossPercentage;
    if (currentLoss < _maxPortfolioLoss) {
      _maxPortfolioLoss = currentLoss;
    }

    final newlyUnlocked = _achievementService.checkAndUnlockAchievements(
      totalTrades: _totalTrades,
      portfolioValue: totalPortfolioValue,
      daysSinceFirstTrade: daysSinceFirstTrade,
      aiChatCount: _aiChatCount,
      articlesRead: _articlesRead,
      quizzesCompleted: _quizzesCompleted,
      perfectQuizzes: _perfectQuizzes,
      communityHelps: _communityHelps,
      consecutiveWins: _consecutiveWins,
      hasSoldLosingPosition: _hasSoldLosingPosition,
      sectorsInvested: sectorsInvested,
      correctPredictions: _correctPredictions,
      maxPortfolioLoss: _maxPortfolioLoss,
    );

    if (newlyUnlocked.isNotEmpty) {
      _recentlyUnlockedAchievements.addAll(newlyUnlocked);

      // Award XP for each achievement
      for (final achievement in newlyUnlocked) {
        addXp(achievement.xpReward);
      }
    }
  }

  // Learning and Social Actions
  void recordAiChat() {
    _aiChatCount++;
    addXp(_achievementService.getXpForAction('ai_chat'));
    _updateChallengesForLearning();
    _checkAndUnlockAchievements();
  }

  void recordArticleRead() {
    _articlesRead++;
    addXp(_achievementService.getXpForAction('read_article'));
    _updateChallengesForLearning();
    _checkAndUnlockAchievements();
  }

  void recordVideoWatched() {
    _videosWatched++;
    addXp(_achievementService.getXpForAction('watch_video'));
    _updateChallengesForLearning();
    _checkAndUnlockAchievements();
  }

  void recordQuizCompleted({bool isPerfect = false}) {
    _quizzesCompleted++;
    if (isPerfect) {
      _perfectQuizzes++;
      addXp(_achievementService.getXpForAction('perfect_quiz'));
    } else {
      addXp(_achievementService.getXpForAction('complete_quiz'));
    }
    _updateChallengesForLearning();
    _checkAndUnlockAchievements();
  }

  void recordCommunityHelp() {
    _communityHelps++;
    addXp(_achievementService.getXpForAction('help_community'));
    _updateChallengesForCommunityHelp();
    _checkAndUnlockAchievements();
  }

  void recordAchievementShared() {
    // _achievementsShared++; // Commented out as not currently used
    addXp(_achievementService.getXpForAction('share_achievement'));
    _updateChallengesForAchievements();
  }

  void recordCorrectPrediction() {
    _correctPredictions++;
    _checkAndUnlockAchievements();
  }

  // Clear recently unlocked achievements (called after displaying them)
  void clearRecentlyUnlockedAchievements() {
    _recentlyUnlockedAchievements.clear();
  }

  // Get random encouragement message
  String getRandomEncouragement() {
    return _achievementService.getRandomEncouragement();
  }

  // Challenge Management
  void initializeChallenges() {
    _challengeService.generateDailyChallenges();
    _challengeService.generateWeeklyChallenges();
    notifyListeners();
  }

  void updateChallengeProgress(
    String challengeId,
    Map<String, dynamic> progressUpdate,
  ) {
    _challengeService.updateChallengeProgress(challengeId, progressUpdate);

    // Check if challenge is completed
    final challenge = _challengeService.getChallenge(challengeId);
    if (challenge != null && challenge.isCompleted) {
      final completedChallenge = _challengeService.completeChallenge(
        challengeId,
      );
      if (completedChallenge != null) {
        _recentlyCompletedChallenges.add(completedChallenge);
        addXp(completedChallenge.xpReward);
      }
    }

    notifyListeners();
  }

  // Update challenges based on user actions
  void _updateChallengesForTrade() {
    // Update trade-related challenges
    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('trades')) {
        _challengeService.updateChallengeProgress(challenge.id, {'trades': 1});
      }
    }
  }

  void _updateChallengesForPortfolioGrowth() {
    final growthPercent = ((totalPortfolioValue - 100000) / 100000) * 100;

    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('portfolio_growth')) {
        final requiredGrowth =
            challenge.requirements['portfolio_growth'] as double;
        if (growthPercent >= requiredGrowth) {
          _challengeService.updateChallengeProgress(challenge.id, {
            'portfolio_growth': growthPercent,
          });
        }
      }
    }
  }

  void _updateChallengesForDiversification() {
    final sectors = getPortfolioDiversification().keys.length;

    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('sectors')) {
        _challengeService.updateChallengeProgress(challenge.id, {
          'sectors': sectors,
        });
      }
    }
  }

  void _updateChallengesForLearning() {
    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('learning_actions')) {
        _challengeService.updateChallengeProgress(challenge.id, {
          'learning_actions': 1,
        });
      }
    }
  }

  // Risk management challenge update (called when selling losing positions)
  void _updateChallengesForRiskManagement() {
    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('risk_management')) {
        _challengeService.updateChallengeProgress(challenge.id, {
          'risk_management': 1,
        });
      }
    }
  }

  void _updateChallengesForCommunityHelp() {
    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('community_helps')) {
        _challengeService.updateChallengeProgress(challenge.id, {
          'community_helps': 1,
        });
      }
    }
  }

  void _updateChallengesForAchievements() {
    for (final challenge in _challengeService.getActiveChallenges()) {
      if (challenge.requirements.containsKey('achievements')) {
        _challengeService.updateChallengeProgress(challenge.id, {
          'achievements': 1,
        });
      }
    }
  }

  // Clear recently completed challenges
  void clearRecentlyCompletedChallenges() {
    _recentlyCompletedChallenges.clear();
  }

  // Get challenge encouragement
  String getChallengeEncouragement() {
    return _challengeService.getRandomChallengeEncouragement();
  }

  // Get level title based on current level
  String getLevelTitle() {
    if (_userLevel <= 3) return 'Novice Investor';
    if (_userLevel <= 6) return 'Rising Trader';
    if (_userLevel <= 10) return 'Experienced Investor';
    if (_userLevel <= 15) return 'Market Analyst';
    if (_userLevel <= 20) return 'Portfolio Manager';
    return 'Investment Master';
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    _realTimeTimer?.cancel();
    super.dispose();
  }

  // Reset portfolio (for testing) - also reset XP and achievements
  void resetPortfolio() {
    _virtualCash = 100000.00;
    _portfolio.clear();
    _transactionHistory.clear();
    _currentPrices.clear();
    _userLevel = 1;
    _userXp = 0;
    _xpForNextLevel = 1000;

    // Reset achievement tracking
    _recentlyUnlockedAchievements.clear();
    _totalTrades = 0;
    _dailyTrades = 0;
    _lastTradeDate = DateTime.now();
    _consecutiveWins = 0;
    // _consecutiveLosses = 0; // Commented out as not currently used
    _hasSoldLosingPosition = false;
    _maxPortfolioLoss = 0.0;
    _firstTradeDate = DateTime.now();

    // Reset learning and social tracking
    _aiChatCount = 0;
    _articlesRead = 0;
    _videosWatched = 0;
    _quizzesCompleted = 0;
    _perfectQuizzes = 0;
    _communityHelps = 0;
    // _achievementsShared = 0; // Commented out as not currently used
    _correctPredictions = 0;

    // Reset achievement service
    _achievementService.resetAchievements();

    // Reset challenge service
    _challengeService.resetChallenges();

    notifyListeners();
  }
}

// Portfolio value point for charting
class PortfolioValuePoint {
  final DateTime timestamp;
  final double value;

  PortfolioValuePoint({required this.timestamp, required this.value});
}

// Transaction model
class Transaction {
  final String symbol;
  final int quantity;
  final double price;
  final TransactionType type;
  final DateTime timestamp;

  Transaction({
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.type,
    required this.timestamp,
  });

  double get totalValue => quantity * price;
}

enum TransactionType { buy, sell }
