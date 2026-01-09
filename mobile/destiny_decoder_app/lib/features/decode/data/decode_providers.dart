import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import 'decode_remote_source.dart';
import 'decode_repository.dart';

final decodeRemoteSourceProvider = Provider<DecodeRemoteSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return DecodeRemoteSource(apiClient);
});

final decodeRepositoryProvider = Provider<DecodeRepository>((ref) {
  final remoteSource = ref.read(decodeRemoteSourceProvider);
  return DecodeRepository(remoteSource);
});
