import 'package:uuid/uuid.dart';
import '../../compatibility/domain/compatibility_result.dart';
import '../../decode/domain/decode_result.dart';

enum EntryType { decode, compatibility }

class HistoryEntry {
  final String id;
  final DateTime savedAt;
  final EntryType type;
  final DecodeResult? decodeResult;
  final CompatibilityResult? compatibilityResult;

  HistoryEntry({
    required this.id,
    required this.savedAt,
    required this.type,
    this.decodeResult,
    this.compatibilityResult,
  });

  factory HistoryEntry.createFromDecode(DecodeResult result) {
    return HistoryEntry(
      id: const Uuid().v4(),
      savedAt: DateTime.now(),
      type: EntryType.decode,
      decodeResult: result,
    );
  }

  factory HistoryEntry.createFromCompatibility(CompatibilityResult result) {
    return HistoryEntry(
      id: const Uuid().v4(),
      savedAt: DateTime.now(),
      type: EntryType.compatibility,
      compatibilityResult: result,
    );
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = typeStr == 'compatibility' ? EntryType.compatibility : EntryType.decode;

    return HistoryEntry(
      id: json['id'] as String? ?? '',
      savedAt: DateTime.tryParse(json['saved_at'] as String? ?? '') ?? DateTime.now(),
      type: type,
      decodeResult: type == EntryType.decode && json['decode_result'] != null
          ? DecodeResult.fromJson(json['decode_result'] as Map<String, dynamic>)
          : null,
      compatibilityResult: type == EntryType.compatibility && json['compatibility_result'] != null
          ? CompatibilityResult.fromJson(json['compatibility_result'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saved_at': savedAt.toIso8601String(),
      'type': type == EntryType.compatibility ? 'compatibility' : 'decode',
      if (decodeResult != null) 'decode_result': decodeResult!.toJson(),
      if (compatibilityResult != null) 'compatibility_result': compatibilityResult!.toJson(),
    };
  }

  // Backward compatibility with old single-result format
  factory HistoryEntry.create(DecodeResult result) {
    return HistoryEntry.createFromDecode(result);
  }

  DecodeResult get result => decodeResult!;
}
