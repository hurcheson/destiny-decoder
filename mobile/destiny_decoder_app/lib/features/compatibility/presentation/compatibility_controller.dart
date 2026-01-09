import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/compatibility_providers.dart';
import '../data/compatibility_repository.dart';
import '../domain/compatibility_result.dart';

class CompatibilityController extends StateNotifier<AsyncValue<CompatibilityResult?>> {
  CompatibilityController(this._repository) : super(const AsyncValue.data(null));

  final CompatibilityRepository _repository;

  Future<void> calculateCompatibility({
    required String nameA,
    required String dobA,
    required String nameB,
    required String dobB,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.calculateCompatibility(
        nameA: nameA,
        dobA: dobA,
        nameB: nameB,
        dobB: dobB,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  void setResult(CompatibilityResult result) {
    state = AsyncValue.data(result);
  }
}

final compatibilityControllerProvider =
    StateNotifierProvider<CompatibilityController, AsyncValue<CompatibilityResult?>>((ref) {
  final repository = ref.read(compatibilityRepositoryProvider);
  return CompatibilityController(repository);
});
