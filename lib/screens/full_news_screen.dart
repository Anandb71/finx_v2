import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../services/news_service.dart';
import '../widgets/liquid_card.dart';
import '../utils/liquid_text_style.dart';

class FullNewsScreen extends StatefulWidget {
  const FullNewsScreen({super.key});

  @override
  State<FullNewsScreen> createState() => _FullNewsScreenState();
}

class _FullNewsScreenState extends State<FullNewsScreen> {
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final articles = await context.read<NewsService>().getFinancialNews(
        pageSize: 20,
      );

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load news: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Aurora Background
          _buildAuroraBackground(),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [_buildAppBar(), _buildContent()],
          ),
        ],
      ),
    );
  }

  Widget _buildAuroraBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000), // Super dark black
            Color(0xFF000000), // Super dark black
            Color(0xFF000000), // Super dark black
            Color(0xFF000000), // Super dark black
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Financial News',
                                  style: LiquidTextStyle.headlineMedium(context)
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Stay updated with market insights',
                                  style: LiquidTextStyle.bodyMedium(
                                    context,
                                  ).copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _loadNews,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.refresh,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SliverFillRemaining(child: _buildLoadingState());
    }

    if (_error.isNotEmpty) {
      return SliverFillRemaining(child: _buildErrorState());
    }

    if (_articles.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final article = _articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildNewsCard(article, index == 0),
          );
        }, childCount: _articles.length),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading financial news...',
            style: LiquidTextStyle.bodyLarge(
              context,
            ).copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.7),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load News',
              style: LiquidTextStyle.headlineMedium(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _error,
              style: LiquidTextStyle.bodyMedium(
                context,
              ).copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'No News Available',
              style: LiquidTextStyle.headlineMedium(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Check your internet connection and try again',
              style: LiquidTextStyle.bodyMedium(
                context,
              ).copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Refresh',
                style: LiquidTextStyle.labelMedium(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, bool isFirst) {
    return LiquidCard(
      child: InkWell(
        onTap: () {
          // You can add navigation to a full article view here
          _showArticleDetails(article);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFirst) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'FEATURED',
                        style: LiquidTextStyle.labelSmall(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.timeAgo,
                      style: LiquidTextStyle.labelSmall(
                        context,
                      ).copyWith(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                Row(
                  children: [
                    Text(
                      article.timeAgo,
                      style: LiquidTextStyle.labelSmall(
                        context,
                      ).copyWith(color: Colors.white60, fontSize: 11),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              Text(
                article.title,
                style: isFirst
                    ? LiquidTextStyle.titleLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      )
                    : LiquidTextStyle.titleMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                maxLines: isFirst ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Text(
                article.description,
                style: LiquidTextStyle.bodyMedium(
                  context,
                ).copyWith(color: Colors.white70, height: 1.4),
                maxLines: isFirst ? 4 : 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.source, size: 16, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    article.source,
                    style: LiquidTextStyle.labelMedium(
                      context,
                    ).copyWith(color: Colors.white60, fontSize: 12),
                  ),
                  const Spacer(),
                  if (article.urlToImage != null) ...[
                    Icon(
                      Icons.image,
                      size: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleDetails(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: LiquidTextStyle.headlineMedium(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(Icons.source, size: 16, color: Colors.white60),
                          const SizedBox(width: 6),
                          Text(
                            article.source,
                            style: LiquidTextStyle.labelMedium(
                              context,
                            ).copyWith(color: Colors.white60),
                          ),
                          const Spacer(),
                          Text(
                            article.timeAgo,
                            style: LiquidTextStyle.labelMedium(
                              context,
                            ).copyWith(color: Colors.white60),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        article.description,
                        style: LiquidTextStyle.bodyLarge(
                          context,
                        ).copyWith(color: Colors.white70, height: 1.6),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // You can add logic to open the full article URL here
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Read Full Article',
                            style: LiquidTextStyle.labelMedium(context)
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
