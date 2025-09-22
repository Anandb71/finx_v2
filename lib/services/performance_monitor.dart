import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _performanceHistory = {};
  final Map<String, int> _errorCounts = {};
  final Map<String, int> _apiCallCounts = {};

  // Performance tracking
  void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
    if (kDebugMode) {
      developer.log('Started timer for: $operation');
    }
  }

  void endTimer(String operation) {
    final timer = _timers.remove(operation);
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;

      _performanceHistory.putIfAbsent(operation, () => []);
      _performanceHistory[operation]!.add(duration);

      // Keep only last 100 measurements
      if (_performanceHistory[operation]!.length > 100) {
        _performanceHistory[operation]!.removeAt(0);
      }

      if (kDebugMode) {
        developer.log('$operation completed in: ${duration.inMilliseconds}ms');
      }
    }
  }

  Duration? getAverageTime(String operation) {
    final history = _performanceHistory[operation];
    if (history == null || history.isEmpty) return null;

    final totalMs = history.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ history.length);
  }

  // Error tracking
  void recordError(String operation, String error) {
    _errorCounts[operation] = (_errorCounts[operation] ?? 0) + 1;
    if (kDebugMode) {
      developer.log('Error in $operation: $error', level: 1000);
    }
  }

  int getErrorCount(String operation) => _errorCounts[operation] ?? 0;

  // API call tracking
  void recordApiCall(String endpoint) {
    _apiCallCounts[endpoint] = (_apiCallCounts[endpoint] ?? 0) + 1;
  }

  int getApiCallCount(String endpoint) => _apiCallCounts[endpoint] ?? 0;

  // Performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final summary = <String, dynamic>{};

    for (final operation in _performanceHistory.keys) {
      final avgTime = getAverageTime(operation);
      final errorCount = getErrorCount(operation);

      summary[operation] = {
        'averageTime': avgTime?.inMilliseconds,
        'errorCount': errorCount,
        'totalCalls': _performanceHistory[operation]?.length ?? 0,
      };
    }

    return summary;
  }

  // Memory usage monitoring
  void logMemoryUsage(String context) {
    if (kDebugMode) {
      developer.log('Memory usage at $context: ${_getMemoryUsage()}');
    }
  }

  String _getMemoryUsage() {
    // This is a simplified version - in a real app you'd use proper memory profiling
    return 'Memory monitoring not available in debug mode';
  }

  // Clear old data
  void clearOldData() {
    // Implementation would depend on your data structure
    // This is a placeholder for clearing old performance data
    // In a real implementation, you'd filter out data older than 24 hours
  }
}
