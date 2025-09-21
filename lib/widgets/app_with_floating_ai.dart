import 'package:flutter/material.dart';
import 'floating_ai_button.dart';

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
    return Stack(
      children: [child, if (showFloatingAI) const FloatingAIButton()],
    );
  }
}
