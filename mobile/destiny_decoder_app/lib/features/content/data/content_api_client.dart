import 'package:dio/dio.dart';
import '../models/article_models.dart';

class ContentApiClient {
  final Dio _dio;
  final String baseUrl;

  ContentApiClient({
    required Dio dio,
    required this.baseUrl,
  }) : _dio = dio;

  /// Get all articles with optional filtering
  Future<List<ArticleListItem>> getArticles({
    String? category,
    List<String>? tags,
    bool? featured,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (category != null) queryParams['category'] = category;
    if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
    if (featured != null) queryParams['featured'] = featured;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get(
      '$baseUrl/content/articles',
      queryParameters: queryParams,
    );

    return (response.data as List)
        .map((json) => ArticleListItem.fromJson(json))
        .toList();
  }

  /// Get single article by slug
  Future<Article> getArticle(String slug) async {
    final response = await _dio.get('$baseUrl/content/articles/$slug');
    return Article.fromJson(response.data);
  }

  /// Get related articles
  Future<List<ArticleListItem>> getRelatedArticles(
    String slug, {
    int limit = 3,
  }) async {
    final response = await _dio.get(
      '$baseUrl/content/articles/$slug/related',
      queryParameters: {'limit': limit},
    );

    return (response.data as List)
        .map((json) => ArticleListItem.fromJson(json))
        .toList();
  }

  /// Get all categories
  Future<List<CategoryInfo>> getCategories() async {
    final response = await _dio.get('$baseUrl/content/categories');
    
    return (response.data as List)
        .map((json) => CategoryInfo.fromJson(json))
        .toList();
  }

  /// Get recommendations based on Life Seal
  Future<List<ArticleListItem>> getRecommendations(
    int lifeSeal, {
    int limit = 3,
  }) async {
    final response = await _dio.get(
      '$baseUrl/content/recommendations/$lifeSeal',
      queryParameters: {'limit': limit},
    );

    return (response.data as List)
        .map((json) => ArticleListItem.fromJson(json))
        .toList();
  }

  /// Track article view
  Future<void> trackArticleView(String slug) async {
    try {
      await _dio.post('$baseUrl/content/articles/$slug/view');
    } catch (e) {
      // Silently fail - analytics tracking shouldn't break UX
      print('Failed to track article view: $e');
    }
  }
}
