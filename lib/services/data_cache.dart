import 'dart:convert';
import 'dart:io';

class DataCache {
  static final DataCache _instance = DataCache._internal();
  factory DataCache() => _instance;
  DataCache._internal();

  // In-memory cache for demonstration
  // In production, you'd use SharedPreferences or a proper database
  final Map<String, String> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache duration - 5 minutes for stock data, 1 hour for user data
  static const Duration _stockCacheDuration = Duration(minutes: 5);
  static const Duration _userCacheDuration = Duration(hours: 1);

  // Cache stock data
  Future<void> cacheStockData(Map<String, dynamic> stockData) async {
    try {
      final jsonData = json.encode(stockData);
      _cache['stock_data'] = jsonData;
      _cacheTimestamps['stock_data'] = DateTime.now();
    } catch (e) {
      print('Error caching stock data: $e');
    }
  }

  // Get cached stock data
  Future<Map<String, dynamic>?> getCachedStockData() async {
    try {
      final lastUpdate = _cacheTimestamps['stock_data'];

      if (lastUpdate == null) return null;

      final now = DateTime.now();

      // Check if cache is still valid
      if (now.difference(lastUpdate) > _stockCacheDuration) {
        return null; // Cache expired
      }

      final jsonData = _cache['stock_data'];
      if (jsonData == null) return null;

      return json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cached stock data: $e');
      return null;
    }
  }

  // Cache portfolio data
  Future<void> cachePortfolioData(Map<String, dynamic> portfolioData) async {
    try {
      final jsonData = json.encode(portfolioData);
      _cache['portfolio_data'] = jsonData;
      _cacheTimestamps['portfolio_data'] = DateTime.now();
    } catch (e) {
      print('Error caching portfolio data: $e');
    }
  }

  // Get cached portfolio data
  Future<Map<String, dynamic>?> getCachedPortfolioData() async {
    try {
      final jsonData = _cache['portfolio_data'];
      if (jsonData == null) return null;
      return json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cached portfolio data: $e');
      return null;
    }
  }

  // Cache user data
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    try {
      final jsonData = json.encode(userData);
      _cache['user_data'] = jsonData;
      _cacheTimestamps['user_data'] = DateTime.now();
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

  // Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final lastUpdate = _cacheTimestamps['user_data'];

      if (lastUpdate == null) return null;

      final now = DateTime.now();

      // Check if cache is still valid
      if (now.difference(lastUpdate) > _userCacheDuration) {
        return null; // Cache expired
      }

      final jsonData = _cache['user_data'];
      if (jsonData == null) return null;

      return json.decode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cached user data: $e');
      return null;
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      _cache.clear();
      _cacheTimestamps.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Clear expired cache
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];

      for (final entry in _cacheTimestamps.entries) {
        final key = entry.key;
        final timestamp = entry.value;

        Duration cacheDuration;
        if (key == 'stock_data') {
          cacheDuration = _stockCacheDuration;
        } else if (key == 'user_data') {
          cacheDuration = _userCacheDuration;
        } else {
          continue; // Skip unknown keys
        }

        if (now.difference(timestamp) > cacheDuration) {
          keysToRemove.add(key);
        }
      }

      for (final key in keysToRemove) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }

  // Get cache size (approximate)
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      for (final value in _cache.values) {
        totalSize += value.length;
      }

      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  // Check if device is online
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Smart data fetching - tries cache first, then API
  Future<Map<String, dynamic>?> getSmartData(
    String dataType,
    Future<Map<String, dynamic>> Function() apiCall,
  ) async {
    // First try to get from cache
    Map<String, dynamic>? cachedData;

    switch (dataType) {
      case 'stock':
        cachedData = await getCachedStockData();
        break;
      case 'portfolio':
        cachedData = await getCachedPortfolioData();
        break;
      case 'user':
        cachedData = await getCachedUserData();
        break;
    }

    // If we have valid cached data, return it
    if (cachedData != null) {
      return cachedData;
    }

    // If no cache or cache expired, try API
    try {
      final online = await isOnline();
      if (!online) {
        // Return stale cache if offline
        return cachedData;
      }

      final freshData = await apiCall();

      // Cache the fresh data
      switch (dataType) {
        case 'stock':
          await cacheStockData(freshData);
          break;
        case 'portfolio':
          await cachePortfolioData(freshData);
          break;
        case 'user':
          await cacheUserData(freshData);
          break;
      }

      return freshData;
    } catch (e) {
      print('API call failed, returning cached data: $e');
      return cachedData; // Return stale cache if API fails
    }
  }
}
