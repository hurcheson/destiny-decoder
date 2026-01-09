import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotService {
  /// Capture screenshot and save to gallery
  static Future<bool> saveToGallery({
    required ScreenshotController controller,
    required String fileName,
  }) async {
    try {
      // Capture screenshot
      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: 2.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save directly to gallery using saver_gallery
      final result = await SaverGallery.saveImage(
        imageBytes,
        name: '$fileName.png',
        androidRelativePath: 'Pictures/DestinyDecoder',
        androidExistNotSave: false,
      );

      return result.isSuccess;
    } catch (e) {
      debugPrint('Error saving screenshot: $e');
      rethrow;
    }
  }

  /// Capture screenshot and share
  static Future<void> shareImage({
    required ScreenshotController controller,
    required String fileName,
    String? text,
  }) async {
    try {
      // Capture screenshot
      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: 2.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$fileName.png').create();
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
      );
    } catch (e) {
      debugPrint('Error sharing screenshot: $e');
      rethrow;
    }
  }

  /// Generate a filename based on name and timestamp
  static String generateFileName(String prefix) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '${prefix}_$timestamp';
  }
}
