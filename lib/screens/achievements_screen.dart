// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../services/enhanced_portfolio_provider.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _auroraController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Trading',
    'Learning',
    'Social',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _auroraController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );

    _headerAnimationController.forward();
    _cardAnimationController.forward();
    _auroraController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
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
                    Icons.emoji_events_outlined,
                    color: LiquidMaterialTheme.neonAccent(context),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Achievements',
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
        opacity: _headerAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<EnhancedPortfolioProvider>(
            builder: (context, portfolio, child) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Unlocked',
                      '${_getUnlockedCount()}',
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      '${_getTotalCount()}',
                      Icons.emoji_events_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Progress',
                      '${_getProgressPercentage()}%',
                      Icons.trending_up,
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

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LiquidMaterialTheme.neonAccent(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? LiquidMaterialTheme.neonAccent(context)
                            : Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: LiquidTextStyle.bodyMedium(context).copyWith(
                        color: isSelected
                            ? LiquidMaterialTheme.darkSpaceBackground(context)
                            : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final achievement = _getFilteredAchievements()[index];
          return FadeTransition(
            opacity: _cardAnimation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _cardAnimationController,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildAchievementCard(achievement),
              ),
            ),
          );
        }, childCount: _getFilteredAchievements().length),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return LiquidCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: achievement.isUnlocked
                      ? [
                          LiquidMaterialTheme.neonAccent(context),
                          LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.7),
                        ]
                      : [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: achievement.isUnlocked
                    ? [
                        BoxShadow(
                          color: LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: LiquidTextStyle.titleMedium(context).copyWith(
                      color: achievement.isUnlocked
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: LiquidTextStyle.bodyMedium(context).copyWith(
                      color: achievement.isUnlocked
                          ? Colors.white70
                          : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (achievement.isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${achievement.xpReward} XP',
                          style: LiquidTextStyle.labelSmall(
                            context,
                          ).copyWith(color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (achievement.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: LiquidMaterialTheme.neonAccent(
                    context,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'UNLOCKED',
                  style: LiquidTextStyle.labelSmall(context).copyWith(
                    color: LiquidMaterialTheme.neonAccent(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Achievement> _getFilteredAchievements() {
    final allAchievements = _getAllAchievements();
    if (_selectedFilter == 'All') {
      return allAchievements;
    }
    return allAchievements.where((achievement) {
      return achievement.type.name.toLowerCase() ==
          _selectedFilter.toLowerCase();
    }).toList();
  }

  List<Achievement> _getAllAchievements() {
    return [
      Achievement(
        id: '1',
        title: 'First Trade',
        description: 'Complete your first trade',
        icon: '📈',
        type: AchievementType.trading,
        rarity: AchievementRarity.common,
        xpReward: 100,
        requirements: ['Complete first trade'],
        isUnlocked: true,
      ),
      Achievement(
        id: '2',
        title: 'Portfolio Master',
        description: 'Reach \$100K portfolio value',
        icon: '💰',
        type: AchievementType.trading,
        rarity: AchievementRarity.rare,
        xpReward: 500,
        requirements: ['Reach \$100K portfolio value'],
        isUnlocked: false,
      ),
      Achievement(
        id: '3',
        title: 'Risk Taker',
        description: 'Make 10 high-risk trades',
        icon: '⚠️',
        type: AchievementType.trading,
        rarity: AchievementRarity.uncommon,
        xpReward: 300,
        requirements: ['Make 10 high-risk trades'],
        isUnlocked: false,
      ),
      Achievement(
        id: '4',
        title: 'Learning Champion',
        description: 'Complete 5 learning modules',
        icon: '🎓',
        type: AchievementType.learning,
        rarity: AchievementRarity.uncommon,
        xpReward: 200,
        requirements: ['Complete 5 learning modules'],
        isUnlocked: true,
      ),
      Achievement(
        id: '5',
        title: 'Social Butterfly',
        description: 'Share your first portfolio',
        icon: '📤',
        type: AchievementType.social,
        rarity: AchievementRarity.common,
        xpReward: 150,
        requirements: ['Share first portfolio'],
        isUnlocked: false,
      ),
      Achievement(
        id: '6',
        title: 'Special Achievement',
        description: 'Complete a special challenge',
        icon: '🏆',
        type: AchievementType.special,
        rarity: AchievementRarity.legendary,
        xpReward: 1000,
        requirements: ['Complete special challenge'],
        isUnlocked: false,
      ),
    ];
  }

  int _getUnlockedCount() {
    return _getAllAchievements()
        .where((achievement) => achievement.isUnlocked)
        .length;
  }

  int _getTotalCount() {
    return _getAllAchievements().length;
  }

  int _getProgressPercentage() {
    if (_getTotalCount() == 0) return 0;
    return ((_getUnlockedCount() / _getTotalCount()) * 100).round();
  }
}
