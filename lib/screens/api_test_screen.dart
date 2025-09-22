import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_test.dart';
import '../services/real_time_data_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final RealTimeDataService _dataService = RealTimeDataService();
  List<String> _testResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          'API Test',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finnhub API Integration Test',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Testing your API key: d37otghr01qskreh7ci0d37otghr01qskreh7cig',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Test Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTestButton(
                    'Test Connection',
                    Icons.wifi,
                    _testConnection,
                  ),
                  _buildTestButton(
                    'Test Multiple Stocks',
                    Icons.list,
                    _testMultipleStocks,
                  ),
                  _buildTestButton(
                    'Test Rate Limits',
                    Icons.speed,
                    _testRateLimits,
                  ),
                  _buildTestButton(
                    'Test Real Service',
                    Icons.api,
                    _testRealService,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Results
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            color: const Color(0xFF00FFA3),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Test Results',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00FFA3),
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00FFA3),
                                strokeWidth: 2,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _testResults
                                .map(
                                  (result) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      result,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFA3).withOpacity(0.1),
        foregroundColor: const Color(0xFF00FFA3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: const Color(0xFF00FFA3).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(
        '${DateTime.now().toString().substring(11, 19)} - $result',
      );
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🔍 Testing API connection...');
    await ApiTest.testApiConnection();
    _addResult('✅ Connection test completed');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testMultipleStocks() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🔍 Testing multiple stocks...');
    await ApiTest.testMultipleStocks();
    _addResult('✅ Multiple stocks test completed');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testRateLimits() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🔍 Testing rate limits...');
    await ApiTest.testRateLimits();
    _addResult('✅ Rate limits test completed');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testRealService() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🔍 Testing real-time data service...');

    try {
      final symbols = ['AAPL', 'GOOGL', 'MSFT'];

      for (final symbol in symbols) {
        _addResult('📈 Fetching $symbol...');
        final data = await _dataService.getStockData(symbol);

        if (data != null) {
          _addResult(
            '✅ $symbol: \$${data.currentPrice.toStringAsFixed(2)} (${data.changePercent.toStringAsFixed(2)}%)',
          );
        } else {
          _addResult('❌ $symbol: Failed to fetch data');
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      _addResult('✅ Real-time service test completed');
    } catch (e) {
      _addResult('💥 Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }
}
