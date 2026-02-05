import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageTracker {
  static String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  static String _pdfExportsKey(DateTime date) =>
      'pdf_exports_${_monthKey(date)}';

  static Future<int> getPdfExportsThisMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _pdfExportsKey(DateTime.now());
    return prefs.getInt(key) ?? 0;
  }

  static Future<int> incrementPdfExports() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _pdfExportsKey(DateTime.now());
    final current = prefs.getInt(key) ?? 0;
    final next = current + 1;
    await prefs.setInt(key, next);
    return next;
  }
}

final pdfExportsThisMonthProvider = FutureProvider<int>((ref) async {
  return UsageTracker.getPdfExportsThisMonth();
});
