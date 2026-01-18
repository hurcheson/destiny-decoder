/// Share helpers for Life Seal and articles (no code generation required)

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
  /// Optionally include an app landing URL if provided.
  static String formatLifeSealShare(
    int lifeSealNumber,
    String description, [
    String appShareUrl = '',
    String refCode = '',
  ]) {
    final name = LifeSealNames.getName(lifeSealNumber);
    final trimmedDesc = description.trim();

    String linkSection = '';
    if (appShareUrl.isNotEmpty) {
      final qp = refCode.isNotEmpty
          ? '?ref=$refCode&utm_source=share&utm_medium=app&utm_campaign=life_seal'
          : '?utm_source=share&utm_medium=app&utm_campaign=life_seal';
      linkSection = '\nGet the app: $appShareUrl$qp\n';
    }

    return '''
🔮 My Life Seal: #$lifeSealNumber - $name

$trimmedDesc

Discover your unique numerological profile with Destiny Decoder!
✨ Know yourself deeper
📊 Get personalized daily insights
🌟 Unlock your life's purpose

$linkSection'''.trim();
  }

  /// Format article share message
  /// Optionally include a direct article URL using slug if provided.
  static String formatArticleShare(
    String title,
    String category,
    String slug, [
    String appShareUrl = '',
    String refCode = '',
  ]) {
    final articleLink = appShareUrl.isNotEmpty
        ? () {
            final qp = refCode.isNotEmpty
                ? '?ref=$refCode&utm_source=share&utm_medium=app&utm_campaign=article'
                : '?utm_source=share&utm_medium=app&utm_campaign=article';
            return '\nRead it here: $appShareUrl/articles/$slug$qp\n';
          }()
        : '';

    return '''
📚 I just found this insightful article:

"$title"

Category: $category

${articleLink}Learn more about numerology and unlock personalized guidance with Destiny Decoder!'''.trim();
  }
}
