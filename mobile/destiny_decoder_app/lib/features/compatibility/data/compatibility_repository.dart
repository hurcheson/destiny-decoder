import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../domain/compatibility_result.dart';

class CompatibilityRepository {
  final Dio _dio;

  CompatibilityRepository(this._dio);

  Future<CompatibilityResult> calculateCompatibility({
    required String nameA,
    required String dobA,
    required String nameB,
    required String dobB,
  }) async {
    final datePartsA = dobA.split('-');
    final datePartsB = dobB.split('-');

    final response = await _dio.post(
      '/decode/compatibility',
      data: {
        'person_a': {
          'full_name': nameA,
          'year_of_birth': int.parse(datePartsA[0]),
          'month_of_birth': int.parse(datePartsA[1]),
          'day_of_birth': int.parse(datePartsA[2]),
        },
        'person_b': {
          'full_name': nameB,
          'year_of_birth': int.parse(datePartsB[0]),
          'month_of_birth': int.parse(datePartsB[1]),
          'day_of_birth': int.parse(datePartsB[2]),
        },
      },
    );

    return CompatibilityResult.fromJson(response.data);
  }

  Future<List<int>> exportPdf({
    required String nameA,
    required String dobA,
    required String nameB,
    required String dobB,
  }) async {
    final datePartsA = dobA.split('-');
    final datePartsB = dobB.split('-');

    final response = await _dio.post(
      '/export/compatibility/pdf',
      data: {
        'person_a': {
          'full_name': nameA,
          'year_of_birth': int.parse(datePartsA[0]),
          'month_of_birth': int.parse(datePartsA[1]),
          'day_of_birth': int.parse(datePartsA[2]),
        },
        'person_b': {
          'full_name': nameB,
          'year_of_birth': int.parse(datePartsB[0]),
          'month_of_birth': int.parse(datePartsB[1]),
          'day_of_birth': int.parse(datePartsB[2]),
        },
      },
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // response.data is already List<int> when using ResponseType.bytes
    if (response.data is List<int>) {
      return response.data as List<int>;
    } else if (response.data is Uint8List) {
      return response.data.toList();
    } else {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
  }
}
