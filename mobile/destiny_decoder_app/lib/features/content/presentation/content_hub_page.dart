import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_providers.dart';
import '../data/models/article_models.dart';
import 'article_reader_page.dart';

class ContentHubPage extends ConsumerStatefulWidget {
  const ContentHubPage({super.key});

  @override
  ConsumerState<ContentHubPage> createState() => _ContentHubPageState();
}

class _ContentHubPageState extends ConsumerState<ContentHubPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(articleFiltersProvider);
    final articlesAsync = ref.watch(articlesProvider(filters));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Numerology'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(articleFiltersProvider.notifier).setSearch(null);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                ref.read(articleFiltersProvider.notifier).setSearch(
                      value.isEmpty ? null : value,
                    );
              },
            ),
          ),

          // Category tabs
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() => _selectedCategory = null);
                      ref.read(articleFiltersProvider.notifier).setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: _formatCategoryName(cat.name),
                        count: cat.count,
                        isSelected: _selectedCategory == cat.name,
                        onTap: () {
                          setState(() => _selectedCategory = cat.name);
                          ref.read(articleFiltersProvider.notifier).setCategory(cat.name);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(height: 50),
          ),

          const SizedBox(height: 8),

          // Articles list
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No articles found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                // Separate featured and regular articles
                final featuredArticles = articles.where((a) => a.featured).toList();
                final regularArticles = articles.where((a) => !a.featured).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(articlesProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Featured section
                      if (featuredArticles.isNotEmpty && _selectedCategory == null) ...[
                        Text(
                          'Featured',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...featuredArticles.map(
                          (article) => _ArticleCard(
                            article: article,
                            isFeatured: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Regular articles
                      if (regularArticles.isNotEmpty) ...[
                        if (featuredArticles.isNotEmpty && _selectedCategory == null)
                          Text(
                            'More Articles',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        if (featuredArticles.isNotEmpty && _selectedCategory == null)
                          const SizedBox(height: 12),
                        ...regularArticles.map(
                          (article) => _ArticleCard(article: article),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load articles',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(articlesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'basics':
        return 'Basics';
      case 'life-seals':
        return 'Life Seals';
      case 'cycles':
        return 'Cycles';
      case 'compatibility':
        return 'Compatibility';
      case 'advanced':
        return 'Advanced';
      default:
        return category;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        count != null ? '$label ($count)' : label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  final ArticleListItem article;
  final bool isFeatured;

  const _ArticleCard({
    required this.article,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(article.slug);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isFeatured ? 4 : 1,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticleReaderPage(slug: article.slug),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context, article.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatCategoryName(article.category),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Spacer(),
                  // Read time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTime} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Bookmark button
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      ref.read(bookmarksProvider.notifier).toggleBookmark(article.slug);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                article.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),

              // Preview
              Text(
                article.contentPreview,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (article.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: article.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) {
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
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'basics':
        return 'Basics';
      case 'life-seals':
        return 'Life Seals';
      case 'cycles':
        return 'Cycles';
      case 'compatibility':
        return 'Compatibility';
      case 'advanced':
        return 'Advanced';
      default:
        return category;
    }
  }
}
