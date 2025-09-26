// lib/screens/ai_mentor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../services/gemini_ai_service.dart';
import '../services/enhanced_portfolio_provider.dart';
import '../theme/liquid_material_theme.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class AIMentorScreen extends StatefulWidget {
  const AIMentorScreen({super.key});

  @override
  State<AIMentorScreen> createState() => _AIMentorScreenState();
}

class _AIMentorScreenState extends State<AIMentorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingController;
  late AnimationController _auroraController;
  late Animation<double> _typingAnimation;

  // Initialize Gemini AI service
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeAI();
  }

  void _initializeAI() async {
    try {
      GeminiAIService.initialize();
      _isInitialized = true;
      _addWelcomeMessage();
    } catch (e) {
      print('Error initializing AI: $e');
      _addWelcomeMessage(); // Add welcome message even if AI fails to initialize
    }
  }

  void _setupAnimations() {
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _auroraController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _auroraController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
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
          Column(
            children: [
              _buildLiquidAppBar(),
              Expanded(child: _buildChatInterface()),
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
    return Container(
      height: 100,
      child: ClipRect(
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
                    Icons.psychology_outlined,
                    color: LiquidMaterialTheme.neonAccent(context),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'AI Mentor',
                    style: LiquidTextStyle.headlineMedium(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isInitialized
                          ? LiquidMaterialTheme.neonAccent(
                              context,
                            ).withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _isInitialized ? 'Online' : 'Offline',
                      style: LiquidTextStyle.labelSmall(context).copyWith(
                        color: _isInitialized
                            ? LiquidMaterialTheme.neonAccent(context)
                            : Colors.red,
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

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(child: _buildMessagesList()),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LiquidMaterialTheme.neonAccent(context),
                    LiquidMaterialTheme.neonAccent(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: LiquidCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: LiquidTextStyle.bodyMedium(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: LiquidTextStyle.labelSmall(
                        context,
                      ).copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LiquidMaterialTheme.neonAccent(context),
                  LiquidMaterialTheme.neonAccent(context).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          LiquidCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _typingAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final animationValue = (_typingAnimation.value - delay)
                          .clamp(0.0, 1.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: LiquidMaterialTheme.neonAccent(
                            context,
                          ).withOpacity(animationValue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: LiquidCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: LiquidTextStyle.bodyMedium(context),
                  decoration: InputDecoration(
                    hintText: 'Ask your AI mentor anything...',
                    hintStyle: LiquidTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: Colors.white60),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidMaterialTheme.neonAccent(context),
                        LiquidMaterialTheme.neonAccent(
                          context,
                        ).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: messageText, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    if (_isInitialized) {
      _getAIResponse(messageText);
    } else {
      _addErrorMessage();
    }
  }

  void _getAIResponse(String userMessage) async {
    try {
      final response = await GeminiAIService.getFinancialAdvice(userMessage);
      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isTyping = false;
      });
    } catch (e) {
      _addErrorMessage();
    }
    _scrollToBottom();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: _isInitialized
              ? "Hello! I'm your AI financial mentor. I'm here to help you with investment strategies, market analysis, and portfolio management. What would you like to know?"
              : "Hello! I'm your AI financial mentor, but I'm currently offline. I can still provide some basic guidance. What would you like to know?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _addErrorMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "I'm sorry, I'm having trouble connecting right now. Please try again later or check your internet connection.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
