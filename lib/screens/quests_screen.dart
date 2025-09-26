// lib/screens/quests_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

// Quest model
class Quest {
  final int id;
  final String title;
  final String description;
  final String icon;
  final bool isCompleted;
  final double progress;
  final int xpReward;
  final String category;
  final DateTime? deadline;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.progress,
    required this.xpReward,
    required this.category,
    this.deadline,
  });
}

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _auroraController;
  late TabController _tabController;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _auroraController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
    _auroraController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _auroraController.dispose();
    _tabController.dispose();
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildLiquidAppBar(),
                _buildStatsSection(),
                _buildCategoryTabs(),
                _buildQuestsList(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
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
                    Icons.assignment_outlined,
                    color: LiquidMaterialTheme.neonAccent(context),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Daily Quests',
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active',
                '${_getActiveQuestsCount()}',
                Icons.play_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Completed',
                '${_getCompletedQuestsCount()}',
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'XP Earned',
                '${_getTotalXP()}',
                Icons.star,
              ),
            ),
          ],
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

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Daily', 'Weekly', 'Special'].map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
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
                      category,
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

  Widget _buildQuestsList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final quest = _getFilteredQuests()[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQuestCard(quest),
          );
        }, childCount: _getFilteredQuests().length),
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return LiquidCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: quest.isCompleted
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
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: quest.isCompleted
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
                      quest.icon,
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
                        quest.title,
                        style: LiquidTextStyle.titleMedium(context).copyWith(
                          color: quest.isCompleted
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: LiquidTextStyle.bodyMedium(context).copyWith(
                          color: quest.isCompleted
                              ? Colors.white60
                              : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (quest.isCompleted)
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
                      'DONE',
                      style: LiquidTextStyle.labelSmall(context).copyWith(
                        color: LiquidMaterialTheme.neonAccent(context),
                        fontWeight: FontWeight.bold,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: LiquidTextStyle.bodyMedium(
                              context,
                            ).copyWith(color: Colors.white70),
                          ),
                          Text(
                            '${(quest.progress * 100).toInt()}%',
                            style: LiquidTextStyle.bodyMedium(context).copyWith(
                              color: LiquidMaterialTheme.neonAccent(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quest.progress,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            LiquidMaterialTheme.neonAccent(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${quest.xpReward} XP',
                      style: LiquidTextStyle.labelSmall(context).copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Quest> _getFilteredQuests() {
    final allQuests = _getAllQuests();
    if (_selectedCategory == 'All') {
      return allQuests;
    }
    return allQuests.where((quest) {
      return quest.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  List<Quest> _getAllQuests() {
    return [
      Quest(
        id: 1,
        title: "Read an article in the Learn section",
        description: "Expand your knowledge by reading one educational article",
        icon: "💡",
        isCompleted: false,
        progress: 0.3,
        xpReward: 50,
        category: "Daily",
      ),
      Quest(
        id: 2,
        title: "Make your first trade",
        description: "Complete a buy or sell transaction",
        icon: "📈",
        isCompleted: true,
        progress: 1.0,
        xpReward: 100,
        category: "Daily",
      ),
      Quest(
        id: 3,
        title: "Check your portfolio",
        description: "View your portfolio performance",
        icon: "📊",
        isCompleted: false,
        progress: 0.0,
        xpReward: 25,
        category: "Daily",
      ),
      Quest(
        id: 4,
        title: "Complete 5 trades this week",
        description: "Make 5 successful trades within 7 days",
        icon: "🎯",
        isCompleted: false,
        progress: 0.6,
        xpReward: 200,
        category: "Weekly",
      ),
      Quest(
        id: 5,
        title: "Reach \$10K portfolio value",
        description: "Grow your portfolio to \$10,000",
        icon: "💰",
        isCompleted: false,
        progress: 0.8,
        xpReward: 500,
        category: "Special",
      ),
    ];
  }

  int _getActiveQuestsCount() {
    return _getAllQuests().where((quest) => !quest.isCompleted).length;
  }

  int _getCompletedQuestsCount() {
    return _getAllQuests().where((quest) => quest.isCompleted).length;
  }

  int _getTotalXP() {
    return _getAllQuests()
        .where((quest) => quest.isCompleted)
        .fold(0, (sum, quest) => sum + quest.xpReward);
  }
}
