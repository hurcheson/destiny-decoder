import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'history_local_source.dart';
import 'history_repository.dart';

final historyLocalSourceProvider = Provider<HistoryLocalSource>((ref) {
  return HistoryLocalSource();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final local = ref.read(historyLocalSourceProvider);
  return HistoryRepository(local);
});
