// lib/utils/scroll_reveal.dart

import 'dart:async';
import 'package:flutter/material.dart';

// Simplified scroll reveal for cross-platform compatibility

class ScrollRevealController extends ChangeNotifier {
  final Set<String> _revealedElements = {};
  final Map<String, StreamSubscription> _observers = {};

  bool isElementRevealed(String elementId) {
    return _revealedElements.contains(elementId);
  }

  void observeElement(String elementId, String selector) {
    if (_revealedElements.contains(elementId)) return;

    // Simplified version - immediately mark as revealed for demo purposes
    // In a real implementation, you would use platform-specific intersection observers
    _revealedElements.add(elementId);
    notifyListeners();
  }

  void dispose() {
    _observers.clear();
    _revealedElements.clear();
    super.dispose();
  }
}

class ScrollRevealWidget extends StatefulWidget {
  final Widget child;
  final String elementId;
  final ScrollRevealController controller;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const ScrollRevealWidget({
    Key? key,
    required this.child,
    required this.elementId,
    required this.controller,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<ScrollRevealWidget> createState() => _ScrollRevealWidgetState();
}

class _ScrollRevealWidgetState extends State<ScrollRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: widget.curve),
        );

    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (widget.controller.isElementRevealed(widget.elementId)) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: 0.99 + (0.01 * _fadeAnimation.value),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// Staggered reveal for lists of widgets
class StaggeredRevealList extends StatelessWidget {
  final List<Widget> children;
  final ScrollRevealController controller;
  final Duration staggerDelay;

  const StaggeredRevealList({
    Key? key,
    required this.children,
    required this.controller,
    this.staggerDelay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return ScrollRevealWidget(
          elementId: 'staggered_$index',
          controller: controller,
          delay: staggerDelay * index,
          child: child,
        );
      }).toList(),
    );
  }
}
