import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  // Mock quest data
  final List<Quest> allQuests = [
    // Daily Quests
    Quest(
      id: 1,
      title: "Read an article in the Learn section",
      description: "Expand your knowledge by reading one educational article",
      icon: "💡",
      isCompleted: false,
      progress: 0.3,
      xpReward: 25,
      category: "Daily",
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),
    Quest(
      id: 2,
      title: "Add a tech stock to your watchlist",
      description: "Add any technology sector stock to your watchlist",
      icon: "📈",
      isCompleted: false,
      progress: 0.0,
      xpReward: 30,
      category: "Daily",
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),
    Quest(
      id: 3,
      title: "Perform your first trade",
      description: "Execute your first buy or sell order",
      icon: "💰",
      isCompleted: true,
      progress: 1.0,
      xpReward: 50,
      category: "Daily",
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),
    Quest(
      id: 4,
      title: "Check market movers",
      description: "View the market movers section on the dashboard",
      icon: "📊",
      isCompleted: false,
      progress: 0.7,
      xpReward: 20,
      category: "Daily",
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),
    Quest(
      id: 5,
      title: "Complete 3 trades this week",
      description: "Execute at least 3 buy or sell orders this week",
      icon: "🎯",
      isCompleted: false,
      progress: 0.6,
      xpReward: 100,
      category: "Daily",
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),

    // Weekly Quests
    Quest(
      id: 6,
      title: "Diversify your portfolio",
      description: "Invest in stocks from at least 3 different sectors",
      icon: "🌐",
      isCompleted: false,
      progress: 0.4,
      xpReward: 150,
      category: "Weekly",
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
    Quest(
      id: 7,
      title: "Achieve 10% portfolio growth",
      description: "Increase your total portfolio value by 10%",
      icon: "📈",
      isCompleted: false,
      progress: 0.2,
      xpReward: 200,
      category: "Weekly",
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
    Quest(
      id: 8,
      title: "Complete all daily quests",
      description: "Finish all daily quests for 5 consecutive days",
      icon: "🔥",
      isCompleted: false,
      progress: 0.8,
      xpReward: 300,
      category: "Weekly",
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),

    // Special Quests
    Quest(
      id: 9,
      title: "First Million",
      description: "Grow your virtual portfolio to \$1,000,000",
      icon: "💎",
      isCompleted: false,
      progress: 0.1,
      xpReward: 1000,
      category: "Special",
    ),
    Quest(
      id: 10,
      title: "Market Master",
      description: "Make profitable trades for 30 consecutive days",
      icon: "👑",
      isCompleted: false,
      progress: 0.0,
      xpReward: 500,
      category: "Special",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Quest> get filteredQuests {
    if (_selectedCategory == 'All') {
      return allQuests;
    }
    return allQuests
        .where((quest) => quest.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildStatsSection(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuestList('All'),
                    _buildQuestList('Daily'),
                    _buildQuestList('Weekly'),
                    _buildQuestList('Special'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Quests & Challenges',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${allQuests.where((q) => q.isCompleted).length}/${allQuests.length}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final completedQuests = allQuests.where((q) => q.isCompleted).length;
    final totalXp = allQuests
        .where((q) => q.isCompleted)
        .fold(0, (sum, q) => sum + q.xpReward);
    final dailyCompleted = allQuests
        .where((q) => q.category == 'Daily' && q.isCompleted)
        .length;
    final dailyTotal = allQuests.where((q) => q.category == 'Daily').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Completed',
              '$completedQuests',
              Icons.check_circle,
              const Color(0xFF00FFA3),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: _buildStatItem(
              'XP Earned',
              '$totalXp',
              Icons.star,
              const Color(0xFF00D4FF),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: _buildStatItem(
              'Daily Streak',
              '$dailyCompleted/$dailyTotal',
              Icons.local_fire_department,
              const Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Daily'),
          Tab(text: 'Weekly'),
          Tab(text: 'Special'),
        ],
      ),
    );
  }

  Widget _buildQuestList(String category) {
    final quests = category == 'All'
        ? allQuests
        : allQuests.where((q) => q.category == category).toList();

    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No quests available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        return _buildQuestCard(quests[index]);
      },
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: quest.isCompleted
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quest.isCompleted
              ? const Color(0xFF00FFA3).withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: quest.isCompleted
                ? const Color(0xFF00FFA3).withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Quest icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF00FFA3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(quest.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),

              // Quest info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: quest.isCompleted
                                  ? Colors.white
                                  : Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: quest.isCompleted
                                ? Colors.white.withOpacity(0.2)
                                : const Color(0xFF00FFA3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quest.category,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: quest.isCompleted
                                  ? Colors.white
                                  : const Color(0xFF00FFA3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: quest.isCompleted
                            ? Colors.white70
                            : Colors.white60,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // XP reward
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF00FFA3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: quest.isCompleted
                        ? Colors.white
                        : const Color(0xFF00FFA3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress section
          if (!quest.isCompleted) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: quest.progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00FFA3),
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(quest.progress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: quest.isCompleted ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Completed!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (quest.deadline != null)
                  Text(
                    'Deadline: ${_formatDeadline(quest.deadline!)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return 'Expired';
    }
  }
}
