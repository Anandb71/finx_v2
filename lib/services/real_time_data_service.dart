import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class RealTimeDataService {
  static final RealTimeDataService _instance = RealTimeDataService._internal();
  factory RealTimeDataService() => _instance;
  RealTimeDataService._internal();

  // Configuration
  static const String _finnhubApiKey =
      'd37otghr01qskreh7ci0d37otghr01qskreh7cig';
  static const String _finnhubBaseUrl = 'https://finnhub.io/api/v1';

  // Data caches
  final Map<String, StockData> _stockCache = {};
  final Map<String, List<double>> _priceHistoryCache = {};
  final Map<String, StreamController<StockData>> _stockStreams = {};

  // Rate limiting
  final Map<String, DateTime> _lastFetchTimes = {};
  static const Duration _minFetchInterval = Duration(seconds: 1);

  // Batch processing
  final List<String> _pendingSymbols = [];
  Timer? _batchTimer;

  /// Get real-time stock data with caching and rate limiting
  Future<StockData?> getStockData(String symbol) async {
    // Check cache first
    if (_stockCache.containsKey(symbol)) {
      final cached = _stockCache[symbol]!;
      if (DateTime.now().difference(cached.lastUpdated).inSeconds < 30) {
        return cached;
      }
    }

    // Check rate limiting
    if (_isRateLimited(symbol)) {
      return _stockCache[symbol];
    }

    try {
      final data = await _fetchStockData(symbol);
      if (data != null) {
        _stockCache[symbol] = data;
        _lastFetchTimes[symbol] = DateTime.now();

        // Update Firestore
        await _updateFirestore(symbol, data);

        // Notify streams
        _notifyStreams(symbol, data);
      }
      return data;
    } catch (e) {
      print('Error fetching stock data for $symbol: $e');
      return _stockCache[symbol];
    }
  }

  /// Get streaming stock data
  Stream<StockData> getStockStream(String symbol) {
    if (!_stockStreams.containsKey(symbol)) {
      _stockStreams[symbol] = StreamController<StockData>.broadcast();
    }
    return _stockStreams[symbol]!.stream;
  }

  /// Get multiple stocks efficiently (batch processing)
  Future<Map<String, StockData>> getMultipleStocks(List<String> symbols) async {
    final results = <String, StockData>{};

    // Add to batch queue
    _pendingSymbols.addAll(symbols);

    // Start batch timer if not running
    _batchTimer ??= Timer.periodic(
      Duration(seconds: 5),
      (_) => _processBatch(),
    );

    // Process immediately for critical data
    for (final symbol in symbols) {
      if (_stockCache.containsKey(symbol)) {
        results[symbol] = _stockCache[symbol]!;
      }
    }

    return results;
  }

  /// Get price history with intelligent caching
  Future<List<double>> getPriceHistory(String symbol, String timeframe) async {
    final cacheKey = '${symbol}_$timeframe';

    if (_priceHistoryCache.containsKey(cacheKey)) {
      return _priceHistoryCache[cacheKey]!;
    }

    try {
      final history = await _fetchPriceHistory(symbol, timeframe);
      _priceHistoryCache[cacheKey] = history;

      // Cache for 5 minutes
      Timer(Duration(minutes: 5), () {
        _priceHistoryCache.remove(cacheKey);
      });

      return history;
    } catch (e) {
      print('Error fetching price history for $symbol: $e');
      return [];
    }
  }

  /// Process batch requests efficiently
  Future<void> _processBatch() async {
    if (_pendingSymbols.isEmpty) return;

    final symbols = List<String>.from(_pendingSymbols);
    _pendingSymbols.clear();

    // Process in chunks to avoid API limits
    const chunkSize = 10;
    for (int i = 0; i < symbols.length; i += chunkSize) {
      final chunk = symbols.skip(i).take(chunkSize).toList();
      await _processChunk(chunk);

      // Rate limiting between chunks
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  /// Process a chunk of symbols
  Future<void> _processChunk(List<String> symbols) async {
    final futures = symbols.map((symbol) => getStockData(symbol));
    await Future.wait(futures);
  }

  /// Fetch stock data from Finnhub API
  Future<StockData?> _fetchStockData(String symbol) async {
    final url = '$_finnhubBaseUrl/quote?symbol=$symbol&token=$_finnhubApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StockData.fromFinnhub(symbol, data);
    }
    return null;
  }

  /// Fetch price history from Finnhub API
  Future<List<double>> _fetchPriceHistory(
    String symbol,
    String timeframe,
  ) async {
    final resolution = _getResolution(timeframe);
    final to = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final from = to - _getTimeframeSeconds(timeframe);

    final url =
        '$_finnhubBaseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$_finnhubApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prices = List<double>.from(data['c'] ?? []);
      return prices;
    }
    return [];
  }

  /// Update Firestore with new data
  Future<void> _updateFirestore(String symbol, StockData data) async {
    try {
      await FirebaseFirestore.instance
          .collection('stocks')
          .doc(symbol)
          .set(data.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating Firestore for $symbol: $e');
    }
  }

  /// Notify all streams for a symbol
  void _notifyStreams(String symbol, StockData data) {
    if (_stockStreams.containsKey(symbol)) {
      _stockStreams[symbol]!.add(data);
    }
  }

  /// Check if symbol is rate limited
  bool _isRateLimited(String symbol) {
    final lastFetch = _lastFetchTimes[symbol];
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _minFetchInterval;
  }

  /// Get resolution for timeframe
  String _getResolution(String timeframe) {
    switch (timeframe) {
      case '1D':
        return '1';
      case '1W':
        return 'D';
      case '1M':
        return 'D';
      case '3M':
        return 'W';
      case '6M':
        return 'W';
      case '1Y':
        return 'M';
      default:
        return '1';
    }
  }

  /// Get seconds for timeframe
  int _getTimeframeSeconds(String timeframe) {
    switch (timeframe) {
      case '1D':
        return 86400;
      case '1W':
        return 604800;
      case '1M':
        return 2592000;
      case '3M':
        return 7776000;
      case '6M':
        return 15552000;
      case '1Y':
        return 31536000;
      default:
        return 86400;
    }
  }

  /// Clean up resources
  void dispose() {
    _batchTimer?.cancel();
    for (final controller in _stockStreams.values) {
      controller.close();
    }
    _stockStreams.clear();
  }
}

/// Enhanced StockData model for real-time data
class StockData {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousClose;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double open;
  final double volume;
  final DateTime lastUpdated;
  final String marketStatus;
  final double marketCap;
  final double pe;
  final double eps;
  final double dividend;
  final double dividendYield;

  StockData({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.open,
    required this.volume,
    required this.lastUpdated,
    required this.marketStatus,
    required this.marketCap,
    required this.pe,
    required this.eps,
    required this.dividend,
    required this.dividendYield,
  });

  factory StockData.fromFinnhub(String symbol, Map<String, dynamic> data) {
    return StockData(
      symbol: symbol,
      name: data['name'] ?? symbol,
      currentPrice: (data['c'] ?? 0.0).toDouble(),
      previousClose: (data['pc'] ?? 0.0).toDouble(),
      change: (data['d'] ?? 0.0).toDouble(),
      changePercent: (data['dp'] ?? 0.0).toDouble(),
      high: (data['h'] ?? 0.0).toDouble(),
      low: (data['l'] ?? 0.0).toDouble(),
      open: (data['o'] ?? 0.0).toDouble(),
      volume: (data['v'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.now(),
      marketStatus: data['marketStatus'] ?? 'open',
      marketCap: (data['marketCap'] ?? 0.0).toDouble(),
      pe: (data['pe'] ?? 0.0).toDouble(),
      eps: (data['eps'] ?? 0.0).toDouble(),
      dividend: (data['dividend'] ?? 0.0).toDouble(),
      dividendYield: (data['dividendYield'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'previousClose': previousClose,
      'change': change,
      'changePercent': changePercent,
      'high': high,
      'low': low,
      'open': open,
      'volume': volume,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'marketStatus': marketStatus,
      'marketCap': marketCap,
      'pe': pe,
      'eps': eps,
      'dividend': dividend,
      'dividendYield': dividendYield,
    };
  }

  StockData copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousClose,
    double? change,
    double? changePercent,
    double? high,
    double? low,
    double? open,
    double? volume,
    DateTime? lastUpdated,
    String? marketStatus,
    double? marketCap,
    double? pe,
    double? eps,
    double? dividend,
    double? dividendYield,
  }) {
    return StockData(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousClose: previousClose ?? this.previousClose,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      volume: volume ?? this.volume,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      marketStatus: marketStatus ?? this.marketStatus,
      marketCap: marketCap ?? this.marketCap,
      pe: pe ?? this.pe,
      eps: eps ?? this.eps,
      dividend: dividend ?? this.dividend,
      dividendYield: dividendYield ?? this.dividendYield,
    );
  }
}
