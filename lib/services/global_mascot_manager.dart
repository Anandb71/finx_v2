import 'package:flutter/material.dart';
import 'mascot_manager_service.dart';

class GlobalMascotManager {
  static final GlobalMascotManager _instance = GlobalMascotManager._internal();
  factory GlobalMascotManager() => _instance;
  GlobalMascotManager._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showMascotPopup(
    MascotTrigger trigger, {
    Map<String, dynamic>? context,
  }) {
    print('🦊 Mascot popup triggered: ${trigger.name}');
    final navigatorContext = navigatorKey.currentContext;
    if (navigatorContext == null) {
      print('❌ No context available for mascot popup');
      return;
    }

    // Generate AI-powered message
    MascotManagerService.generateAIMascotMessage(trigger, context: context)
        .then((message) {
          print('📝 AI Mascot message: ${message.message}');

          // Show as a bottom sheet instead of snackbar
          showModalBottomSheet(
            context: navigatorContext,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => _MascotPopupWidget(message: message),
          );
        })
        .catchError((error) {
          print('❌ Error generating AI mascot message: $error');
          // Fallback to static message
          final fallbackMessage = MascotManagerService.getMessageForContext(
            trigger,
          );
          showModalBottomSheet(
            context: navigatorContext,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => _MascotPopupWidget(message: fallbackMessage),
          );
        });
  }
}

class _MascotPopupWidget extends StatefulWidget {
  final MascotMessage message;

  const _MascotPopupWidget({required this.message});

  @override
  State<_MascotPopupWidget> createState() => _MascotPopupWidgetState();
}

class _MascotPopupWidgetState extends State<_MascotPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Slide in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Bounce animation for the mascot
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right side
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _bounceController.forward();

    // No auto-dismiss - user must manually close
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Speech Bubble
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.message.backgroundColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Character name
                        Text(
                          '${widget.message.emoji} ${MascotManagerService.getMascotName(widget.message.mascot)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.message.backgroundColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Message
                        Text(
                          widget.message.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mascot Character (with bounce animation)
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _bounceAnimation.value),
                      child: Transform.translate(
                        offset: Offset(0, -10 * (1 - _bounceAnimation.value)),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              MascotManagerService.getMascotImage(
                                widget.message.mascot,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Dismiss button
                GestureDetector(
                  onTap: () {
                    _slideController.reverse().then((_) {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
