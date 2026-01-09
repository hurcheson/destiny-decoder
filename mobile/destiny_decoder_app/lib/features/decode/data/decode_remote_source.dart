import '../../../core/network/api_client.dart';

class DecodeRemoteSource {
  final ApiClient _apiClient;

  DecodeRemoteSource(this._apiClient);

  Future<Map<String, dynamic>> decodeFull({
    required String fullName,
    required String dateOfBirth,
  }) async {
    final parts = dateOfBirth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }

    final firstName = fullName.split(' ').first;

    return _apiClient.post(
      '/decode/full',
      data: {
        'full_name': fullName,
        'first_name': firstName,
        'day_of_birth': day,
        'month_of_birth': month,
        'year_of_birth': year,
        'age': age,
      },
    );
  }

  Future<List<int>> exportPdf({
    required String fullName,
    required String dateOfBirth,
  }) async {
    // First get the full decode data
    final decodeData = await decodeFull(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
    );

    // Then send to export endpoint
    return _apiClient.downloadFile(
      '/export/pdf',
      data: {
        'full_name': fullName,
        'date_of_birth': dateOfBirth,
        'decode_data': decodeData,
      },
    );
  }
}
