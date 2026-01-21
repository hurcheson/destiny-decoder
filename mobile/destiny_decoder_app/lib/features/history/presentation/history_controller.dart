import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../compatibility/domain/compatibility_result.dart';
import '../../decode/domain/decode_result.dart';
import '../data/history_providers.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';

class HistoryController extends Notifier<AsyncValue<List<HistoryEntry>>> {
  @override
  AsyncValue<List<HistoryEntry>> build() {
    _load();
    return const AsyncValue.loading();
  }

  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  Future<void> _load() async {
    try {
      final entries = await _repository.getHistory();
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => _load();

  Future<void> addFromResult(DecodeResult result) async {
    try {
      final current = state.value ?? const <HistoryEntry>[];
      final newEntry = await _repository.addEntry(result);
      state = AsyncValue.data([newEntry, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFromCompatibility(CompatibilityResult result) async {
    try {
      final current = state.value ?? const <HistoryEntry>[];
      final newEntry = await _repository.addCompatibilityEntry(result);
      state = AsyncValue.data([newEntry, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.deleteEntry(id);
      final current = state.value ?? const <HistoryEntry>[];
      state = AsyncValue.data(current.where((e) => e.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clear() async {
    try {
      await _repository.clear();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final historyControllerProvider =
    NotifierProvider<HistoryController, AsyncValue<List<HistoryEntry>>>(HistoryController.new);
