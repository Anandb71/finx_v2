// lib/models/news_article.dart

class NewsArticle {
  final String title;
  final String description;
  final String source;
  final String timeAgo;
  final String? url;
  final String? imageUrl;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.timeAgo,
    required this.publishedAt,
    this.url,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source']?['name'] ?? 'Unknown Source',
      timeAgo: json['timeAgo'] ?? 'Unknown time',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      url: json['url'],
      imageUrl: json['urlToImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'source': {'name': source},
      'timeAgo': timeAgo,
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
      'urlToImage': imageUrl,
    };
  }
}


