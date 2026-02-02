import '../domain/decode_result.dart';
import 'decode_remote_source.dart';

class DecodeRepository {
  final DecodeRemoteSource _remoteSource;

  DecodeRepository(this._remoteSource);

  Future<DecodeResult> decodeFull({
    required String fullName,
    required String dateOfBirth,
  }) async {
    final json = await _remoteSource.decodeFull(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
    );

    return DecodeResult.fromJson(json);
  }

  Future<List<int>> exportPdf({
    required String fullName,
    required String dateOfBirth,
    String firstName = '',
  }) async {
    return _remoteSource.exportPdf(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      firstName: firstName,
    );
  }
}
