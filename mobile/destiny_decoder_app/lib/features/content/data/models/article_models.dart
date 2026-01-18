import 'package:equatable/equatable.dart';

/// Lightweight article model for list views
class ArticleListItem extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String category;
  final String author;
  final int readTime;
  final String publishedDate;
  final List<String> tags;
  final bool featured;
  final String? coverImage;
  final String contentPreview;

  const ArticleListItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.readTime,
    required this.publishedDate,
    required this.tags,
    required this.featured,
    this.coverImage,
    required this.contentPreview,
  });

  factory ArticleListItem.fromJson(Map<String, dynamic> json) {
    return ArticleListItem(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      readTime: json['readTime'] as int,
      publishedDate: json['publishedDate'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      featured: json['featured'] as bool,
      coverImage: json['coverImage'] as String?,
      contentPreview: json['contentPreview'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'author': author,
      'readTime': readTime,
      'publishedDate': publishedDate,
      'tags': tags,
      'featured': featured,
      'coverImage': coverImage,
      'contentPreview': contentPreview,
    };
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        subtitle,
        category,
        author,
        readTime,
        publishedDate,
        tags,
        featured,
        coverImage,
        contentPreview,
      ];
}

/// Article content item (section, callout, quote, etc.)
class ArticleContent extends Equatable {
  final String type;
  final String? heading;
  final String? body;
  final String? style;
  final String? text;
  final String? author;
  final List<String>? items;

  const ArticleContent({
    required this.type,
    this.heading,
    this.body,
    this.style,
    this.text,
    this.author,
    this.items,
  });

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      type: json['type'] as String,
      heading: json['heading'] as String?,
      body: json['body'] as String?,
      style: json['style'] as String?,
      text: json['text'] as String?,
      author: json['author'] as String?,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>).map((e) => e as String).toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [type, heading, body, style, text, author, items];
}

/// Full article model with content
class Article extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String category;
  final String author;
  final int readTime;
  final String publishedDate;
  final List<String> tags;
  final bool featured;
  final List<String> relatedArticles;
  final String? coverImage;
  final List<ArticleContent> content;

  const Article({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.readTime,
    required this.publishedDate,
    required this.tags,
    required this.featured,
    required this.relatedArticles,
    this.coverImage,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      readTime: json['readTime'] as int,
      publishedDate: json['publishedDate'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      featured: json['featured'] as bool,
      relatedArticles: (json['relatedArticles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      coverImage: json['coverImage'] as String?,
      content: (json['content'] as List<dynamic>)
          .map((e) => ArticleContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        subtitle,
        category,
        author,
        readTime,
        publishedDate,
        tags,
        featured,
        relatedArticles,
        coverImage,
        content,
      ];
}

/// Category info
class CategoryInfo extends Equatable {
  final String name;
  final int count;

  const CategoryInfo({
    required this.name,
    required this.count,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      name: json['name'] as String,
      count: json['count'] as int,
    );
  }

  @override
  List<Object?> get props => [name, count];
}
