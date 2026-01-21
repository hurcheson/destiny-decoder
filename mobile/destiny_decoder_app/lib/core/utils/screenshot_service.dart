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
        fileName: fileName,
        androidRelativePath: 'Pictures/DestinyDecoder',
        skipIfExists: false,
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

      // Share the file using system share dialog
      // Note: SharePlus doesn't have shareXFiles, so we use Share() with XFile
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(file.path)],
        ),
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

  /// Capture a long screenshot from an arbitrary widget and save to gallery
  static Future<bool> saveLongToGallery({
    required BuildContext context,
    required Widget widget,
    required String fileName,
    double pixelRatio = 2.0,
  }) async {
    try {
      final controller = ScreenshotController();

      // Ensure the widget has proper inherited themes and width constraints
      final mediaQuery = MediaQuery.of(context);
      final themedWidget = InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.transparent,
          child: MediaQuery(
            data: mediaQuery,
            child: SizedBox(
              width: mediaQuery.size.width,
              child: widget,
            ),
          ),
        ),
      );

      final Uint8List imageBytes = await controller.captureFromWidget(
        themedWidget,
        pixelRatio: pixelRatio,
      );

      // Save directly to gallery using saver_gallery
      final result = await SaverGallery.saveImage(
        imageBytes,
        fileName: '$fileName.png',
        androidRelativePath: 'Pictures/DestinyDecoder',
        skipIfExists: false,
      );

      return result.isSuccess;
    } catch (e) {
      debugPrint('Error saving long screenshot: $e');
      rethrow;
    }
  }

  /// Capture a long screenshot from an arbitrary widget and share
  static Future<void> shareLongImage({
    required BuildContext context,
    required Widget widget,
    required String fileName,
    String? text,
    double pixelRatio = 2.0,
  }) async {
    try {
      final controller = ScreenshotController();

      // Ensure the widget has proper inherited themes and width constraints
      final mediaQuery = MediaQuery.of(context);
      final themedWidget = InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.transparent,
          child: MediaQuery(
            data: mediaQuery,
            child: SizedBox(
              width: mediaQuery.size.width,
              child: widget,
            ),
          ),
        ),
      );

      final Uint8List imageBytes = await controller.captureFromWidget(
        themedWidget,
        pixelRatio: pixelRatio,
      );

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$fileName.png').create();
      await file.writeAsBytes(imageBytes);

      // Share the file using system share dialog
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      debugPrint('Error sharing long screenshot: $e');
      rethrow;
    }
  }
}
