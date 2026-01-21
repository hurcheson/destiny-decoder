import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service to handle image-based sharing
class ShareImageService {
  /// Save image to temp directory and share with text
  static Future<void> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    required String shareText,
    String? subject,
  }) async {
    try {
      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');

      // Write image bytes to file
      await file.writeAsBytes(imageBytes);

      // Share with image and text
      // Note: SharePlus uses ShareParams with files property instead of shareXFiles
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          files: [XFile(file.path, mimeType: 'image/png')],
        ),
      );

      // Clean up after short delay (user has tapped share)
      Future.delayed(const Duration(seconds: 3), () {
        try {
          file.deleteSync();
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      throw Exception('Failed to share image: $e');
    }
  }

  /// Save image to gallery (for display purposes)
  static Future<String?> saveImageToTemp({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
