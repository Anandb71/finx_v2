import 'package:flutter/material.dart';
import '../theme/finx_colors.dart';
import '../theme/finx_typography.dart';

enum FinxButtonType { primary, secondary, outline }

class FinxButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final FinxButtonType type;
  final bool isLoading;
  final IconData? icon;

  const FinxButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = FinxButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<FinxButton> createState() => _FinxButtonState();
}

class _FinxButtonState extends State<FinxButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case FinxButtonType.primary:
        return FinxColors.auroraGreen;
      case FinxButtonType.secondary:
        return FinxColors.neutralFogDark;
      case FinxButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case FinxButtonType.primary:
        return FinxColors.nightVoid;
      case FinxButtonType.secondary:
      case FinxButtonType.outline:
        return FinxColors.ghostWhite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          if (widget.onPressed != null && !widget.isLoading) {
            widget.onPressed!();
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(FinxRadius.button),
              border: widget.type == FinxButtonType.outline
                  ? Border.all(
                      color: _isHovered
                          ? FinxColors.auroraGreen
                          : FinxColors.neutralFogMedium,
                      width: 1,
                    )
                  : null,
              boxShadow: _isHovered && widget.type == FinxButtonType.primary
                  ? [
                      BoxShadow(
                        color: FinxColors.auroraGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTextColor(),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: _getTextColor(),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: FinxTypography.button(color: _getTextColor()),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

