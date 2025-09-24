import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolio_simulator_screen.dart';
import 'risk_calculator_screen.dart';
import 'chart_analysis_screen.dart';
import 'quiz_center_screen.dart';
import 'mascot_tutorial_screen.dart';
import '../services/mascot_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _glowAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  final List<String> _categories = [
    'All',
    'Stocks',
    'ETFs',
    'Options',
    'Crypto',
    'Real Estate',
    'Bonds',
    'Futures',
  ];
  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: Curves.linear,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _progressAnimationController.forward();
    });
    _particleAnimationController.repeat();
    _glowAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _particleAnimationController.dispose();
    _progressAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildStatsSection(),
            _buildMascotSection(),
            _buildFilterSection(),
            _buildInteractiveTools(),
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
                        15,
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
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFF00FFA3),
                                          Color(0xFF00D4FF),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Learn',
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
                                            const Color(
                                              0xFF00FFA3,
                                            ).withOpacity(_glowAnimation.value),
                                            const Color(
                                              0xFF00D4FF,
                                            ).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00FFA3)
                                                .withOpacity(
                                                  0.3 * _glowAnimation.value,
                                                ),
                                            blurRadius:
                                                15 * _glowAnimation.value,
                                            spreadRadius:
                                                2 * _glowAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'EDUCATION',
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
    final random = (index * 1.3) % 1.0;
    final size = 2.0 + (random * 5.0);
    final left = 20.0 + (random * 300.0);
    final top = 20.0 + (random * 100.0);
    final opacity = 0.2 + (random * 0.8);

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final animationValue = (_particleAnimation.value + random) % 1.0;
        return Positioned(
          left: left + (60 * (animationValue - 0.5)),
          top: top + (40 * (animationValue - 0.5)),
          child: Opacity(
            opacity: opacity * (1 - animationValue),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withOpacity(0.5),
                    blurRadius: 6,
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
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFA3).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Courses Completed',
                            '0',
                            Icons.school,
                            const Color(0xFF00FFA3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Learning Streak',
                            '0 days',
                            Icons.local_fire_department,
                            const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'XP Earned',
                            '0',
                            Icons.star,
                            const Color(0xFFFFD700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Certificates',
                            '0',
                            Icons.workspace_premium,
                            const Color(0xFF00D4FF),
                          ),
                        ),
                      ],
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMascotSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFA3).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
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
                            Icons.pets,
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
                                'Meet Your Trading Partners',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Learn from our expert fox team!',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MascotTutorialScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FFA3),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Meet Them'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Mascot grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: MascotType.values.length,
                      itemBuilder: (context, index) {
                        final mascot = MascotType.values[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MascotTutorialScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00FFA3,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      MascotService.getMascotImage(mascot),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.pets,
                                                size: 25,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  MascotService.getMascotName(mascot),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
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
                          final isSelected =
                              _categories[index] == _selectedCategory;
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
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00FFA3,
                                          ).withOpacity(0.3),
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
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
                      'Difficulty',
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
                        itemCount: _difficulties.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              _difficulties[index] == _selectedDifficulty;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDifficulty = _difficulties[index];
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
                                          Color(0xFF00D4FF),
                                          Color(0xFF9C27B0),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withOpacity(0.1),
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
                                          color: const Color(
                                            0xFF00D4FF,
                                          ).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  _difficulties[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
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

  Widget _buildLearningPathCard(Map<String, dynamic> path, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFA3).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [path['color1'] as Color, path['color2'] as Color],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  path['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path['title'] as String,
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      path['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${path['lessons']} lessons',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF00FFA3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          path['duration'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value:
                              (path['progress'] as double) *
                              _progressAnimation.value,
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            path['color1'] as Color,
                          ),
                        ),
                        Center(
                          child: Text(
                            '${((path['progress'] as double) * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          // Lock overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTools() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _cardAnimation.value)),
            child: Opacity(
              opacity: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Tools',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: _getInteractiveTools().length,
                      itemBuilder: (context, index) {
                        final tool = _getInteractiveTools()[index];
                        return _buildToolCard(tool, index);
                      },
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

  Widget _buildToolCard(Map<String, dynamic> tool, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tool['color1'] as Color, tool['color2'] as Color],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (tool['color1'] as Color).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTool(tool['title'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool['icon'] as IconData, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  tool['title'] as String,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  tool['description'] as String,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTool(String toolName) {
    switch (toolName) {
      case 'Portfolio Simulator':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PortfolioSimulatorScreen(),
          ),
        );
        break;
      case 'Risk Calculator':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RiskCalculatorScreen()),
        );
        break;
      case 'Chart Analysis':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChartAnalysisScreen()),
        );
        break;
      case 'Quiz Center':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizCenterScreen()),
        );
        break;
    }
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }

  // Mock data methods - only keeping interactive tools
  List<Map<String, dynamic>> _getInteractiveTools() {
    return [
      {
        'title': 'Portfolio Simulator',
        'description': 'Practice trading with virtual money',
        'icon': Icons.account_balance_wallet,
        'color1': const Color(0xFF00FFA3),
        'color2': const Color(0xFF00D4FF),
      },
      {
        'title': 'Risk Calculator',
        'description': 'Calculate position sizes and risk',
        'icon': Icons.calculate,
        'color1': const Color(0xFF9C27B0),
        'color2': const Color(0xFF673AB7),
      },
      {
        'title': 'Chart Analysis',
        'description': 'Learn technical analysis tools',
        'icon': Icons.show_chart,
        'color1': const Color(0xFFFFD700),
        'color2': const Color(0xFFFFA500),
      },
      {
        'title': 'Quiz Center',
        'description': 'Test your knowledge',
        'icon': Icons.quiz,
        'color1': const Color(0xFFFF6B6B),
        'color2': const Color(0xFFFF8E53),
      },
    ];
  }
}
