/// Share data models for Life Seal and article sharing
import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_models.freezed.dart';
part 'share_models.g.dart';

@freezed
class LifeSealShareData with _$LifeSealShareData {
  const factory LifeSealShareData({
    required int lifeSealNumber,
    required String lifeSealName,
    required String description,
    required String shareCode, // Unique code for referral tracking
    required DateTime generatedAt,
  }) = _LifeSealShareData;

  factory LifeSealShareData.fromJson(Map<String, dynamic> json) =>
      _$LifeSealShareDataFromJson(json);
}

@freezed
class ArticleShareData with _$ArticleShareData {
  const factory ArticleShareData({
    required String slug,
    required String title,
    required String category,
    required String shareCode,
  }) = _ArticleShareData;

  factory ArticleShareData.fromJson(Map<String, dynamic> json) =>
      _$ArticleShareDataFromJson(json);
}

/// Maps Life Seal numbers to names for sharing
class LifeSealNames {
  static const Map<int, String> names = {
    1: 'The Pioneer',
    2: 'The Diplomat',
    3: 'The Communicator',
    4: 'The Builder',
    5: 'The Freedom Seeker',
    6: 'The Nurturer',
    7: 'The Seeker',
    8: 'The Achiever',
    9: 'The Humanitarian',
  };

  static String getName(int number) => names[number] ?? 'Unknown';
}

/// Share content formatter
class ShareContentFormatter {
  /// Format Life Seal share message
  static String formatLifeSealShare(int lifeSealNumber, String description) {
    final name = LifeSealNames.getName(lifeSealNumber);
    return '''
🔮 My Life Seal: #$lifeSealNumber - $name

$description

Discover your unique numerological profile with Destiny Decoder! 
✨ Know yourself deeper
📊 Get personalized daily insights
🌟 Unlock your life's purpose

Download now and find YOUR Life Seal!
''';
  }

  /// Format article share message
  static String formatArticleShare(String title, String category) {
    return '''
📚 Just discovered this insightful article:

"$title"

Category: $category

Learn more about numerology and unlock personalized guidance with Destiny Decoder!
''';
  }
}
