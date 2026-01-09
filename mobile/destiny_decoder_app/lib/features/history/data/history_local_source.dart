import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/history_entry.dart';

class HistoryLocalSource {
  static const String _storageKey = 'history_entries_v1';
  static const int _maxEntries = 50;

  Future<List<HistoryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    
    // Parse entries and filter out corrupted/invalid ones
    final entries = <HistoryEntry>[];
    for (final entryString in raw) {
      try {
        final json = jsonDecode(entryString) as Map<String, dynamic>?;
        if (json == null) continue;
        
        final entry = HistoryEntry.fromJson(json);
        
        // Only keep entries that have valid result data
        if (entry.type == EntryType.decode && entry.decodeResult != null) {
          entries.add(entry);
        } else if (entry.type == EntryType.compatibility && entry.compatibilityResult != null) {
          entries.add(entry);
        }
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }
    
    return entries;
  }

  Future<void> saveEntries(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    // Trim to max entries, keeping newest first
    final trimmed = entries.take(_maxEntries).toList();
    final data = trimmed.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, data);
  }
}
