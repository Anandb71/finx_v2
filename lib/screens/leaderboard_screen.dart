import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _rankAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rankAnimation;

  String _selectedTimeframe = 'All Time';
  String _selectedCategory = 'Portfolio Value';

  final List<String> _timeframes = ['All Time', 'This Month', 'This Week', 'Today'];
  final List<String> _categories = ['Portfolio Value', 'XP Earned', 'Trades Made', 'Win Rate'];

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _rankAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    _rankAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rankAnimationController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _rankAnimationController.forward();
    });
    _particleAnimationController.repeat();
    _glowAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _particleAnimationController.dispose();
    _glowAnimationController.dispose();
    _rankAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildStatsSection(),
            _buildFilterSection(),
            _buildLeaderboardList(),
            _buildBottomPadding(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _headerAnimation.value)),
            child: Opacity(
              opacity: _headerAnimation.value,
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                        Color(0xFF0F3460),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background particles
                      ...List.generate(
                        12,
                        (index) => _buildFloatingParticle(index),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
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
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Leaderboard',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFFFD700).withOpacity(_glowAnimation.value),
                                            const Color(0xFFFFA500).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withOpacity(0.3 * _glowAnimation.value),
                                            blurRadius: 15 * _glowAnimation.value,
                                            spreadRadius: 2 * _glowAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'LIVE',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1.7) % 1.0;
    final size = 3.0 + (random * 6.0);
    final left = 20.0 + (random * 300.0);
    final top = 20.0 + (random * 100.0);
    final opacity = 0.3 + (random * 0.7);

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final animationValue = (_particleAnimation.value + random) % 1.0;
        return Positioned(
          left: left + (50 * (animationValue - 0.5)),
          top: top + (30 * (animationValue - 0.5)),
          child: Opacity(
            opacity: opacity * (1 - animationValue),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _listAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _listAnimation.value)),
            child: Opacity(
              opacity: _listAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Your Rank',
                        '#${_getUserRank()}',
                        Icons.emoji_events,
                        const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Total Players',
                        '${_getTotalPlayers()}',
                        Icons.people,
                        const Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Your Score',
                        '\$${_getUserScore().toStringAsFixed(0)}',
                        Icons.trending_up,
                        const Color(0xFF00FFA3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _listAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _listAnimation.value)),
            child: Opacity(
              opacity: _listAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeframe',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _timeframes.length,
                        itemBuilder: (context, index) {
                          final isSelected = _timeframes[index] == _selectedTimeframe;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeframe = _timeframes[index];
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
                                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFD700)
                                      : Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  _timeframes[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Category',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _categories[index] == _selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = _categories[index];
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
                                        colors: [Color(0xFF00D4FF), Color(0xFF00FFA3)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00D4FF)
                                      : Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  _categories[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.white70,
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
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _listAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - _listAnimation.value)),
            child: Opacity(
              opacity: _listAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListHeader(),
                    ...List.generate(
                      _getLeaderboardData().length,
                      (index) => _buildLeaderboardItem(
                        _getLeaderboardData()[index],
                        index + 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'RANK',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              'PLAYER',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _selectedCategory.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'CHANGE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int rank) {
    final isTopThree = rank <= 3;
    final isCurrentUser = entry.isCurrentUser;
    
    return AnimatedBuilder(
      animation: _rankAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _rankAnimation.value)),
          child: Opacity(
            opacity: _rankAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isCurrentUser
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFF00FFA3),
                        ],
                      )
                    : null,
                color: isCurrentUser ? null : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: _buildRankWidget(rank, isTopThree),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCurrentUser
                                ? const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                  )
                                : LinearGradient(
                                    colors: [
                                      _getRankColor(rank).withOpacity(0.8),
                                      _getRankColor(rank).withOpacity(0.4),
                                    ],
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: _getRankColor(rank).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              entry.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrentUser ? Colors.white : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Level ${entry.level}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isCurrentUser ? Colors.white70 : Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatValue(entry.value),
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCurrentUser ? Colors.white : _getRankColor(rank),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          entry.change >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: entry.change >= 0 ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.change >= 0 ? '+' : ''}${entry.change.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: entry.change >= 0 ? const Color(0xFF00FFA3) : const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
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

  Widget _buildRankWidget(int rank, bool isTopThree) {
    if (isTopThree) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRankColor(rank),
              _getRankColor(rank).withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getRankColor(rank).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getRankIcon(rank),
            color: Colors.white,
            size: 18,
          ),
        ),
      );
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF00D4FF);
    }
  }

  String _formatValue(double value) {
    if (_selectedCategory == 'Portfolio Value') {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    } else if (_selectedCategory == 'XP Earned') {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (_selectedCategory == 'Trades Made') {
      return value.toInt().toString();
    } else if (_selectedCategory == 'Win Rate') {
      return '${value.toStringAsFixed(1)}%';
    }
    return value.toStringAsFixed(0);
  }

  List<LeaderboardEntry> _getLeaderboardData() {
    return [
      LeaderboardEntry(
        userId: 'alex_chen_001',
        username: 'Alex Chen',
        value: 1250000,
        changePercent: 12.5,
        rank: 1,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Alex Chen',
        change: 12.5,
        level: 15,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'sarah_johnson_002',
        username: 'Sarah Johnson',
        value: 1180000,
        changePercent: 8.3,
        rank: 2,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Sarah Johnson',
        change: 8.3,
        level: 14,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'mike_rodriguez_003',
        username: 'Mike Rodriguez',
        value: 1095000,
        changePercent: -2.1,
        rank: 3,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Mike Rodriguez',
        change: -2.1,
        level: 13,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'current_user_004',
        username: 'You',
        value: 950000,
        changePercent: 15.7,
        rank: 4,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'You',
        change: 15.7,
        level: 12,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        userId: 'emma_wilson_005',
        username: 'Emma Wilson',
        value: 875000,
        changePercent: 5.2,
        rank: 5,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Emma Wilson',
        change: 5.2,
        level: 11,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'david_kim_006',
        username: 'David Kim',
        value: 820000,
        changePercent: -1.8,
        rank: 6,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'David Kim',
        change: -1.8,
        level: 10,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'lisa_zhang_007',
        username: 'Lisa Zhang',
        value: 780000,
        changePercent: 7.9,
        rank: 7,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Lisa Zhang',
        change: 7.9,
        level: 10,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'tom_anderson_008',
        username: 'Tom Anderson',
        value: 720000,
        changePercent: 3.4,
        rank: 8,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Tom Anderson',
        change: 3.4,
        level: 9,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'maria_garcia_009',
        username: 'Maria Garcia',
        value: 680000,
        changePercent: -0.5,
        rank: 9,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'Maria Garcia',
        change: -0.5,
        level: 9,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'james_brown_010',
        username: 'James Brown',
        value: 640000,
        changePercent: 11.2,
        rank: 10,
        type: LeaderboardType.portfolioValue,
        lastUpdated: DateTime.now(),
        name: 'James Brown',
        change: 11.2,
        level: 8,
        isCurrentUser: false,
      ),
    ];
  }

  int _getUserRank() {
    return 4; // User is currently ranked 4th
  }

  int _getTotalPlayers() {
    return 1247; // Total number of players
  }

  double _getUserScore() {
    return 950000; // User's current score
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }
}