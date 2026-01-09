import 'package:share_plus/share_plus.dart';

/// Service for formatting and sharing reading data
class ShareService {
  /// Format decode result as shareable text
  static String formatDecodeReadingText(dynamic result) {
    final input = result.input;
    final lifeSeal = result.lifeSeal;
    final soulNumber = result.soulNumber;
    final personalityNumber = result.personalityNumber;
    final personalYear = result.personalYear;

    return '''
🌙 My Destiny Reading 🌙

Name: ${input.fullName}
Date of Birth: ${input.dateOfBirth}

═══════════════════════════════

📊 CORE NUMBERS

Life Seal: ${lifeSeal.number} (${lifeSeal.planet})
Soul Number: ${soulNumber.number}
Personality Number: ${personalityNumber.number}
Personal Year: ${personalYear.number}

═══════════════════════════════

✨ Discover your complete reading with the Destiny Decoder app!
🔗 Available on iOS and Android

Generated: ${DateTime.now().toString().split('.')[0]}
'''.trim();
  }

  /// Format compatibility result as shareable text
  static String formatCompatibilityReadingText(dynamic result) {
    final personA = result.personA;
    final personB = result.personB;
    final compatibility = result.compatibility;

    return '''
💕 Compatibility Analysis 💕

Person A: ${personA.input.fullName}
Life Seal: ${personA.interpretations.lifeSeal.number}
Soul Number: ${personA.interpretations.soulNumber.number}
Personality: ${personA.interpretations.personalityNumber.number}

Person B: ${personB.input.fullName}
Life Seal: ${personB.interpretations.lifeSeal.number}
Soul Number: ${personB.interpretations.soulNumber.number}
Personality: ${personB.interpretations.personalityNumber.number}

═══════════════════════════════

Overall Compatibility: ${compatibility.overall}
Life Seal Match: ${compatibility.lifeSeal}
Soul Harmony: ${compatibility.soulNumber}
Personality Balance: ${compatibility.personalityNumber}

═══════════════════════════════

✨ Check our full compatibility reading with the Destiny Decoder app!
🔗 Available on iOS and Android

Generated: ${DateTime.now().toString().split('.')[0]}
'''.trim();
  }

  /// Share reading with formatted text
  static Future<void> shareReading({
    required String text,
    String subject = 'My Destiny Reading',
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      throw Exception('Share failed: $e');
    }
  }

  /// Share reading with custom message
  static Future<void> shareReadingWithMessage({
    required String readingText,
    required String customMessage,
    String subject = 'Check out my reading!',
  }) async {
    try {
      final fullText = '$customMessage\n\n$readingText';
      await Share.share(
        fullText,
        subject: subject,
      );
    } catch (e) {
      throw Exception('Share failed: $e');
    }
  }

  /// Generate a summary card text (for display in dialog)
  static String generateReadingSummaryCard(dynamic result) {
    final input = result.input;
    final lifeSeal = result.lifeSeal;
    final soulNumber = result.soulNumber;
    final personalityNumber = result.personalityNumber;

    return '''${input.fullName}

Life Seal: ${lifeSeal.number} ${lifeSeal.planet}
Soul: ${soulNumber.number} | Personality: ${personalityNumber.number}''';
  }

  /// Generate compatibility summary card
  static String generateCompatibilitySummaryCard(dynamic result) {
    final personA = result.personA.input.fullName;
    final personB = result.personB.input.fullName;
    final overall = result.compatibility.overall;

    return '''$personA & $personB

Compatibility: $overall%''';
  }
}
