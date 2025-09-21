import 'package:cloud_firestore/cloud_firestore.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all stocks from the stocks collection
  Future<List<Map<String, dynamic>>> getAllStocks() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('stocks')
          .orderBy('symbol')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching stocks: $e');
      throw Exception('Failed to fetch stocks: $e');
    }
  }

  /// Fetches a stream of all stocks for real-time updates
  Stream<List<Map<String, dynamic>>> getStocksStream() {
    return _firestore.collection('stocks').orderBy('symbol').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    });
  }

  /// Fetches a specific stock by symbol
  Future<Map<String, dynamic>?> getStockBySymbol(String symbol) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('stocks')
          .where('symbol', isEqualTo: symbol)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }
      return null;
    } catch (e) {
      print('Error fetching stock by symbol: $e');
      throw Exception('Failed to fetch stock: $e');
    }
  }

  /// Fetches top gainers (stocks with highest positive change)
  Future<List<Map<String, dynamic>>> getTopGainers({int limit = 5}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('stocks')
          .orderBy('changePercent', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching top gainers: $e');
      throw Exception('Failed to fetch top gainers: $e');
    }
  }

  /// Fetches top losers (stocks with highest negative change)
  Future<List<Map<String, dynamic>>> getTopLosers({int limit = 5}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('stocks')
          .orderBy('changePercent', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching top losers: $e');
      throw Exception('Failed to fetch top losers: $e');
    }
  }

  /// Fetches most active stocks (by volume or price change)
  Future<List<Map<String, dynamic>>> getMostActive({int limit = 5}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('stocks')
          .orderBy('volume', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching most active stocks: $e');
      throw Exception('Failed to fetch most active stocks: $e');
    }
  }

  /// Gets price history for a specific stock
  Future<List<double>?> getPriceHistory(String symbol) async {
    try {
      final stockData = await getStockBySymbol(symbol);
      if (stockData != null && stockData['priceHistory'] != null) {
        final priceHistory = stockData['priceHistory'] as List<dynamic>;
        return priceHistory.map((price) => (price as num).toDouble()).toList();
      }
      return null;
    } catch (e) {
      print('Error fetching price history for $symbol: $e');
      return null;
    }
  }

  /// Gets the last N prices from price history for sparkline
  Future<List<double>> getLastPrices(String symbol, {int count = 10}) async {
    try {
      final priceHistory = await getPriceHistory(symbol);
      if (priceHistory != null && priceHistory.isNotEmpty) {
        final startIndex = priceHistory.length > count
            ? priceHistory.length - count
            : 0;
        return priceHistory.sublist(startIndex);
      }
      return [];
    } catch (e) {
      print('Error fetching last prices for $symbol: $e');
      return [];
    }
  }

  /// Calculates price change percentage from price history
  double calculatePriceChangePercent(List<double> priceHistory) {
    if (priceHistory.length < 2) return 0.0;

    final currentPrice = priceHistory.last;
    final previousPrice = priceHistory[priceHistory.length - 2];

    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }

  /// Gets price history stream for real-time updates
  Stream<List<double>?> getPriceHistoryStream(String symbol) {
    return _firestore
        .collection('stocks')
        .where('symbol', isEqualTo: symbol)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data() as Map<String, dynamic>;
            if (data['priceHistory'] != null) {
              final priceHistory = data['priceHistory'] as List<dynamic>;
              return priceHistory
                  .map((price) => (price as num).toDouble())
                  .toList();
            }
          }
          return null;
        });
  }
}
