// lib/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/leaderboard_entry.dart';
import '../services/enhanced_portfolio_provider.dart';
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _listAnimationController;
  late AnimationController _auroraController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _auroraController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _fadeController.forward();
    _listAnimationController.forward();
    _auroraController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listAnimationController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Aurora background
          _buildAuroraBackground(),
          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildLiquidAppBar(),
              _buildStatsSection(),
              _buildLeaderboardList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuroraBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  colorScheme.background,
                  colorScheme.primary.withOpacity(0.03),
                  _auroraController.value,
                )!,
                colorScheme.background,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiquidAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: LiquidMaterialTheme.darkSpaceBackground(
                context,
              ).withOpacity(0.5),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    color: LiquidMaterialTheme.neonAccent(context),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Leaderboard',
                    style: LiquidTextStyle.headlineMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<EnhancedPortfolioProvider>(
            builder: (context, portfolio, child) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Your Rank',
                      '#1',
                      Icons.emoji_events_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Your Score',
                      '\$${_getUserScore(portfolio).toStringAsFixed(0)}',
                      Icons.show_chart_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return LiquidCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: LiquidMaterialTheme.neonAccent(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: LiquidTextStyle.titleLarge(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: LiquidTextStyle.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _listAnimationController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: LiquidCard(
            child: Consumer<EnhancedPortfolioProvider>(
              builder: (context, portfolio, child) {
                final leaderboardData = _getLeaderboardData(portfolio);
                return Column(
                  children: List.generate(
                    leaderboardData.length,
                    (index) => _buildLeaderboardItem(
                      leaderboardData[index],
                      index + 1,
                      isLast: index == leaderboardData.length - 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    LeaderboardEntry entry,
    int rank, {
    bool isLast = false,
  }) {
    final isCurrentUser = entry.isCurrentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
        color: isCurrentUser
            ? LiquidMaterialTheme.neonAccent(context).withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('#$rank', style: LiquidTextStyle.titleMedium(context)),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  LiquidMaterialTheme.neonAccent(context),
                  LiquidMaterialTheme.neonAccent(context).withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Text(
                entry.name.substring(0, 1).toUpperCase(),
                style: LiquidTextStyle.titleLarge(context).copyWith(
                  color: LiquidMaterialTheme.darkSpaceBackground(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: LiquidTextStyle.titleMedium(context)),
                Text(
                  'Level ${entry.level}',
                  style: LiquidTextStyle.bodyMedium(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${entry.value.toStringAsFixed(0)}',
                style: LiquidTextStyle.titleMedium(
                  context,
                ).copyWith(color: LiquidMaterialTheme.neonAccent(context)),
              ),
              Text(
                '${entry.change >= 0 ? '+' : ''}${entry.change.toStringAsFixed(1)}%',
                style: LiquidTextStyle.bodyMedium(context).copyWith(
                  color: entry.change >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<LeaderboardEntry> _getLeaderboardData(
    EnhancedPortfolioProvider portfolio,
  ) {
    return [
      LeaderboardEntry(
        name: 'You',
        level: portfolio.userLevel,
        value: portfolio.totalValue,
        change: portfolio.dayGainPercent,
        isCurrentUser: true,
      ),
      // Add mock data for other players
      LeaderboardEntry(
        name: 'Alex',
        level: 15,
        value: 95200,
        change: 1.5,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        name: 'BetaTrader',
        level: 12,
        value: 88750,
        change: -0.8,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        name: 'CryptoKate',
        level: 11,
        value: 85100,
        change: 2.1,
        isCurrentUser: false,
      ),
    ];
  }

  double _getUserScore(EnhancedPortfolioProvider portfolio) {
    return portfolio.totalValue;
  }
}
