import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../test_functionality.dart';

class FunctionalityTestScreen extends StatefulWidget {
  const FunctionalityTestScreen({super.key});

  @override
  State<FunctionalityTestScreen> createState() =>
      _FunctionalityTestScreenState();
}

class _FunctionalityTestScreenState extends State<FunctionalityTestScreen> {
  Map<String, dynamic>? _testResults;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          'Functionality Test',
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
                'Comprehensive Functionality Test',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Testing all app functionalities and API integration',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Test Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runTests,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isRunning ? 'Running Tests...' : 'Run All Tests',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFA3),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Results
              if (_testResults != null) ...[
                Text(
                  'Test Results',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
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
                    child: ListView(
                      children: _testResults!.entries.map((entry) {
                        final testName = entry.key;
                        final result = entry.value as Map<String, dynamic>;
                        final isSuccess = result['success'] as bool;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSuccess
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSuccess
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: isSuccess
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatTestName(testName),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSuccess
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result['message'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              if (result.containsKey('data') &&
                                  result['data'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Data: ${result['data'].toString()}',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else if (!_isRunning) ...[
                Center(
                  child: Text(
                    'Click "Run All Tests" to start testing',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults = null;
    });

    try {
      final results = await FunctionalityTest.runComprehensiveTest();
      setState(() {
        _testResults = results;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'error': {'success': false, 'message': 'Test execution failed: $e'},
        };
        _isRunning = false;
      });
    }
  }

  String _formatTestName(String testName) {
    switch (testName) {
      case 'api_connection':
        return 'API Connection';
      case 'multiple_stocks':
        return 'Multiple Stocks';
      case 'rate_limiting':
        return 'Rate Limiting';
      case 'error_handling':
        return 'Error Handling';
      case 'data_validation':
        return 'Data Validation';
      default:
        return testName.replaceAll('_', ' ').toUpperCase();
    }
  }
}
