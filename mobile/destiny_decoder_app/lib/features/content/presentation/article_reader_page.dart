import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/content_providers.dart';
import '../data/models/article_models.dart';
import '../../sharing/widgets/share_widget.dart';

class ArticleReaderPage extends ConsumerStatefulWidget {
  final String slug;

  const ArticleReaderPage({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends ConsumerState<ArticleReaderPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    
    // Track view after page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trackArticleView(ref, widget.slug);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailProvider(widget.slug));
    final isBookmarked = ref.watch(bookmarksProvider).contains(widget.slug);

    return Scaffold(
      body: articleAsync.when(
        data: (article) => CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App bar with progress indicator
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    ref.read(bookmarksProvider.notifier).toggleBookmark(widget.slug);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareArticle(article),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Article content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article metadata
                    _ArticleMetadata(article: article),
                    const SizedBox(height: 24),

                    // Article content
                    ...article.content.map((content) => _buildContentItem(context, content)),

                    const SizedBox(height: 32),

                    // Share article
                    ArticleShareWidget(
                      title: article.title,
                      category: article.category,
                      slug: widget.slug,
                    ),

                    const SizedBox(height: 24),

                    // Related articles
                    _RelatedArticlesSection(slug: widget.slug),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text('Failed to load article'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(articleDetailProvider(widget.slug)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentItem(BuildContext context, ArticleContent content) {
    switch (content.type) {
      case 'introduction':
        return _IntroductionWidget(content: content);
      case 'section':
        return _SectionWidget(content: content);
      case 'callout':
        return _CalloutWidget(content: content);
      case 'quote':
        return _QuoteWidget(content: content);
      case 'list':
        return _ListWidget(content: content);
      default:
        return const SizedBox.shrink();
    }
  }

  void _shareArticle(Article article) {
    Share.share(
      '${article.title}\n\n${article.subtitle}\n\nRead more on Destiny Decoder app!',
      subject: article.title,
    );
  }
}

class _ArticleMetadata extends StatelessWidget {
  final Article article;

  const _ArticleMetadata({required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle
        Text(
          article.subtitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),

        // Metadata row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(article.category),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatCategoryName(article.category),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${article.readTime} min read',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                article.author,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tags
        if (article.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: article.tags.map((tag) {
              return Chip(
                label: Text(tag),
                labelStyle: Theme.of(context).textTheme.labelSmall,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'basics':
        return Colors.blue;
      case 'life-seals':
        return Colors.purple;
      case 'cycles':
        return Colors.orange;
      case 'compatibility':
        return Colors.pink;
      case 'advanced':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String _formatCategoryName(String category) {
    return category.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class _IntroductionWidget extends StatelessWidget {
  final ArticleContent content;

  const _IntroductionWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: MarkdownBody(
        data: content.body ?? '',
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.6,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final ArticleContent content;

  const _SectionWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.heading != null) ...[
            Text(
              content.heading!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          MarkdownBody(
            data: content.body ?? '',
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              strong: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalloutWidget extends StatelessWidget {
  final ArticleContent content;

  const _CalloutWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    final style = content.style ?? 'info';
    final color = _getCalloutColor(style);
    final icon = _getCalloutIcon(style);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: MarkdownBody(
              data: content.body ?? '',
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                strong: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCalloutColor(String style) {
    switch (style) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getCalloutIcon(String style) {
    switch (style) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}

class _QuoteWidget extends StatelessWidget {
  final ArticleContent content;

  const _QuoteWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${content.text}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
          ),
          if (content.author != null) ...[
            const SizedBox(height: 8),
            Text(
              '— ${content.author}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListWidget extends StatelessWidget {
  final ArticleContent content;

  const _ListWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.heading != null) ...[
            Text(
              content.heading!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          ...?content.items?.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MarkdownBody(
                      data: item,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedArticlesSection extends ConsumerWidget {
  final String slug;

  const _RelatedArticlesSection({required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedArticlesProvider(slug));

    return relatedAsync.when(
      data: (articles) {
        if (articles.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Related Articles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...articles.map(
              (article) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${article.readTime} min read',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ArticleReaderPage(slug: article.slug),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
