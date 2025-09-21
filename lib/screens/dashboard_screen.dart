import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'trade_screen.dart';
import 'analytics_screen.dart';
import 'learn_screen.dart';
import 'leaderboard_screen.dart';
import 'quests_screen.dart';
import 'achievements_screen.dart';

// Data models
class Quest {
  final int id;
  final String title;
  final String icon;
  final bool isCompleted;
  final double progress;

  Quest({
    required this.id,
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.progress,
  });
}

class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });
}

class Achievement {
  final String name;
  final String icon;
  final bool isEarned;

  Achievement({required this.name, required this.icon, required this.isEarned});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // User data
  UserModel? _userData;
  bool _isLoading = true;

  // Mock data for demonstration (will be replaced with real data)
  final double portfolioValue = 102500.00;
  final double dailyChange = 2500.00;
  final double dailyChangePercent = 2.5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  // Mock quest data
  final List<Quest> dailyQuests = [
    Quest(
      id: 1,
      title: "Read an article in the Learn section",
      icon: "💡",
      isCompleted: false,
      progress: 0.0,
    ),
    Quest(
      id: 2,
      title: "Add a tech stock to your watchlist",
      icon: "📈",
      isCompleted: false,
      progress: 0.0,
    ),
    Quest(
      id: 3,
      title: "Perform your first trade",
      icon: "💰",
      isCompleted: true,
      progress: 1.0,
    ),
  ];

  // Mock watchlist data
  final List<Stock> watchlist = [
    Stock(
      symbol: "AAPL",
      name: "Apple Inc.",
      price: 175.43,
      change: 2.34,
      changePercent: 1.35,
    ),
    Stock(
      symbol: "TSLA",
      name: "Tesla Inc.",
      price: 248.50,
      change: -5.20,
      changePercent: -2.05,
    ),
    Stock(
      symbol: "GOOGL",
      name: "Alphabet Inc.",
      price: 142.56,
      change: 1.23,
      changePercent: 0.87,
    ),
    Stock(
      symbol: "MSFT",
      name: "Microsoft Corp.",
      price: 378.85,
      change: 3.45,
      changePercent: 0.92,
    ),
  ];

  // Mock achievements
  final List<Achievement> achievements = [
    Achievement(name: "First Trade", icon: "🎯", isEarned: true),
    Achievement(name: "Portfolio Pro", icon: "💼", isEarned: true),
    Achievement(name: "Tech Investor", icon: "💻", isEarned: false),
    Achievement(name: "Diversifier", icon: "🌐", isEarned: true),
  ];

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching user data
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0F23),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
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

                  // Portfolio Overview Card
                  Container(
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
                                color: const Color(0xFF00FFA3).withOpacity(0.1),
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
                        Text(
                          '\$${portfolioValue.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FFA3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              dailyChange >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: dailyChange >= 0
                                  ? const Color(0xFF00FFA3)
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dailyChange >= 0 ? '+' : ''}\$${dailyChange.abs().toStringAsFixed(2)} (${dailyChangePercent >= 0 ? '+' : ''}${dailyChangePercent.toStringAsFixed(1)}%)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: dailyChange >= 0
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

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDynamicActionCard(
                                  icon: Icons.trending_up,
                                  title: 'Trade',
                                  subtitle: 'Your top mover: TSLA +7.1%',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TradeScreen(),
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
                                  subtitle: 'Portfolio up 2.5% today',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AnalyticsScreen(),
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
                                  subtitle: 'Next lesson: What is an ETF?',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LearnScreen(),
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
                                  subtitle: 'Your Rank: #125 ▲',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LeaderboardScreen(),
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
                  ),
                  const SizedBox(height: 16),

                  // My Achievements Section
                  _buildAchievementsSection(),

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Quests',
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
                    builder: (context) => const QuestsScreen(),
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
        ...dailyQuests.map((quest) => _buildQuestCard(quest)).toList(),
      ],
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen size
        final isDesktop = MediaQuery.of(context).size.width > 768;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: quest.isCompleted
                ? const Color(0xFF00FFA3).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: quest.isCompleted
                  ? const Color(0xFF00FFA3).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                quest.icon, 
                style: TextStyle(fontSize: isDesktop ? 24 : 20)
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quest.title,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: quest.isCompleted
                            ? const Color(0xFF00FFA3)
                            : Colors.white,
                      ),
                    ),
                    if (!quest.isCompleted) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: quest.progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00FFA3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (quest.isCompleted)
                Icon(
                  Icons.check_circle, 
                  color: const Color(0xFF00FFA3), 
                  size: isDesktop ? 20 : 16
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketMoversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Movers',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final stock = watchlist[index];
              return _buildStockCard(stock);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(Stock stock) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen size
        final isDesktop = MediaQuery.of(context).size.width > 768;
        final cardWidth = isDesktop ? 140.0 : 110.0; // Reduced mobile width
        final cardHeight = isDesktop ? 90.0 : 75.0; // Reduced mobile height
        
        return Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stock.symbol,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 16 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  stock.name,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 12 : 9,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '\$${stock.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stock.change >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: isDesktop ? 12 : 8,
                          color: stock.change >= 0 ? const Color(0xFF00FFA3) : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${stock.change >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: isDesktop ? 12 : 9,
                            color: stock.change >= 0
                                ? const Color(0xFF00FFA3)
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementsSection() {
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements
                .map((achievement) => _buildAchievementBadge(achievement))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen size
        final isDesktop = MediaQuery.of(context).size.width > 768;
        final badgeWidth = isDesktop ? 90.0 : 80.0;
        final badgeHeight = isDesktop ? 60.0 : 50.0;
        
        return Container(
          margin: const EdgeInsets.only(right: 12),
          width: badgeWidth,
          height: badgeHeight,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: achievement.isEarned
                ? const Color(0xFF00FFA3).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement.isEarned
                  ? const Color(0xFF00FFA3).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 16,
                  color: achievement.isEarned
                      ? const Color(0xFF00FFA3)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  achievement.name,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 10 : 8,
                    fontWeight: FontWeight.w500,
                    color: achievement.isEarned
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
      height: 40,
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
