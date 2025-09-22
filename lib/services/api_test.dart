import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTest {
  static const String _apiKey = 'd37otghr01qskreh7ci0d37otghr01qskreh7cig';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  // Test the API connection
  static Future<void> testApiConnection() async {
    try {
      print('🔍 Testing Finnhub API connection...');

      // Test with Apple stock (AAPL)
      final response = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=AAPL&token=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      print('📊 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Connection Successful!');
        print('📈 AAPL Data: $data');

        if (data['c'] != null) {
          print('💰 Current Price: \$${data['c']}');
          print('📊 Change: ${data['d']} (${data['dp']}%)');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('📝 Response: ${response.body}');
      }
    } catch (e) {
      print('💥 Connection Error: $e');
    }
  }

  // Test multiple stocks
  static Future<void> testMultipleStocks() async {
    final symbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];

    print('🔍 Testing multiple stocks...');

    for (final symbol in symbols) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['c'] != null) {
            print('📈 $symbol: \$${data['c']} (${data['dp']}%)');
          }
        } else {
          print('❌ $symbol: Error ${response.statusCode}');
        }
      } catch (e) {
        print('💥 $symbol: $e');
      }

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  // Test rate limits
  static Future<void> testRateLimits() async {
    print('🔍 Testing rate limits...');

    final startTime = DateTime.now();
    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < 10; i++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/quote?symbol=AAPL&token=$_apiKey'),
        );

        if (response.statusCode == 200) {
          successCount++;
        } else {
          errorCount++;
          print('⚠️ Request ${i + 1}: ${response.statusCode}');
        }
      } catch (e) {
        errorCount++;
        print('💥 Request ${i + 1}: $e');
      }

      // Small delay between requests
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final duration = DateTime.now().difference(startTime);
    print('📊 Rate Limit Test Results:');
    print('✅ Successful: $successCount');
    print('❌ Errors: $errorCount');
    print('⏱️ Duration: ${duration.inMilliseconds}ms');
  }
}

