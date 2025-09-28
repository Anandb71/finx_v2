// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../services/achievement_service.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Trading',
    'Wealth',
    'Strategy',
    'Learning',
  ];

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildAuroraBackground(),
          CustomScrollView(
            slivers: [
              _buildLiquidAppBar(),
              _buildFilterSection(),
              _buildAchievementsList(),
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
        return CustomPaint(
          size: Size.infinite,
          painter: AuroraPainter(_auroraController.value),
        );
      },
    );
  }

  Widget _buildLiquidAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.6),
                  const Color(0xFF0F3460).withOpacity(0.4),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Achievements',
                    style: LiquidTextStyle.headlineMedium(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your progress and unlock rewards',
                    style: LiquidTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LiquidCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Category',
                  style: LiquidTextStyle.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    itemBuilder: (context, index) {
                      final filter = _filterOptions[index];
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00FFA3),
                                      Color(0xFF00D4FF),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00FFA3)
                                  : Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: LiquidTextStyle.bodyMedium(context)
                                  .copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList() {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        final achievements = _getFilteredAchievements(achievementService);
        final unlockedCount = achievementService.unlockedAchievements.length;
        final totalCount = achievementService.allAchievements.length;
        final progressPercentage = totalCount > 0
            ? (unlockedCount / totalCount * 100).round()
            : 0;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Summary
                LiquidCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Unlocked',
                          unlockedCount.toString(),
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Total',
                          totalCount.toString(),
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Progress',
                          '$progressPercentage%',
                          Colors.orange,
                        ),
                        _buildStatItem(
                          'Points',
                          achievementService.totalPoints.toString(),
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Achievements Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = achievementService.isAchievementUnlocked(
                      achievement.id,
                    );
                    return _buildAchievementCard(achievement, isUnlocked);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Achievement> _getFilteredAchievements(AchievementService service) {
    final allAchievements = service.allAchievements;
    if (_selectedFilter == 'All') {
      return allAchievements;
    }
    return allAchievements.where((achievement) {
      return achievement.category.toLowerCase() ==
          _selectedFilter.toLowerCase();
    }).toList();
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: LiquidTextStyle.titleLarge(
            context,
          ).copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LiquidTextStyle.bodyMedium(
            context,
          ).copyWith(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
            ),
        child: LiquidCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF00FFA3).withOpacity(0.1),
                        const Color(0xFF00D4FF).withOpacity(0.1),
                      ],
                    )
                  : null,
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFF00FFA3)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    if (isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00FFA3),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  achievement.title,
                  style: LiquidTextStyle.titleMedium(context).copyWith(
                    color: isUnlocked ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  style: LiquidTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: Colors.white60, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          achievement.category,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement.category,
                        style: LiquidTextStyle.bodyMedium(context).copyWith(
                          color: _getCategoryColor(achievement.category),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${achievement.points} pts',
                      style: LiquidTextStyle.bodyMedium(context).copyWith(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trading':
        return Colors.green;
      case 'wealth':
        return Colors.blue;
      case 'strategy':
        return Colors.orange;
      case 'learning':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;

  AuroraPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0A1A).withOpacity(0.008),
          const Color(0xFF0D1B2A).withOpacity(0.012),
          const Color(0xFF0A1A2E).withOpacity(0.008),
        ],
        stops: [
          0.0 + (animationValue * 0.1),
          0.5 + (animationValue * 0.2),
          1.0 + (animationValue * 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
