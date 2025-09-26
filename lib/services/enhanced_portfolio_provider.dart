import 'dart:async';
import 'package:flutter/foundation.dart';
import 'real_time_data_service.dart';

class EnhancedPortfolioProvider extends ChangeNotifier {
  static final EnhancedPortfolioProvider _instance =
      EnhancedPortfolioProvider._internal();
  factory EnhancedPortfolioProvider() => _instance;
  EnhancedPortfolioProvider._internal();

  final RealTimeDataService _dataService = RealTimeDataService();

  // Portfolio data
  double _virtualCash = 100000.0;
  final Map<String, int> _holdings = {};
  final List<Transaction> _transactions = [];

  // Real-time data
  final Map<String, StockData> _currentStockData = {};
  final Map<String, List<double>> _priceHistory = {};

  // Streams and timers
  Timer? _updateTimer;
  final Map<String, StreamSubscription> _stockSubscriptions = {};

  // Performance tracking
  double _totalValue = 100000.0; // Start with $100K virtual currency
  double _totalGain = 0.0;
  double _totalGainPercent = 0.0;
  double _dayGain = 0.0;
  double _dayGainPercent = 0.0;

  // Getters
  double get virtualCash => _virtualCash;
  Map<String, int> get holdings => Map.unmodifiable(_holdings);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  Map<String, StockData> get currentStockData =>
      Map.unmodifiable(_currentStockData);
  double get totalValue => _totalValue;
  double get totalGain => _totalGain;
  double get totalGainPercent => _totalGainPercent;
  double get dayGain => _dayGain;
  double get dayGainPercent => _dayGainPercent;

  int get userLevel {
    // Example logic: Level up every $5,000 in portfolio value
    if (totalValue < 5000) return 1;
    return (totalValue / 5000).floor() + 1;
  }

  /// Initialize real-time data updates
  void initializeRealTimeData() {
    // Start periodic updates
    _updateTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => _updateAllData(),
    );

    // Subscribe to held stocks
    for (final symbol in _holdings.keys) {
      _subscribeToStock(symbol);
    }

    // Load popular market stocks
    _loadMarketMovers();

    _updateAllData();
  }

  /// Subscribe to real-time updates for a stock
  void _subscribeToStock(String symbol) {
    if (_stockSubscriptions.containsKey(symbol)) return;

    _stockSubscriptions[symbol] = _dataService
        .getStockStream(symbol)
        .listen(
          (data) {
            _currentStockData[symbol] = data;
            _updatePortfolioValue();
            notifyListeners();
          },
          onError: (error) {
            print('Error in stock stream for $symbol: $error');
          },
        );
  }

  /// Unsubscribe from stock updates
  void _unsubscribeFromStock(String symbol) {
    _stockSubscriptions[symbol]?.cancel();
    _stockSubscriptions.remove(symbol);
    _currentStockData.remove(symbol);
  }

  /// Load popular market movers
  Future<void> _loadMarketMovers() async {
    final popularSymbols = [
      'AAPL',
      'GOOGL',
      'MSFT',
      'TSLA',
      'AMZN',
      'META',
      'NVDA',
      'NFLX',
    ];

    try {
      final stockData = await _dataService.getMultipleStocks(popularSymbols);

      for (final entry in stockData.entries) {
        _currentStockData[entry.key] = entry.value;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading market movers: $e');
    }
  }

  /// Update all portfolio data
  Future<void> _updateAllData() async {
    final symbols = _holdings.keys.toList();
    if (symbols.isEmpty) {
      // If no holdings, just update market movers
      _loadMarketMovers();
      return;
    }

    try {
      // Batch fetch all stock data
      final stockData = await _dataService.getMultipleStocks(symbols);

      for (final entry in stockData.entries) {
        _currentStockData[entry.key] = entry.value;
      }

      _updatePortfolioValue();
      notifyListeners();
    } catch (e) {
      print('Error updating portfolio data: $e');
    }
  }

  /// Update portfolio value calculations
  void _updatePortfolioValue() {
    double newTotalValue = _virtualCash;
    double newTotalGain = 0.0;
    double newDayGain = 0.0;

    for (final entry in _holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final stockData = _currentStockData[symbol];

      if (stockData != null) {
        final currentValue = quantity * stockData.currentPrice;
        newTotalValue += currentValue;

        // Calculate total gain (vs average cost)
        final avgCost = _getAverageCost(symbol);
        if (avgCost > 0) {
          newTotalGain += (stockData.currentPrice - avgCost) * quantity;
        }

        // Calculate day gain
        newDayGain += (stockData.change) * quantity;
      }
    }

    _totalValue = newTotalValue;
    _totalGain = newTotalGain;
    _totalGainPercent = _totalValue > 0
        ? (_totalGain / (_totalValue - _totalGain)) * 100
        : 0;
    _dayGain = newDayGain;
    _dayGainPercent = _totalValue > 0 ? (_dayGain / _totalValue) * 100 : 0;
  }

  /// Get average cost for a stock
  double _getAverageCost(String symbol) {
    final stockTransactions = _transactions
        .where((t) => t.symbol == symbol && t.type == TransactionType.buy)
        .toList();

    if (stockTransactions.isEmpty) return 0.0;

    double totalCost = 0.0;
    int totalQuantity = 0;

    for (final transaction in stockTransactions) {
      totalCost += transaction.quantity * transaction.price;
      totalQuantity += transaction.quantity;
    }

    return totalQuantity > 0 ? totalCost / totalQuantity : 0.0;
  }

  /// Execute a trade with real-time data
  Future<bool> executeTrade({
    required String symbol,
    required int quantity,
    required TransactionType type,
  }) async {
    try {
      // Get current stock data
      final stockData = await _dataService.getStockData(symbol);
      if (stockData == null) {
        print('Could not fetch current price for $symbol');
        return false;
      }

      final currentPrice = stockData.currentPrice;

      // Validate trade
      if (type == TransactionType.buy) {
        final totalCost = quantity * currentPrice;
        if (totalCost > _virtualCash) {
          print(
            'Insufficient funds: need \$${totalCost.toStringAsFixed(2)}, have \$${_virtualCash.toStringAsFixed(2)}',
          );
          return false;
        }
      } else {
        if (!_holdings.containsKey(symbol) || _holdings[symbol]! < quantity) {
          print(
            'Insufficient shares: need $quantity, have ${_holdings[symbol] ?? 0}',
          );
          return false;
        }
      }

      // Execute trade
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        quantity: quantity,
        price: currentPrice,
        type: type,
        timestamp: DateTime.now(),
        totalValue: quantity * currentPrice,
      );

      _transactions.add(transaction);

      if (type == TransactionType.buy) {
        _virtualCash -= transaction.totalValue;
        _holdings[symbol] = (_holdings[symbol] ?? 0) + quantity;

        // Subscribe to real-time updates if new stock
        if (!_stockSubscriptions.containsKey(symbol)) {
          _subscribeToStock(symbol);
        }
      } else {
        _virtualCash += transaction.totalValue;
        _holdings[symbol] = _holdings[symbol]! - quantity;

        // Unsubscribe if no more shares
        if (_holdings[symbol] == 0) {
          _holdings.remove(symbol);
          _unsubscribeFromStock(symbol);
        }
      }

      _updatePortfolioValue();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error executing trade: $e');
      return false;
    }
  }

  /// Get price history for a stock
  Future<List<double>> getPriceHistory(String symbol, String timeframe) async {
    if (_priceHistory.containsKey('${symbol}_$timeframe')) {
      return _priceHistory['${symbol}_$timeframe']!;
    }

    try {
      final history = await _dataService.getPriceHistory(symbol, timeframe);
      _priceHistory['${symbol}_$timeframe'] = history;
      return history;
    } catch (e) {
      print('Error fetching price history for $symbol: $e');
      return [];
    }
  }

  /// Get current price for a stock
  double getCurrentPrice(String symbol) {
    return _currentStockData[symbol]?.currentPrice ?? 0.0;
  }

  /// Get stock data for a symbol
  StockData? getStockData(String symbol) {
    return _currentStockData[symbol];
  }

  /// Get portfolio performance metrics
  Map<String, double> getPerformanceMetrics() {
    return {
      'totalValue': _totalValue,
      'totalGain': _totalGain,
      'totalGainPercent': _totalGainPercent,
      'dayGain': _dayGain,
      'dayGainPercent': _dayGainPercent,
      'virtualCash': _virtualCash,
    };
  }

  /// Get top performers
  List<Map<String, dynamic>> getTopPerformers() {
    final performers = <Map<String, dynamic>>[];

    for (final entry in _holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final stockData = _currentStockData[symbol];

      if (stockData != null) {
        final avgCost = _getAverageCost(symbol);
        final gain = (stockData.currentPrice - avgCost) * quantity;
        final gainPercent = avgCost > 0
            ? ((stockData.currentPrice - avgCost) / avgCost) * 100
            : 0;

        performers.add({
          'symbol': symbol,
          'name': stockData.name,
          'quantity': quantity,
          'currentPrice': stockData.currentPrice,
          'avgCost': avgCost,
          'gain': gain,
          'gainPercent': gainPercent,
          'value': quantity * stockData.currentPrice,
        });
      }
    }

    performers.sort(
      (a, b) =>
          (b['gainPercent'] as double).compareTo(a['gainPercent'] as double),
    );
    return performers;
  }

  /// Get sector allocation
  Map<String, double> getSectorAllocation() {
    final sectors = <String, double>{};
    double totalValue = _virtualCash;

    for (final entry in _holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final stockData = _currentStockData[symbol];

      if (stockData != null) {
        final value = quantity * stockData.currentPrice;
        totalValue += value;

        // This would need to be enhanced with actual sector data
        final sector = _getSectorForSymbol(symbol);
        sectors[sector] = (sectors[sector] ?? 0) + value;
      }
    }

    // Convert to percentages
    for (final entry in sectors.entries) {
      sectors[entry.key] = (entry.value / totalValue) * 100;
    }

    return sectors;
  }

  /// Get sector for symbol (mock implementation)
  String _getSectorForSymbol(String symbol) {
    // This would typically come from a sector mapping service
    final sectorMap = {
      'AAPL': 'Technology',
      'GOOGL': 'Technology',
      'MSFT': 'Technology',
      'TSLA': 'Automotive',
      'AMZN': 'Consumer Discretionary',
      'JNJ': 'Healthcare',
      'JPM': 'Financial Services',
      'PG': 'Consumer Staples',
      'UNH': 'Healthcare',
      'V': 'Financial Services',
    };

    return sectorMap[symbol] ?? 'Other';
  }

  /// Clean up resources
  @override
  void dispose() {
    _updateTimer?.cancel();
    for (final subscription in _stockSubscriptions.values) {
      subscription.cancel();
    }
    _stockSubscriptions.clear();
    _dataService.dispose();
    super.dispose();
  }
}

/// Enhanced Transaction model
class Transaction {
  final String id;
  final String symbol;
  final int quantity;
  final double price;
  final TransactionType type;
  final DateTime timestamp;
  final double totalValue;

  Transaction({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.type,
    required this.timestamp,
    required this.totalValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'quantity': quantity,
      'price': price,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'totalValue': totalValue,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      symbol: json['symbol'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.buy,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      totalValue: json['totalValue'].toDouble(),
    );
  }
}

enum TransactionType { buy, sell }
