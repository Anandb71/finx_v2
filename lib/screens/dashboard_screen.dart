import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
// import '../services/stock_service.dart'; // Replaced with real-time API
import '../services/portfolio_provider.dart';
import '../services/real_time_data_service.dart';
import '../models/achievement.dart';
import '../widgets/modern_stock_card.dart';
import 'modern_trade_screen.dart';
import 'portfolio_screen.dart';
import 'analytics_screen.dart';
import 'learn_screen.dart';
import 'leaderboard_screen.dart';
import 'quests_screen.dart';
import 'achievements_screen.dart';
// import 'ai_mentor_screen.dart'; // Available for future use
import 'api_test_screen.dart';
import 'functionality_test_screen.dart';
import 'settings_screen.dart';
import '../services/mascot_manager_service.dart';
import '../services/dynamic_quest_generator.dart';

// Data models
class Quest {
  final int id;
  final String title;
  final String icon;
  bool isCompleted;
  final double progress;

  Quest({
    required this.id,
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.progress,
  });
}

// Achievement class is now imported from ../models/achievement.dart

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // User data
  UserModel? _userData;
  bool _isLoading = true;
  // final StockService _stockService = StockService(); // Replaced with real-time API

  // Stock data - now using StreamBuilder, no need for state variables

  // Mock data for demonstration (will be replaced with real data)
  final double portfolioValue = 102500.00;
  final double dailyChange = 2500.00;
  final double dailyChangePercent = 2.5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeRealTimeUpdates();
    _generateDynamicQuests();
  }

  void _initializeRealTimeUpdates() {
    // Initialize real-time portfolio updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final portfolio = context.read<PortfolioProvider>();
      portfolio.initializeRealTimeUpdates();
    });
  }

  Future<void> _generateDynamicQuests() async {
    if (_questsGenerated) return;

    try {
      final portfolio = context.read<PortfolioProvider>();

      // Generate personalized quests based on user's portfolio
      final dynamicQuests =
          await DynamicQuestGenerator.generatePersonalizedQuests(
            holdings: portfolio.holdings,
            virtualCash: portfolio.virtualCash,
            totalPortfolioValue: portfolio.totalPortfolioValue,
            userLevel: portfolio.userLevel,
            totalTrades: portfolio.totalTrades,
            transactionHistory: portfolio.transactionHistory
                .map(
                  (t) => {
                    'symbol': t.symbol,
                    'quantity': t.quantity,
                    'price': t.price,
                    'type': t.type.name,
                    'timestamp': t.timestamp.toIso8601String(),
                  },
                )
                .toList(),
            currentPrices: portfolio.currentPrices,
          );

      // Convert Challenge objects to Quest objects for the UI
      dailyQuests = dynamicQuests
          .map(
            (challenge) => Quest(
              id: challenge.id.hashCode,
              title: challenge.title,
              icon: challenge.icon ?? '🎯',
              isCompleted: challenge.isCompleted,
              progress: challenge.completionPercentage,
            ),
          )
          .toList();

      _questsGenerated = true;

      if (mounted) {
        setState(() {});
      }

      print('🎯 Generated ${dailyQuests.length} personalized quests');
    } catch (e) {
      print('Error generating dynamic quests: $e');
      // Fallback to basic quests
      _generateFallbackQuests();
    }
  }

  void _generateFallbackQuests() {
    dailyQuests = [
      Quest(
        id: 1,
        title: "Make your first trade",
        icon: "💰",
        isCompleted: false,
        progress: 0.0,
      ),
      Quest(
        id: 2,
        title: "Earn 100 XP",
        icon: "⭐",
        isCompleted: false,
        progress: 0.0,
      ),
      Quest(
        id: 3,
        title: "Complete 3 trades",
        icon: "📈",
        isCompleted: false,
        progress: 0.0,
      ),
      Quest(
        id: 4,
        title: "Diversify your portfolio",
        icon: "🌐",
        isCompleted: false,
        progress: 0.0,
      ),
    ];
    _questsGenerated = true;
  }

  Future<void> _loadUserData() async {
    // For now, skip Firebase loading since user data is empty
    // This allows the app to work with local portfolio data only
    print('Skipping Firebase user data loading for trial run');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // TODO: Re-enable Firebase loading when user data is available
    /*
    try {
      // Get full user data for all features
      final userData = await _userService.getCurrentUserData();

      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');

      // If user document doesn't exist, try to create it
      if (e.toString().contains('User document does not exist')) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('Creating missing user document...');
            await _userService.createUserOnSignUp(
              user.uid,
              user.email ?? 'unknown@example.com',
              displayName: user.displayName,
            );

            // Try to load user data again
            final userData = await _userService.getCurrentUserData();
            if (mounted) {
              setState(() {
                _userData = userData;
                _isLoading = false;
              });
            }
            return;
          }
        } catch (createError) {
          print('Error creating missing user document: $createError');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    */
  }

  // Get user display name from Firestore data or fallback to Auth
  String get displayName {
    if (_userData != null) {
      return _userData!.fullDisplayName;
    }

    // Fallback to Firebase Auth data
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return "Trader";
  }

  // Get user avatar initial
  String get avatarInitial {
    if (_userData != null) {
      return _userData!.firstNameForAvatar;
    }

    // Fallback to Firebase Auth data
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName![0].toUpperCase();
    } else if (user?.email != null) {
      return user!.email![0].toUpperCase();
    }
    return "T";
  }

  // Mock sparkline data (in a real app, this would come from your portfolio history)
  final List<double> sparklineData = [
    100000,
    100500,
    101200,
    100800,
    101500,
    102000,
    102500,
  ];

  // Dynamic quests will be generated based on user's portfolio
  List<Quest> dailyQuests = [];
  bool _questsGenerated = false;

  // Achievements are now fetched from PortfolioProvider

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching user data
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFA3)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Finx Dashboard',
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          Consumer<PortfolioProvider>(
            builder: (context, portfolio, child) {
              return IconButton(
                onPressed: () {
                  portfolio.toggleRealTimeUpdates();
                },
                icon: Icon(
                  portfolio.isRealTimeEnabled ? Icons.wifi : Icons.wifi_off,
                  color: portfolio.isRealTimeEnabled
                      ? Colors.green
                      : Colors.grey,
                ),
                tooltip: portfolio.isRealTimeEnabled
                    ? 'Disable Real-time Updates'
                    : 'Enable Real-time Updates',
              );
            },
          ),
          // Global Refresh Button
          GestureDetector(
            onTap: () {
              setState(() {
                // This will trigger a rebuild and refresh all data
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00FFA3).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.refresh,
                color: const Color(0xFF00FFA3),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $displayName!',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Ready to make some smart moves?',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      // User Avatar with Initials
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFA3).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            avatarInitial,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Player Status Card
                  Consumer<PortfolioProvider>(
                    builder: (context, portfolio, child) {
                      return _buildPlayerStatusCard(portfolio, displayName);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Portfolio Overview Card
                  Consumer<PortfolioProvider>(
                    builder: (context, portfolio, child) {
                      final totalValue = portfolio.totalPortfolioValue;
                      final gainLoss = portfolio.totalGainLoss;
                      final gainLossPercent = portfolio.totalGainLossPercentage;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PortfolioScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00FFA3).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00FFA3,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Color(0xFF00FFA3),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Portfolio Value',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$${totalValue.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00FFA3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Consumer<PortfolioProvider>(
                                    builder: (context, portfolio, child) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: portfolio.isRealTimeEnabled
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: portfolio.isRealTimeEnabled
                                                ? Colors.green
                                                : Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.wifi,
                                              size: 12,
                                              color: portfolio.isRealTimeEnabled
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'LIVE',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    portfolio.isRealTimeEnabled
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    gainLoss >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: gainLoss >= 0
                                        ? const Color(0xFF00FFA3)
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${gainLoss >= 0 ? '+' : ''}\$${gainLoss.abs().toStringAsFixed(2)} (${gainLossPercent >= 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%)',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: gainLoss >= 0
                                          ? const Color(0xFF00FFA3)
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Mini Sparkline Chart
                              _buildSparklineChart(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Daily Quests Section
                  _buildDailyQuestsSection(),
                  const SizedBox(height: 16),

                  // Market Movers Section
                  _buildMarketMoversSection(),
                  const SizedBox(height: 16),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Consumer<PortfolioProvider>(
                    builder: (context, portfolio, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.trending_up,
                                      title: 'Trade',
                                      subtitle: _getTopMoverText(),
                                      onTap: () {
                                        // This will be replaced with actual stock data
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ModernTradeScreen(
                                                  stockData: {
                                                    'symbol': 'TSLA',
                                                    'name': 'Tesla Inc.',
                                                    'currentPrice': 248.50,
                                                    'changePercent': 7.1,
                                                  },
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.analytics,
                                      title: 'Analytics',
                                      subtitle: _getPortfolioChangeText(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AnalyticsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.school,
                                      title: 'Learn',
                                      subtitle: _getNextLessonText(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LearnScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.leaderboard,
                                      title: 'Leaderboard',
                                      subtitle: _getLeaderboardRankText(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LeaderboardScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.account_balance_wallet,
                                      title: 'Portfolio',
                                      subtitle: _getPortfolioSummaryText(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PortfolioScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.emoji_events,
                                      title: 'Achievements',
                                      subtitle: _getAchievementsText(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AchievementsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.api,
                                      title: 'API Test',
                                      subtitle: 'Test Finnhub integration',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ApiTestScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.bug_report,
                                      title: 'Functionality Test',
                                      subtitle: 'Test all app features',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const FunctionalityTestScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDynamicActionCard(
                                      icon: Icons.settings,
                                      title: 'Settings',
                                      subtitle: 'Customize your experience',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SettingsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // My Achievements Section
                  _buildAchievementsSection(),

                  const SizedBox(height: 16),

                  // Mascot of the Day
                  _buildMascotOfTheDay(),

                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestsSection() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        final completedQuests = dailyQuests.where((q) => q.isCompleted).length;
        final totalQuests = dailyQuests.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Quests',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$completedQuests of $totalQuests completed',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuestsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00FFA3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF00FFA3),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dailyQuests
                .map((quest) => _buildQuestCard(quest, portfolio))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildMascotOfTheDay() {
    final mascotOfTheDay = MascotManagerService.getMascotOfTheDay();
    final dailyTip = MascotManagerService.getDailyTip(mascotOfTheDay);

    return MascotManagerService.buildMascotOfTheDay(
      mascot: mascotOfTheDay,
      tip: dailyTip,
      onTap: () {
        // Show AI-based portfolio advice instead of generic tip
        _showPortfolioAdvice();
      },
    );
  }

  void _showPortfolioAdvice() {
    // Get current portfolio data
    final portfolio = context.read<PortfolioProvider>();
    final portfolioData = {
      'virtualCash': portfolio.virtualCash,
      'holdings': portfolio.holdings,
      'totalValue': portfolio.totalValue,
    };

    // Get AI-based advice
    final advice = MascotManagerService.getPortfolioAdvice(portfolioData);

    // Show as bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PortfolioAdviceWidget(advice: advice),
    );
  }

  Widget _buildQuestCard(Quest quest, PortfolioProvider portfolio) {
    // Calculate real quest progress based on portfolio data
    double progress = _calculateQuestProgress(quest, portfolio);
    bool isCompleted = quest.isCompleted;

    // Check if quest was just completed
    if (progress >= 1.0 && !isCompleted) {
      quest.isCompleted = true;
      print('🎉 Quest completed: ${quest.title}');
      // Note: Quest completion mascot popup is handled by the trade screen
      // to avoid duplicate popups when trading
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(
                  colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF00FFA3).withOpacity(0.8)
                : Colors.white.withOpacity(0.15),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? const Color(0xFF00FFA3).withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isCompleted ? 12 : 6,
              spreadRadius: isCompleted ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quest icon with background
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF00FFA3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: isCompleted
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                    : null,
              ),
              child: Center(
                child: Text(quest.icon, style: const TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 6),

            // Quest content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.white : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  if (!isCompleted) ...[
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00FFA3),
                            ),
                            minHeight: 2,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'COMPLETED!',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketMoversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: const Color(0xFF00FFA3), size: 24),
            const SizedBox(width: 12),
            Text(
              'Market Movers',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Refresh Button
            GestureDetector(
              onTap: () {
                setState(() {
                  // This will trigger a rebuild and refresh the data
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.refresh,
                  color: const Color(0xFF00FFA3),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00FFA3).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Live',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FFA3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 300, // Increased height for bigger cards with bigger graphs
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: _buildRealTimeMarketMovers(),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        final recentAchievements = portfolio.recentAchievements
            .take(4)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Achievements',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF00FFA3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentAchievements.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentAchievements
                      .map((achievement) => _buildAchievementBadge(achievement))
                      .toList(),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Complete trades to earn achievements!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen size
        final isDesktop = MediaQuery.of(context).size.width > 768;
        final badgeWidth = isDesktop ? 110.0 : 95.0;
        final badgeHeight = isDesktop ? 75.0 : 65.0;

        return Container(
          margin: const EdgeInsets.only(right: 12),
          width: badgeWidth,
          height: badgeHeight,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? const Color(0xFF00FFA3).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement.isUnlocked
                  ? const Color(0xFF00FFA3).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getAchievementIcon(achievement.title),
                size: isDesktop ? 24 : 20,
                color: achievement.isUnlocked
                    ? const Color(0xFF00FFA3)
                    : Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  achievement.title,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 12 : 10,
                    fontWeight: FontWeight.w500,
                    color: achievement.isUnlocked
                        ? const Color(0xFF00FFA3)
                        : Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAchievementIcon(String achievementName) {
    switch (achievementName.toLowerCase()) {
      case 'first trade':
        return Icons.trending_up;
      case 'portfolio pro':
        return Icons.account_balance_wallet;
      case 'tech investor':
        return Icons.computer;
      case 'diversifier':
        return Icons.public;
      case 'risk taker':
        return Icons.warning;
      case 'conservative':
        return Icons.shield;
      case 'day trader':
        return Icons.schedule;
      case 'long term investor':
        return Icons.timeline;
      default:
        return Icons.emoji_events;
    }
  }

  double _calculateQuestProgress(Quest quest, PortfolioProvider portfolio) {
    double progress = 0.0;

    // Handle dynamic quests based on their objectives
    final title = quest.title.toLowerCase();

    if (title.contains('first trade') ||
        title.contains('make') && title.contains('trade')) {
      progress = portfolio.totalTrades > 0 ? 1.0 : 0.0;
    } else if (title.contains('earn') && title.contains('xp')) {
      // Extract XP amount from quest title
      final xpMatch = RegExp(r'(\d+)').firstMatch(quest.title);
      if (xpMatch != null) {
        final targetXp = int.parse(xpMatch.group(1)!);
        progress = (portfolio.userXp / targetXp).clamp(0.0, 1.0);
      } else {
        progress = (portfolio.userXp / 100).clamp(0.0, 1.0);
      }
    } else if (title.contains('complete') && title.contains('trade')) {
      // Extract number of trades from quest title
      final tradeMatch = RegExp(r'(\d+)').firstMatch(quest.title);
      if (tradeMatch != null) {
        final targetTrades = int.parse(tradeMatch.group(1)!);
        progress = (portfolio.totalTrades / targetTrades).clamp(0.0, 1.0);
      } else {
        progress = (portfolio.totalTrades / 3).clamp(0.0, 1.0);
      }
    } else if (title.contains('diversify') || title.contains('sector')) {
      // Check if user has stocks from different sectors
      final sectors = _getPortfolioSectors(portfolio.holdings);
      progress = (sectors.length / 2).clamp(0.0, 1.0);
    } else if (title.contains('risk') || title.contains('concentration')) {
      // Check portfolio concentration
      final concentration = _calculatePortfolioConcentration(portfolio);
      progress = concentration > 0.3 ? 0.0 : 1.0;
    } else if (title.contains('level')) {
      // Extract level from quest title
      final levelMatch = RegExp(r'level (\d+)').firstMatch(quest.title);
      if (levelMatch != null) {
        final targetLevel = int.parse(levelMatch.group(1)!);
        progress = portfolio.userLevel >= targetLevel ? 1.0 : 0.0;
      }
    } else if (title.contains('read') && title.contains('article')) {
      // Learning quests - for now, return 0 as we don't track this yet
      progress = 0.0;
    } else {
      // Fallback to basic progress calculation
      progress = quest.progress;
    }

    print(
      '🔍 Quest Progress: "${quest.title}" = ${(progress * 100).toInt()}% (trades: ${portfolio.totalTrades}, xp: ${portfolio.userXp}, level: ${portfolio.userLevel})',
    );

    return progress;
  }

  List<String> _getPortfolioSectors(Map<String, int> holdings) {
    final sectorMapping = {
      'AAPL': 'Technology',
      'MSFT': 'Technology',
      'GOOGL': 'Technology',
      'META': 'Technology',
      'NVDA': 'Technology',
      'AMD': 'Technology',
      'INTC': 'Technology',
      'TSLA': 'Automotive',
      'AMZN': 'Consumer Discretionary',
      'NFLX': 'Communication Services',
      'JPM': 'Financial',
      'JNJ': 'Healthcare',
      'PG': 'Consumer Staples',
      'KO': 'Consumer Staples',
      'WMT': 'Consumer Staples',
      'XOM': 'Energy',
      'CVX': 'Energy',
    };

    final sectors = <String>{};
    for (final symbol in holdings.keys) {
      final sector = sectorMapping[symbol] ?? 'Other';
      sectors.add(sector);
    }
    return sectors.toList();
  }

  double _calculatePortfolioConcentration(PortfolioProvider portfolio) {
    if (portfolio.holdings.isEmpty) return 0.0;

    double totalValue = portfolio.totalPortfolioValue;
    if (totalValue == 0) return 0.0;

    double maxValue = 0.0;
    for (final entry in portfolio.holdings.entries) {
      final symbol = entry.key;
      final quantity = entry.value;
      final price = portfolio.currentPrices[symbol] ?? 0.0;
      final value = quantity * price;
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return maxValue / totalValue;
  }

  // Real-time Market Movers using Finnhub API
  Widget _buildRealTimeMarketMovers() {
    final realTimeService = RealTimeDataService();
    final watchlistSymbols = [
      'AAPL',
      'GOOGL',
      'MSFT',
      'TSLA',
      'AMZN',
      'NVDA',
      'META',
      'NFLX',
      'AMD',
      'INTC',
    ];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMultipleStocks(realTimeService, watchlistSymbols),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFA3)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.withOpacity(0.7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading live data',
                  style: GoogleFonts.inter(
                    color: Colors.red.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Using cached data...',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No live data available',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }

        final stocks = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width > 768;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stockData = stocks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ModernStockCard(
                  stockData: stockData,
                  isDesktop: isDesktop,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ModernTradeScreen(stockData: stockData),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Fetch multiple stocks from API
  Future<List<Map<String, dynamic>>> _fetchMultipleStocks(
    RealTimeDataService service,
    List<String> symbols,
  ) async {
    final List<Map<String, dynamic>> stocks = [];

    for (final symbol in symbols) {
      try {
        final stockData = await service.getStockData(symbol);
        if (stockData != null) {
          stocks.add({
            'symbol': stockData.symbol,
            'name': stockData.name,
            'currentPrice': stockData.currentPrice,
            'change': stockData.change,
            'changePercent': stockData.changePercent,
            'volume': stockData.volume,
            'high': stockData.high,
            'low': stockData.low,
            'open': stockData.open,
            'priceHistory': _generatePriceHistory(stockData.currentPrice),
          });
        }
      } catch (e) {
        print('Error fetching $symbol: $e');
      }
    }

    // Sort by change percentage (biggest movers first)
    stocks.sort(
      (a, b) => (b['changePercent'] as double).compareTo(
        a['changePercent'] as double,
      ),
    );

    return stocks;
  }

  // Generate mock price history for sparkline
  List<double> _generatePriceHistory(double currentPrice) {
    final random = Random();
    final history = <double>[];
    double price = currentPrice;

    for (int i = 0; i < 20; i++) {
      price +=
          (random.nextDouble() - 0.5) * currentPrice * 0.02; // ±1% variation
      history.add(price);
    }

    return history;
  }

  Widget _buildDynamicActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF00FFA3), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF00FFA3),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparklineChart() {
    if (sparklineData.isEmpty) return const SizedBox.shrink();

    final minValue = sparklineData.reduce((a, b) => a < b ? a : b);
    final maxValue = sparklineData.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 60,
      width: double.infinity,
      child: CustomPaint(
        painter: SparklinePainter(
          data: sparklineData,
          minValue: minValue,
          maxValue: maxValue,
          color: dailyChange >= 0 ? const Color(0xFF00FFA3) : Colors.red,
        ),
      ),
    );
  }

  Widget _buildPlayerStatusCard(
    PortfolioProvider portfolio,
    String displayName,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Status',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$displayName • Level ${portfolio.userLevel}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  portfolio.getLevelTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FFA3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience Points',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${portfolio.userXp} / ${portfolio.xpForNextLevel} XP',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(portfolio.xpProgress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FFA3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: portfolio.xpProgress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic subtext helper methods
  String _getTopMoverText() {
    final portfolio = context.read<PortfolioProvider>();
    if (portfolio.holdings.isEmpty) {
      return 'Start trading to see movers';
    }

    // Find the stock with highest gain
    String topMover = '';
    double maxGain = double.negativeInfinity;

    for (final entry in portfolio.holdings.entries) {
      final symbol = entry.key;
      final shares = entry.value;
      final currentPrice = portfolio.currentPrices[symbol] ?? 0.0;
      if (currentPrice > 0 && shares > 0) {
        // Calculate gain percentage (simplified - using current price vs a base price)
        final gain =
            (currentPrice - 100.0) / 100.0 * 100; // Assuming base price of $100
        if (gain > maxGain) {
          maxGain = gain;
          topMover = symbol;
        }
      }
    }

    if (topMover.isNotEmpty) {
      final gainText = maxGain >= 0
          ? '+${maxGain.toStringAsFixed(1)}%'
          : '${maxGain.toStringAsFixed(1)}%';
      return 'Top mover: $topMover $gainText';
    }

    return 'No active positions';
  }

  String _getPortfolioChangeText() {
    final portfolio = context.read<PortfolioProvider>();
    final changePercent = portfolio.totalGainLossPercentage;
    final changeText = changePercent >= 0
        ? '+${changePercent.toStringAsFixed(1)}%'
        : '${changePercent.toStringAsFixed(1)}%';
    final direction = changePercent >= 0 ? '▲' : '▼';
    return 'Portfolio $changeText $direction';
  }

  String _getNextLessonText() {
    // Simple lesson progression based on user level
    final portfolio = context.read<PortfolioProvider>();
    final level = portfolio.userLevel;

    if (level <= 2) {
      return 'Next: What is an ETF?';
    } else if (level <= 5) {
      return 'Next: Risk management';
    } else if (level <= 10) {
      return 'Next: Technical analysis';
    } else {
      return 'Next: Advanced strategies';
    }
  }

  String _getLeaderboardRankText() {
    // Since we only have 1 user, they're always #1
    return 'Your Rank: #1 🏆';
  }

  String _getPortfolioSummaryText() {
    final portfolio = context.read<PortfolioProvider>();
    final holdingsCount = portfolio.holdings.length;
    if (holdingsCount == 0) {
      return 'No holdings yet';
    } else if (holdingsCount == 1) {
      return '1 holding';
    } else {
      return '$holdingsCount holdings';
    }
  }

  String _getAchievementsText() {
    final portfolio = context.read<PortfolioProvider>();
    final level = portfolio.userLevel;
    final xp = portfolio.userXp;

    // Simple achievement count based on level and XP
    int achievements = 0;
    if (level >= 2) achievements++;
    if (level >= 5) achievements++;
    if (level >= 10) achievements++;
    if (xp >= 1000) achievements++;
    if (xp >= 5000) achievements++;
    if (portfolio.transactionHistory.length >= 10) achievements++;

    if (achievements == 0) {
      return 'Start earning badges';
    } else if (achievements == 1) {
      return '1 badge earned';
    } else {
      return '$achievements badges earned';
    }
  }
}

class _PortfolioAdviceWidget extends StatefulWidget {
  final MascotMessage advice;

  const _PortfolioAdviceWidget({required this.advice});

  @override
  State<_PortfolioAdviceWidget> createState() => _PortfolioAdviceWidgetState();
}

class _PortfolioAdviceWidgetState extends State<_PortfolioAdviceWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 200 * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.advice.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.advice.backgroundColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      // Mascot Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            MascotManagerService.getMascotImage(
                              widget.advice.mascot,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.pets,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.advice.emoji} ${MascotManagerService.getMascotName(widget.advice.mascot)}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Portfolio Analysis',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      GestureDetector(
                        onTap: () {
                          _animationController.reverse().then((_) {
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Advice message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.advice.message,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _animationController.reverse().then((_) {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: widget.advice.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        'Got it!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final double minValue;
  final double maxValue;
  final Color color;

  SparklinePainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path()..addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
