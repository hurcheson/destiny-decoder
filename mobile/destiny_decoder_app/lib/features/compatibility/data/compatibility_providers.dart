import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client_provider.dart';
import 'compatibility_repository.dart';

final compatibilityRepositoryProvider = Provider<CompatibilityRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CompatibilityRepository(apiClient.dio);
});
