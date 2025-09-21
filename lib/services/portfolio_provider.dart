import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class PortfolioProvider extends ChangeNotifier {
  // Starting virtual cash
  double _virtualCash = 100000.00;

  // Portfolio holdings: {symbol: quantity}
  Map<String, int> _portfolio = {};

  // Transaction history for analytics
  List<Transaction> _transactionHistory = [];

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
  List<Transaction> get transactionHistory => List.from(_transactionHistory);
  Map<String, double> get currentPrices => Map.from(_currentPrices);

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
    } else {
      _virtualCash += totalCost;
      _portfolio[symbol] = (_portfolio[symbol] ?? 0) - quantity;

      // Remove from portfolio if quantity reaches 0
      if (_portfolio[symbol] == 0) {
        _portfolio.remove(symbol);
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
