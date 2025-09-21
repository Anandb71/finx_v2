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
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching stocks: $e');
      throw Exception('Failed to fetch stocks: $e');
    }
  }

  /// Fetches a stream of all stocks for real-time updates
  Stream<List<Map<String, dynamic>>> getStocksStream() {
    return _firestore
        .collection('stocks')
        .orderBy('symbol')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
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
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
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
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
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
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
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
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching most active stocks: $e');
      throw Exception('Failed to fetch most active stocks: $e');
    }
  }
}
