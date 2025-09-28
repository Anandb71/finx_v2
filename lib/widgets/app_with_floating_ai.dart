import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'floating_ai_button.dart';
import '../services/ai_mentor_state_service.dart';

class AppWithFloatingAI extends StatelessWidget {
  final Widget child;
  final bool showFloatingAI;

  const AppWithFloatingAI({
    super.key,
    required this.child,
    this.showFloatingAI = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AIMentorStateService>(
      builder: (context, aiMentorState, child) {
        return Stack(
          children: [
            this.child,
            if (this.showFloatingAI && !aiMentorState.isAIMentorOpen)
              const FloatingAIButton(),
          ],
        );
      },
    );
  }
}
