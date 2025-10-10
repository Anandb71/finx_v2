import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/finx_colors.dart';

class FinxCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool useGlassmorphism;
  final EdgeInsetsGeometry? padding;

  const FinxCard({
    super.key,
    required this.child,
    this.onTap,
    this.useGlassmorphism = false,
    this.padding,
  });

  @override
  State<FinxCard> createState() => _FinxCardState();
}

class _FinxCardState extends State<FinxCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: widget.padding ?? const EdgeInsets.all(FinxSpacing.md),
          decoration: BoxDecoration(
            color: widget.useGlassmorphism
                ? FinxColors.neutralFogDark.withOpacity(0.3)
                : FinxColors.neutralFogDark,
            borderRadius: BorderRadius.circular(FinxRadius.card),
            border: Border.all(
              color: _isHovered
                  ? FinxColors.auroraGreen.withOpacity(0.5)
                  : FinxColors.neutralFogMedium,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
                blurRadius: _isHovered ? 24 : 16,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: widget.useGlassmorphism
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(FinxRadius.card),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: widget.child,
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}

