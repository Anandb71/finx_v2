// lib/widgets/swipeable_news_card.dart

import 'package:flutter/material.dart';
import 'package:finx_v2/models/news_article.dart';

class SwipeableNewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const SwipeableNewsCard({
    Key? key,
    required this.article,
    this.onBookmark,
    this.onShare,
    this.onTap,
  }) : super(key: key);

  @override
  State<SwipeableNewsCard> createState() => _SwipeableNewsCardState();
}

class _SwipeableNewsCardState extends State<SwipeableNewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  double _swipeOffset = 0.0;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
      _swipeOffset = _swipeOffset.clamp(-120.0, 0.0); // Limit swipe distance
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_swipeOffset < -60.0) {
      // Show actions
      _showActions = true;
      _swipeAnimation = Tween<double>(begin: _swipeOffset, end: -120.0).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
      );
      _swipeController.forward();
    } else {
      // Hide actions
      _showActions = false;
      _swipeAnimation = Tween<double>(begin: _swipeOffset, end: 0.0).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
      );
      _swipeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Action buttons (behind the card)
          if (_showActions)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: widget.onBookmark ?? () {},
                      child: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onShare ?? () {},
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),

          // Main card content
          AnimatedBuilder(
            animation: _swipeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _showActions ? _swipeAnimation.value : _swipeOffset,
                  0,
                ),
                child: GestureDetector(
                  onTap: widget.onTap,
                  onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                  onHorizontalDragEnd: _handleHorizontalDragEnd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Article thumbnail placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.article_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Article content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.article.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.article.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      widget.article.source,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      widget.article.timeAgo,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
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
        ],
      ),
    );
  }
}
