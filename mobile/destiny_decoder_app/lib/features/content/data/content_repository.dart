import '../data/content_api_client.dart';
import '../data/models/article_models.dart';

class ContentRepository {
  final ContentApiClient _apiClient;

  ContentRepository(this._apiClient);

  Future<List<ArticleListItem>> getArticles({
    String? category,
    List<String>? tags,
    bool? featured,
    String? search,
  }) async {
    return _apiClient.getArticles(
      category: category,
      tags: tags,
      featured: featured,
      search: search,
    );
  }

  Future<Article> getArticle(String slug) async {
    return _apiClient.getArticle(slug);
  }

  Future<List<ArticleListItem>> getRelatedArticles(
    String slug, {
    int limit = 3,
  }) async {
    return _apiClient.getRelatedArticles(slug, limit: limit);
  }

  Future<List<CategoryInfo>> getCategories() async {
    return _apiClient.getCategories();
  }

  Future<List<ArticleListItem>> getRecommendations(
    int lifeSeal, {
    int limit = 3,
  }) async {
    return _apiClient.getRecommendations(lifeSeal, limit: limit);
  }

  Future<void> trackArticleView(String slug) async {
    await _apiClient.trackArticleView(slug);
  }
}
