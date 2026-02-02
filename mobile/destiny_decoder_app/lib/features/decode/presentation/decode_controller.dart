import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/decode_repository.dart';
import '../data/decode_providers.dart';
import '../domain/decode_result.dart';

class DecodeController extends Notifier<AsyncValue<DecodeResult?>> {
  @override
  AsyncValue<DecodeResult?> build() => const AsyncValue.data(null);

  DecodeRepository get _repository => ref.read(decodeRepositoryProvider);

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
    String firstName = '',
  }) async {
    return _repository.exportPdf(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      firstName: firstName,
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  void setResult(DecodeResult result) {
    state = AsyncValue.data(result);
  }
}

final decodeControllerProvider =
    NotifierProvider<DecodeController, AsyncValue<DecodeResult?>>(DecodeController.new);

// State provider for tracking PDF export status
class PdfExportState extends Notifier<AsyncValue<bool>> {
  @override
  AsyncValue<bool> build() => const AsyncValue.data(false);
  
  void setLoading() {
    state = const AsyncValue.loading();
  }
  
  void setExporting(bool value) {
    state = AsyncValue.data(value);
  }
  
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

final pdfExportStateProvider = NotifierProvider<PdfExportState, AsyncValue<bool>>(PdfExportState.new);
