import '../../compatibility/domain/compatibility_result.dart';
import '../../decode/domain/decode_result.dart';
import '../domain/history_entry.dart';
import 'history_local_source.dart';

class HistoryRepository {
	final HistoryLocalSource _local;

	HistoryRepository(this._local);

	Future<List<HistoryEntry>> getHistory() async {
		final entries = await _local.loadEntries();
		// Sort newest first
		entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
		return entries;
	}

	Future<HistoryEntry> addEntry(DecodeResult result) async {
		final current = await getHistory();
		final entry = HistoryEntry.create(result);
		final updated = [entry, ...current];
		await _local.saveEntries(updated);
		return entry;
	}

	Future<HistoryEntry> addCompatibilityEntry(CompatibilityResult result) async {
		final current = await getHistory();
		final entry = HistoryEntry.createFromCompatibility(result);
		final updated = [entry, ...current];
		await _local.saveEntries(updated);
		return entry;
	}

	Future<void> deleteEntry(String id) async {
		final current = await getHistory();
		final updated = current.where((e) => e.id != id).toList();
		await _local.saveEntries(updated);
	}

	Future<void> clear() async {
		await _local.saveEntries([]);
	}
}