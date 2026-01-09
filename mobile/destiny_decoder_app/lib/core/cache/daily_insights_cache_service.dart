import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with TTL support
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.ttl,
  }) : cachedAt = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));
}

/// Local cache service for daily insights, weekly previews, and blessed days
class DailyInsightsCacheService {
  static const String _keyPrefix = 'destiny.daily_insights.';
  static const Duration _defaultTtl = Duration(hours: 24);

  final SharedPreferencesAsync _prefs;

  DailyInsightsCacheService(this._prefs);

  /// Generate cache key from parameters
  String _cacheKey(String category, Map<String, dynamic> params) {
    final paramStr = params.entries
        .map((e) => '${e.key}=${e.value}')
        .toList()
        .join('&');
    return '$_keyPrefix$category:$paramStr';
  }

  /// Store data in cache with TTL
  Future<void> set<T>(
    String category,
    Map<String, dynamic> params,
    T data,
    String Function(T) toJson, {
    Duration? ttl,
  }) async {
    final key = _cacheKey(category, params);
    final entry = CacheEntry(
      data: data,
      ttl: ttl ?? _defaultTtl,
    );
    final json = jsonEncode({
      'data': toJson(data),
      'cachedAt': entry.cachedAt.toIso8601String(),
      'ttl': entry.ttl.inMilliseconds,
    });
    await _prefs.setString(key, json);
  }

  /// Retrieve data from cache if not expired
  Future<T?> get<T>(
    String category,
    Map<String, dynamic> params,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final key = _cacheKey(category, params);
    final cached = await _prefs.getString(key);
    if (cached == null) return null;

    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(json['cachedAt'] as String);
      final ttl = Duration(milliseconds: json['ttl'] as int);
      final isExpired = DateTime.now().isAfter(cachedAt.add(ttl));

      if (isExpired) {
        await _prefs.remove(key);
        return null;
      }

      return fromJson(json['data'] as Map<String, dynamic>);
    } catch (_) {
      // Corrupt cache; delete and return null
      await _prefs.remove(key);
      return null;
    }
  }

  /// Clear cache for a specific category or all cache
  Future<void> clear({String? category}) async {
    final prefs = await _prefs.getKeys();
    final keysToDelete = category != null
        ? prefs.where((k) => k.contains('$_keyPrefix$category'))
        : prefs.where((k) => k.startsWith(_keyPrefix));
    for (final key in keysToDelete) {
      await _prefs.remove(key);
    }
  }
}
