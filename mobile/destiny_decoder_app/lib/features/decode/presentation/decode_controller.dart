import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/decode_repository.dart';
import '../data/decode_providers.dart';
import '../domain/decode_result.dart';

class DecodeController extends StateNotifier<AsyncValue<DecodeResult?>> {
  DecodeController(this._repository) : super(const AsyncValue.data(null));

  final DecodeRepository _repository;

  Future<void> decode({
    required String fullName,
    required String dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.decodeFull(
        fullName: fullName,
        dateOfBirth: dateOfBirth,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<int>> exportPdf({
    required String fullName,
    required String dateOfBirth,
  }) async {
    return _repository.exportPdf(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final decodeControllerProvider =
    StateNotifierProvider<DecodeController, AsyncValue<DecodeResult?>>((ref) {
  final repository = ref.read(decodeRepositoryProvider);
  return DecodeController(repository);
});

// State provider for tracking PDF export status
final pdfExportStateProvider = StateProvider<AsyncValue<bool>>((ref) {
  return const AsyncValue.data(false);
});
