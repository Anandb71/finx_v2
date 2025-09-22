import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizCenterScreen extends StatefulWidget {
  const QuizCenterScreen({super.key});

  @override
  State<QuizCenterScreen> createState() => _QuizCenterScreenState();
}

class _QuizCenterScreenState extends State<QuizCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _quizAnimationController;
  late AnimationController _glowAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _quizAnimation;
  late Animation<double> _glowAnimation;

  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizStarted = false;
  bool _quizCompleted = false;
  List<int> _selectedAnswers = [];
  List<bool> _answerResults = [];

  final List<String> _categories = [
    'All',
    'Stocks',
    'ETFs',
    'Options',
    'Crypto',
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

    _quizAnimationController = AnimationController(
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

    _quizAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _quizAnimationController,
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
      _quizAnimationController.forward();
    });
    _glowAnimationController.repeat(reverse: true);
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswers = List.filled(_getFilteredQuestions().length, -1);
      _answerResults = List.filled(_getFilteredQuestions().length, false);
    });
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _getFilteredQuestions().length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    int correctAnswers = 0;
    for (int i = 0; i < _getFilteredQuestions().length; i++) {
      final question = _getFilteredQuestions()[i];
      if (_selectedAnswers[i] == question['correctAnswer']) {
        correctAnswers++;
        _answerResults[i] = true;
      }
    }

    setState(() {
      _score = correctAnswers;
      _quizCompleted = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _quizStarted = false;
      _quizCompleted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswers = [];
      _answerResults = [];
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _quizAnimationController.dispose();
    _glowAnimationController.dispose();
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
            if (!_quizStarted && !_quizCompleted) ..._buildQuizSelection(),
            if (_quizStarted && !_quizCompleted) ..._buildQuizInterface(),
            if (_quizCompleted) ..._buildQuizResults(),
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
                        10,
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
                                          Color(0xFFFF6B6B),
                                          Color(0xFFFF8E53),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'Quiz Center',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 20,
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
                                              0xFFFF6B6B,
                                            ).withOpacity(_glowAnimation.value),
                                            const Color(
                                              0xFFFF8E53,
                                            ).withOpacity(_glowAnimation.value),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF6B6B)
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
                                        'QUIZ',
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
    final size = 2.0 + (random * 4.0);
    final left = 20.0 + (random * 300.0);
    final top = 20.0 + (random * 80.0);
    final opacity = 0.2 + (random * 0.6);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final animationValue = (_glowAnimation.value + random) % 1.0;
        return Positioned(
          left: left + (40 * (animationValue - 0.5)),
          top: top + (30 * (animationValue - 0.5)),
          child: Opacity(
            opacity: opacity * (1 - animationValue),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.5),
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

  List<Widget> _buildQuizSelection() {
    return [
      SliverToBoxAdapter(
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
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Categories',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                            Color(0xFFFF6B6B),
                                            Color(0xFFFF8E53),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
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
                        'Difficulty Level',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
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
      ),
      SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _cardAnimation.value)),
              child: Opacity(
                opacity: _cardAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ready to Test Your Knowledge?',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getFilteredQuestions().length} questions • ${_getDifficultyText()} level',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFA3), Color(0xFF00D4FF)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFA3).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _startQuiz,
                            borderRadius: BorderRadius.circular(25),
                            child: Center(
                              child: Text(
                                'Start Quiz',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
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
        ),
      ),
    ];
  }

  List<Widget> _buildQuizInterface() {
    final questions = _getFilteredQuestions();
    final currentQuestion = questions[_currentQuestionIndex];

    return [
      SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _quizAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _quizAnimation.value)),
              child: Opacity(
                opacity: _quizAnimation.value,
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
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Score: $_score',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00D4FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / questions.length,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D4FF),
                        ),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentQuestion['question'] as String,
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(
                        (currentQuestion['answers'] as List<String>).length,
                        (index) => _buildAnswerOption(
                          (currentQuestion['answers'] as List<String>)[index],
                          index,
                          _selectedAnswers[_currentQuestionIndex] == index,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (_currentQuestionIndex > 0)
                            Expanded(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _currentQuestionIndex--;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(22),
                                    child: Center(
                                      child: Text(
                                        'Previous',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_currentQuestionIndex > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00FFA3),
                                    Color(0xFF00D4FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00FFA3,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:
                                      _selectedAnswers[_currentQuestionIndex] !=
                                          -1
                                      ? _nextQuestion
                                      : null,
                                  borderRadius: BorderRadius.circular(22),
                                  child: Center(
                                    child: Text(
                                      _currentQuestionIndex ==
                                              questions.length - 1
                                          ? 'Finish Quiz'
                                          : 'Next',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    ];
  }

  Widget _buildAnswerOption(String answer, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF9C27B0)],
              )
            : null,
        color: isSelected ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00D4FF)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00D4FF)
                          : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF00D4FF),
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    answer,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuizResults() {
    final questions = _getFilteredQuestions();
    final percentage = (_score / questions.length * 100).round();

    return [
      SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _quizAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _quizAnimation.value)),
              child: Opacity(
                opacity: _quizAnimation.value,
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
                      color: _getScoreColor(percentage).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _getScoreColor(percentage),
                              _getScoreColor(percentage).withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getScoreColor(
                                percentage,
                              ).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$percentage%',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getScoreMessage(percentage),
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You scored $_score out of ${questions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _resetQuiz,
                                  borderRadius: BorderRadius.circular(22),
                                  child: Center(
                                    child: Text(
                                      'Try Again',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00FFA3),
                                    Color(0xFF00D4FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00FFA3,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _resetQuiz();
                                    _startQuiz();
                                  },
                                  borderRadius: BorderRadius.circular(22),
                                  child: Center(
                                    child: Text(
                                      'New Quiz',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    ];
  }

  Widget _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 100));
  }

  List<Map<String, dynamic>> _getFilteredQuestions() {
    final allQuestions = _getAllQuestions();
    return allQuestions.where((question) {
      final categoryMatch =
          _selectedCategory == 'All' ||
          question['category'] == _selectedCategory;
      final difficultyMatch =
          _selectedDifficulty == 'All' ||
          question['difficulty'] == _selectedDifficulty;
      return categoryMatch && difficultyMatch;
    }).toList();
  }

  String _getDifficultyText() {
    return _selectedDifficulty == 'All' ? 'Mixed' : _selectedDifficulty;
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF00FFA3);
    if (percentage >= 60) return const Color(0xFFFFD700);
    if (percentage >= 40) return const Color(0xFFFF8E53);
    return const Color(0xFFFF6B6B);
  }

  String _getScoreMessage(int percentage) {
    if (percentage >= 90) return 'Outstanding!';
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 70) return 'Good Job!';
    if (percentage >= 60) return 'Not Bad!';
    if (percentage >= 40) return 'Keep Learning!';
    return 'Try Again!';
  }

  List<Map<String, dynamic>> _getAllQuestions() {
    return [
      {
        'question': 'What does IPO stand for?',
        'answers': [
          'Initial Public Offering',
          'International Portfolio Option',
          'Investment Profit Opportunity',
          'Individual Purchase Order',
        ],
        'correctAnswer': 0,
        'category': 'Stocks',
        'difficulty': 'Beginner',
      },
      {
        'question': 'What is the primary purpose of a stop-loss order?',
        'answers': [
          'To maximize profits',
          'To limit losses',
          'To increase trading volume',
          'To reduce taxes',
        ],
        'correctAnswer': 1,
        'category': 'Stocks',
        'difficulty': 'Beginner',
      },
      {
        'question': 'What does ETF stand for?',
        'answers': [
          'Exchange Traded Fund',
          'Electronic Trading Facility',
          'Equity Transfer Fund',
          'Enhanced Trading Feature',
        ],
        'correctAnswer': 0,
        'category': 'ETFs',
        'difficulty': 'Beginner',
      },
      {
        'question': 'What is the main advantage of diversification?',
        'answers': [
          'Higher returns',
          'Lower risk',
          'Lower taxes',
          'Faster execution',
        ],
        'correctAnswer': 1,
        'category': 'Stocks',
        'difficulty': 'Intermediate',
      },
      {
        'question': 'What is a call option?',
        'answers': [
          'Right to sell at a specific price',
          'Right to buy at a specific price',
          'Obligation to buy',
          'Obligation to sell',
        ],
        'correctAnswer': 1,
        'category': 'Options',
        'difficulty': 'Intermediate',
      },
      {
        'question': 'What does RSI measure?',
        'answers': [
          'Price momentum',
          'Volume trends',
          'Market volatility',
          'Interest rates',
        ],
        'correctAnswer': 0,
        'category': 'Stocks',
        'difficulty': 'Advanced',
      },
      {
        'question': 'What is the primary characteristic of a bond?',
        'answers': [
          'High volatility',
          'Fixed income',
          'Equity ownership',
          'Currency trading',
        ],
        'correctAnswer': 1,
        'category': 'Bonds',
        'difficulty': 'Beginner',
      },
      {
        'question': 'What does MACD stand for?',
        'answers': [
          'Moving Average Convergence Divergence',
          'Market Analysis and Chart Data',
          'Multiple Asset Correlation Dashboard',
          'Maximum Allowable Credit Default',
        ],
        'correctAnswer': 0,
        'category': 'Stocks',
        'difficulty': 'Advanced',
      },
      {
        'question': 'What is the main risk of cryptocurrency investing?',
        'answers': [
          'Low liquidity',
          'High volatility',
          'Government regulation',
          'All of the above',
        ],
        'correctAnswer': 3,
        'category': 'Crypto',
        'difficulty': 'Intermediate',
      },
      {
        'question': 'What is a futures contract?',
        'answers': [
          'A past transaction',
          'An agreement to buy/sell at a future date',
          'A type of stock',
          'A government bond',
        ],
        'correctAnswer': 1,
        'category': 'Futures',
        'difficulty': 'Advanced',
      },
    ];
  }
}

