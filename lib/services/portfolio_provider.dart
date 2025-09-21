import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class PortfolioProvider extends ChangeNotifier {
  // Starting virtual cash
  double _virtualCash = 100000.00;

  // Portfolio holdings: {symbol: quantity}
  Map<String, int> _portfolio = {};

  // Transaction history for analytics
  List<Transaction> _transactionHistory = [];

  // Portfolio value history for charts
  final List<PortfolioValuePoint> _portfolioValueHistory = [];

  // Purchase prices for each stock (for P&L calculations)
  final Map<String, double> _purchasePrices = {};

  // Current stock prices (mock data for now)
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

  // Getters
  double get virtualCash => _virtualCash;
  Map<String, int> get portfolio => Map.from(_portfolio);
  Map<String, double> get currentPrices => Map.from(_currentPrices);
  List<Transaction> get transactionHistory => List.from(_transactionHistory);

  // Get total portfolio value
  double get totalPortfolioValue {
    double total = _virtualCash;
    _portfolio.forEach((symbol, quantity) {
      final price = _currentPrices[symbol] ?? 0.0;
      total += quantity * price;
    });
    return total;
  }

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
    if (totalGainLoss == 0) return 0.0;
    final totalInvested = 100000.00 - _virtualCash + totalGainLoss;
    return (totalGainLoss / totalInvested) * 100;
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

    // Validate trade
    if (type == TransactionType.buy) {
      if (_virtualCash < totalCost) {
        return false; // Not enough cash
      }
    } else if (type == TransactionType.sell) {
      final currentHolding = _portfolio[symbol] ?? 0;
      if (currentHolding < quantity) {
        return false; // Not enough shares
      }
    }

    // Execute the trade
    if (type == TransactionType.buy) {
      _virtualCash -= totalCost;
      _portfolio[symbol] = (_portfolio[symbol] ?? 0) + quantity;

      // Update purchase price (weighted average)
      final currentQuantity = _portfolio[symbol] ?? 0;
      final currentPurchasePrice = _purchasePrices[symbol] ?? 0.0;
      final currentValue = (currentQuantity - quantity) * currentPurchasePrice;
      final newValue = currentValue + totalCost;
      _purchasePrices[symbol] = newValue / currentQuantity;
    } else {
      _virtualCash += totalCost;
      _portfolio[symbol] = (_portfolio[symbol] ?? 0) - quantity;

      // Remove from portfolio if quantity reaches 0
      if (_portfolio[symbol] == 0) {
        _portfolio.remove(symbol);
        _purchasePrices.remove(symbol);
      }
    }

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

  // Reset portfolio (for testing)
  void resetPortfolio() {
    _virtualCash = 100000.00;
    _portfolio.clear();
    _transactionHistory.clear();
    notifyListeners();
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
