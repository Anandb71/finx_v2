import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // Configuration
  static String get _newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  static const String _newsBaseUrl = 'https://newsapi.org/v2';

  // Data caches
  final Map<String, List<NewsArticle>> _newsCache = {};
  final Map<String, DateTime> _lastFetchTimes = {};
  static const Duration _minFetchInterval = Duration(minutes: 5);

  /// Get financial news with caching and rate limiting
  Future<List<NewsArticle>> getFinancialNews({int pageSize = 10}) async {
    final cacheKey = 'financial_news_$pageSize';

    // Check cache first - extend cache time to 10 minutes
    if (_newsCache.containsKey(cacheKey)) {
      final cached = _newsCache[cacheKey]!;
      if (_lastFetchTimes.containsKey(cacheKey) &&
          DateTime.now().difference(_lastFetchTimes[cacheKey]!).inMinutes <
              10) {
        return cached;
      }
    }

    try {
      final articles = await _fetchFinancialNews(pageSize);
      if (articles.isNotEmpty) {
        _newsCache[cacheKey] = articles;
        _lastFetchTimes[cacheKey] = DateTime.now();
        return articles;
      } else {
        // If API returns empty, return cached data or fallback
        return _newsCache[cacheKey] ?? _getFallbackNews();
      }
    } catch (e) {
      print('Error fetching financial news: $e');
      // Return cached data if available, otherwise fallback
      return _newsCache[cacheKey] ?? _getFallbackNews();
    }
  }

  /// Get market news for specific symbols
  Future<List<NewsArticle>> getMarketNews(
    List<String> symbols, {
    int pageSize = 5,
  }) async {
    final cacheKey = 'market_news_${symbols.join('_')}_$pageSize';

    // Check cache first
    if (_newsCache.containsKey(cacheKey)) {
      final cached = _newsCache[cacheKey]!;
      if (_lastFetchTimes.containsKey(cacheKey) &&
          DateTime.now().difference(_lastFetchTimes[cacheKey]!).inMinutes < 5) {
        return cached;
      }
    }

    try {
      final articles = await _fetchMarketNews(symbols, pageSize);
      if (articles.isNotEmpty) {
        _newsCache[cacheKey] = articles;
        _lastFetchTimes[cacheKey] = DateTime.now();
      }
      return articles;
    } catch (e) {
      print('Error fetching market news: $e');
      return _newsCache[cacheKey] ?? [];
    }
  }

  /// Fetch financial news from News API
  Future<List<NewsArticle>> _fetchFinancialNews(int pageSize) async {
    if (_newsApiKey.isEmpty) {
      print('News API key not found');
      return _getFallbackNews();
    }

    final url = Uri.parse(
      '$_newsBaseUrl/everything?q=finance OR stock OR market OR investment OR trading&'
      'language=en&sortBy=publishedAt&pageSize=$pageSize&apiKey=$_newsApiKey',
    );

    print('📰 Fetching financial news from News API...');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok' && data['articles'] != null) {
        final articles = (data['articles'] as List)
            .map((json) => NewsArticle.fromJson(json))
            .where((article) => article.title.isNotEmpty)
            .toList();
        print('📰 Fetched ${articles.length} financial news articles');
        return articles;
      }
    }

    print('📰 News API error: ${response.statusCode} - ${response.body}');
    return _getFallbackNews();
  }

  /// Fetch market news for specific symbols
  Future<List<NewsArticle>> _fetchMarketNews(
    List<String> symbols,
    int pageSize,
  ) async {
    if (_newsApiKey.isEmpty) {
      print('News API key not found');
      return _getFallbackNews();
    }

    final query = symbols
        .map((symbol) => '($symbol OR "${symbol}")')
        .join(' OR ');
    final url = Uri.parse(
      '$_newsBaseUrl/everything?q=$query&language=en&sortBy=publishedAt&pageSize=$pageSize&apiKey=$_newsApiKey',
    );

    print('📰 Fetching market news for ${symbols.join(', ')}...');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok' && data['articles'] != null) {
        final articles = (data['articles'] as List)
            .map((json) => NewsArticle.fromJson(json))
            .where((article) => article.title.isNotEmpty)
            .toList();
        print('📰 Fetched ${articles.length} market news articles');
        return articles;
      }
    }

    print(
      '📰 Market news API error: ${response.statusCode} - ${response.body}',
    );
    return _getFallbackNews();
  }

  /// Get fallback news when API fails
  List<NewsArticle> _getFallbackNews() {
    return [
      NewsArticle(
        title: "Market Update: Tech Stocks Show Strong Performance",
        description:
            "Technology stocks continue to demonstrate resilience in the current market environment, with several major companies reporting positive earnings.",
        url: "https://example.com/news1",
        urlToImage:
            "https://via.placeholder.com/300x200/1a1a2e/ffffff?text=Tech+News",
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: "Financial Times",
      ),
      NewsArticle(
        title: "Investment Strategies for 2024",
        description:
            "Financial experts share their insights on investment opportunities and market trends for the upcoming year.",
        url: "https://example.com/news2",
        urlToImage:
            "https://via.placeholder.com/300x200/16213e/ffffff?text=Investment",
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: "Wall Street Journal",
      ),
      NewsArticle(
        title: "Cryptocurrency Market Analysis",
        description:
            "A comprehensive look at the current state of cryptocurrency markets and what investors should know.",
        url: "https://example.com/news3",
        urlToImage:
            "https://via.placeholder.com/300x200/0f3460/ffffff?text=Crypto",
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: "CoinDesk",
      ),
    ];
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? 'Unknown Source',
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
