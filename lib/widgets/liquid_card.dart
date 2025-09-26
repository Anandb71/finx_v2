import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiquidCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool enableHover;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  const LiquidCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.enableHover = true,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _shimmerController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;
  Offset? _mousePosition;
  Offset? _localCursorPosition;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    );
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start shimmer animation
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHoverEnter(PointerEvent event) {
    if (widget.enableHover) {
      setState(() {
        _isHovered = true;
        _mousePosition = event.localPosition;
        _localCursorPosition = event.localPosition;
      });
      _hoverController.forward();
    }
  }

  void _onHoverExit(PointerEvent event) {
    if (widget.enableHover) {
      setState(() {
        _isHovered = false;
        _mousePosition = null;
        _localCursorPosition = null;
      });
      _hoverController.reverse();
    }
  }

  void _onHoverMove(PointerEvent event) {
    if (widget.enableHover) {
      setState(() {
        _mousePosition = event.localPosition;
        _localCursorPosition = event.localPosition;
      });
    }
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  Widget _buildCardContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Layer 1: The Blur - BackdropFilter sits at the bottom
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(28.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              // Layer 2: The Tint & Border
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(
                  0.15,
                ), // Glass surface tint
                border: Border.all(
                  color: Colors.white.withOpacity(
                    0.2 + (_hoverAnimation.value * 0.1),
                  ),
                  width: 1.0,
                ),
                borderRadius:
                    widget.borderRadius ?? BorderRadius.circular(28.0),
                boxShadow:
                    widget.boxShadow ??
                    [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(
                          0.1 + (_hoverAnimation.value * 0.1),
                        ),
                        blurRadius: 20 + (_hoverAnimation.value * 10),
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
              ),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(20.0),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    // Layer 3: The Reflective Sheen with ShaderMask
                    return ShaderMask(
                      shaderCallback: (rect) {
                        // Create the moving gradient for the sheen effect
                        final slidePosition = _shimmerAnimation.value;
                        final colorWidth =
                            0.5; // How wide the bright part of the sheen is

                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(
                              0.2,
                            ), // Base ambient reflection
                            Colors.white.withOpacity(
                              0.7,
                            ), // The bright "hotspot" of the sheen
                            Colors.white.withOpacity(0.2), // Back to ambient
                          ],
                          // The stops are crucial. They control the position of the colors.
                          // By linking them to the animation value, we make the gradient move.
                          stops: [
                            (slidePosition - colorWidth).clamp(0.0, 1.0),
                            slidePosition.clamp(0.0, 1.0),
                            (slidePosition + colorWidth).clamp(0.0, 1.0),
                          ],
                          tileMode: TileMode
                              .clamp, // Prevents the gradient from repeating
                        ).createShader(rect);
                      },
                      // This blend mode applies the shader's colors on top of the child's existing colors.
                      blendMode: BlendMode.srcATop,
                      child: widget.child, // This is the original card content
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate 3D tilt effect based on cursor position
        double yRotation = 0.0;
        double xRotation = 0.0;
        bool enable3DTilt = false; // Safety flag

        try {
          if (_localCursorPosition != null &&
              constraints.maxWidth > 0 &&
              constraints.maxHeight > 0) {
            // Get the size of the card for center calculation
            final cardSize = Size(constraints.maxWidth, constraints.maxHeight);
            final centerX = cardSize.width / 2;
            final centerY = cardSize.height / 2;

            // Map the cursor position to a small rotation angle (max ~6 degrees)
            // Add safety checks to prevent division by zero and NaN values
            if (centerX > 0) {
              yRotation = ((_localCursorPosition!.dx - centerX) / centerX * 0.1)
                  .clamp(-0.1, 0.1); // Clamp to prevent extreme values
            }
            if (centerY > 0) {
              xRotation =
                  (-(_localCursorPosition!.dy - centerY) / centerY * 0.1).clamp(
                    -0.1,
                    0.1,
                  ); // Clamp to prevent extreme values
            }

            // Only enable 3D tilt if values are valid
            enable3DTilt = yRotation.isFinite && xRotation.isFinite;
          }
        } catch (e) {
          // If any error occurs, disable 3D tilt
          enable3DTilt = false;
          yRotation = 0.0;
          xRotation = 0.0;
        }

        return MouseRegion(
          onEnter: _onHoverEnter,
          onExit: _onHoverExit,
          onHover: _onHoverMove,
          child: AnimatedBuilder(
            animation: Listenable.merge([_hoverAnimation, _shimmerAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_hoverAnimation.value * 0.02),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  margin: widget.margin,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onTap,
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(28.0),
                      child: enable3DTilt
                          ? Transform(
                              transform: Matrix4.identity()
                                ..setEntry(
                                  3,
                                  2,
                                  0.001,
                                ) // This entry adds the 3D perspective
                                ..rotateX(xRotation)
                                ..rotateY(yRotation),
                              alignment: FractionalOffset.center,
                              child: _buildCardContent(),
                            )
                          : _buildCardContent(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
