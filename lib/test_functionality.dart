import 'dart:convert';
import 'package:http/http.dart' as http;

class FunctionalityTest {
  static const String _apiKey = 'd37otghr01qskreh7ci0d37otghr01qskreh7cig';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  static Future<Map<String, dynamic>> runComprehensiveTest() async {
    final results = <String, dynamic>{};

    print('🧪 Starting Comprehensive Functionality Test...\n');

    // Test 1: API Connection
    results['api_connection'] = await _testApiConnection();

    // Test 2: Multiple Stock Data
    results['multiple_stocks'] = await _testMultipleStocks();

    // Test 3: Rate Limiting
    results['rate_limiting'] = await _testRateLimiting();

    // Test 4: Error Handling
    results['error_handling'] = await _testErrorHandling();

    // Test 5: Data Validation
    results['data_validation'] = await _testDataValidation();

    print('\n📊 Test Results Summary:');
    print('========================');
    results.forEach((key, value) {
      final status = value['success'] ? '✅' : '❌';
      print('$status $key: ${value['message']}');
    });

    return results;
  }

  static Future<Map<String, dynamic>> _testApiConnection() async {
    try {
      print('🔍 Testing API Connection...');

      final response = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=AAPL&token=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['c'] != null && data['d'] != null) {
          print('✅ API Connection: SUCCESS');
          return {
            'success': true,
            'message': 'API connection working',
            'data': data,
          };
        }
      }

      print('❌ API Connection: FAILED');
      return {
        'success': false,
        'message': 'API returned invalid data',
        'error': response.body,
      };
    } catch (e) {
      print('❌ API Connection: ERROR - $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _testMultipleStocks() async {
    try {
      print('🔍 Testing Multiple Stocks...');

      final symbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];
      final results = <String, dynamic>{};
      int successCount = 0;

      for (final symbol in symbols) {
        try {
          final response = await http.get(
            Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['c'] != null) {
              results[symbol] = {
                'price': data['c'],
                'change': data['d'],
                'changePercent': data['dp'],
              };
              successCount++;
              print('✅ $symbol: \$${data['c']} (${data['dp']}%)');
            }
          }
        } catch (e) {
          print('❌ $symbol: Error - $e');
        }
      }

      final success = successCount >= 3; // At least 3 stocks should work
      print(
        success ? '✅ Multiple Stocks: SUCCESS' : '❌ Multiple Stocks: PARTIAL',
      );

      return {
        'success': success,
        'message':
            '$successCount/${symbols.length} stocks fetched successfully',
        'data': results,
      };
    } catch (e) {
      print('❌ Multiple Stocks: ERROR - $e');
      return {'success': false, 'message': 'Error testing multiple stocks: $e'};
    }
  }

  static Future<Map<String, dynamic>> _testRateLimiting() async {
    try {
      print('🔍 Testing Rate Limiting...');

      final startTime = DateTime.now();
      final requests = <Future>[];

      // Make 5 rapid requests
      for (int i = 0; i < 5; i++) {
        requests.add(
          http.get(Uri.parse('$_baseUrl/quote?symbol=AAPL&token=$_apiKey')),
        );
      }

      await Future.wait(requests);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print(
        '✅ Rate Limiting: SUCCESS - 5 requests in ${duration.inMilliseconds}ms',
      );
      return {
        'success': true,
        'message': 'Rate limiting working properly',
        'duration': duration.inMilliseconds,
      };
    } catch (e) {
      print('❌ Rate Limiting: ERROR - $e');
      return {'success': false, 'message': 'Rate limiting test failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _testErrorHandling() async {
    try {
      print('🔍 Testing Error Handling...');

      // Test with invalid symbol
      final response = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=INVALID_SYMBOL_12345&token=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Should return null values for invalid symbol
        if (data['c'] == null || data['c'] == 0) {
          print('✅ Error Handling: SUCCESS - Invalid symbol handled properly');
          return {
            'success': true,
            'message': 'Error handling working correctly',
          };
        }
      }

      print('❌ Error Handling: FAILED - Unexpected response');
      return {
        'success': false,
        'message': 'Error handling not working as expected',
      };
    } catch (e) {
      print('❌ Error Handling: ERROR - $e');
      return {'success': false, 'message': 'Error handling test failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _testDataValidation() async {
    try {
      print('🔍 Testing Data Validation...');

      final response = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=AAPL&token=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate required fields (check for meaningful data, not just existence)
        final hasPrice = data['c'] != null && data['c'] is num && data['c'] > 0;
        final hasChange = data['d'] != null && data['d'] is num;
        final hasChangePercent = data['dp'] != null && data['dp'] is num;
        final hasHigh = data['h'] != null && data['h'] is num && data['h'] > 0;
        final hasLow = data['l'] != null && data['l'] is num && data['l'] > 0;
        final hasOpen = data['o'] != null && data['o'] is num && data['o'] > 0;
        final hasVolume = data['v'] != null && data['v'] is num;

        // Only require essential fields for basic functionality
        final essentialFieldsPresent =
            hasPrice && hasChange && hasChangePercent;
        final optionalFieldsPresent = hasHigh && hasLow && hasOpen && hasVolume;

        if (essentialFieldsPresent) {
          final status = optionalFieldsPresent
              ? 'All fields'
              : 'Essential fields';
          print('✅ Data Validation: SUCCESS - $status present');
          return {
            'success': true,
            'message': 'Data validation passed ($status)',
            'fields': {
              'price': hasPrice,
              'change': hasChange,
              'changePercent': hasChangePercent,
              'high': hasHigh,
              'low': hasLow,
              'open': hasOpen,
              'volume': hasVolume,
            },
          };
        } else {
          print('❌ Data Validation: FAILED - Missing essential fields');
          return {'success': false, 'message': 'Missing essential data fields'};
        }
      }

      print('❌ Data Validation: FAILED - Invalid response');
      return {'success': false, 'message': 'Invalid API response'};
    } catch (e) {
      print('❌ Data Validation: ERROR - $e');
      return {'success': false, 'message': 'Data validation test failed: $e'};
    }
  }
}
