import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../data/content_api_client.dart';
import '../data/content_repository.dart';
import '../data/models/article_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API Client Provider
final contentApiClientProvider = Provider<ContentApiClient>((ref) {
  final dio = Dio();
  return ContentApiClient(
    dio: dio,
    baseUrl: AppConfig.apiBaseUrl,
  );
});

// Repository Provider
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final apiClient = ref.watch(contentApiClientProvider);
  return ContentRepository(apiClient);
});

// Articles List Provider (with filters)
final articlesProvider = FutureProvider.family<List<ArticleListItem>, ArticleFilters>(
  (ref, filters) async {
    final repository = ref.watch(contentRepositoryProvider);
    return repository.getArticles(
      category: filters.category,
      tags: filters.tags,
      featured: filters.featured,
      search: filters.search,
    );
  },
);

// Single Article Provider
final articleDetailProvider = FutureProvider.family<Article, String>(
  (ref, slug) async {
    final repository = ref.watch(contentRepositoryProvider);
    return repository.getArticle(slug);
  },
);

// Related Articles Provider
final relatedArticlesProvider = FutureProvider.family<List<ArticleListItem>, String>(
  (ref, slug) async {
    final repository = ref.watch(contentRepositoryProvider);
    return repository.getRelatedArticles(slug);
  },
);

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryInfo>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getCategories();
});

// Recommendations Provider
final recommendationsProvider = FutureProvider.family<List<ArticleListItem>, int>(
  (ref, lifeSeal) async {
    final repository = ref.watch(contentRepositoryProvider);
    return repository.getRecommendations(lifeSeal);
  },
);

// Search/Filter State Provider
final articleFiltersProvider = NotifierProvider<ArticleFiltersNotifier, ArticleFilters>(
  ArticleFiltersNotifier.new,
);

class ArticleFiltersNotifier extends Notifier<ArticleFilters> {
  @override
  ArticleFilters build() => const ArticleFilters();

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search);
  }

  void setFeatured(bool? featured) {
    state = state.copyWith(featured: featured);
  }

  void setTags(List<String>? tags) {
    state = state.copyWith(tags: tags);
  }

  void reset() {
    state = const ArticleFilters();
  }
}

class ArticleFilters {
  final String? category;
  final String? search;
  final bool? featured;
  final List<String>? tags;

  const ArticleFilters({
    this.category,
    this.search,
    this.featured,
    this.tags,
  });

  ArticleFilters copyWith({
    String? category,
    String? search,
    bool? featured,
    List<String>? tags,
  }) {
    return ArticleFilters(
      category: category ?? this.category,
      search: search ?? this.search,
      featured: featured ?? this.featured,
      tags: tags ?? this.tags,
    );
  }
}

// Bookmarks Provider (using SharedPreferences for persistence)
final bookmarksProvider = NotifierProvider<BookmarksNotifier, Set<String>>(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadBookmarks();
    return {};
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('article_bookmarks') ?? [];
    state = bookmarks.toSet();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('article_bookmarks', state.toList());
  }

  void toggleBookmark(String slug) {
    if (state.contains(slug)) {
      state = Set<String>.from(state)..remove(slug);
    } else {
      state = {...state, slug};
    }
    _saveBookmarks();
  }

  bool isBookmarked(String slug) {
    return state.contains(slug);
  }
}

// View tracking helper
void trackArticleView(WidgetRef ref, String slug) {
  final repository = ref.read(contentRepositoryProvider);
  repository.trackArticleView(slug);
}
