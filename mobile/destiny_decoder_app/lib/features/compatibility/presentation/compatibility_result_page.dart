import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client_provider.dart';
import '../../../core/utils/screenshot_service.dart';
import '../../../core/utils/share_service.dart';
import '../../decode/presentation/widgets/cards.dart';
import '../../decode/presentation/widgets/export_dialog.dart';
import '../../history/presentation/history_controller.dart';
import '../domain/compatibility_result.dart';
import '../data/compatibility_repository.dart';
import 'compatibility_controller.dart';

class CompatibilityResultPage extends ConsumerStatefulWidget {
  const CompatibilityResultPage({super.key});

  @override
  ConsumerState<CompatibilityResultPage> createState() => _CompatibilityResultPageState();
}

class _CompatibilityResultPageState extends ConsumerState<CompatibilityResultPage> {
  final _screenshotController = ScreenshotController();
  bool _isSaving = false;
  bool _isExporting = false;

  /// Refresh the compatibility reading - provides visual refresh feedback
  Future<void> _refreshReading() async {
    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _saveReading(WidgetRef ref, CompatibilityResult result) async {
    if (_isSaving) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      await ref.read(historyControllerProvider.notifier).addFromCompatibility(result);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Compatibility saved to history'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _exportPdf(WidgetRef ref, CompatibilityResult result) async {
    if (_isExporting) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isExporting = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = CompatibilityRepository(apiClient.dio);
      final pdfBytes = await repository.exportPdf(
        nameA: result.personA.input.fullName,
        dobA: result.personA.input.dateOfBirth,
        nameB: result.personB.input.fullName,
        dobB: result.personB.input.dateOfBirth,
      );

      // Save file using same method as decode
      if (kIsWeb) {
        _downloadFileWeb(pdfBytes, 'compatibility-report.pdf');
      } else {
        final filePath = await _saveFileMobile(pdfBytes, 'compatibility-report.pdf');
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('PDF exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _downloadFileWeb(List<int> bytes, String filename) {
    throw UnsupportedError('Web download not implemented');
  }

  Future<String> _saveFileMobile(List<int> bytes, String filename) async {
    try {
      // On mobile (Android/iOS), save directly to Downloads folder
      if (Platform.isAndroid || Platform.isIOS) {
        // Get the Downloads directory
        final downloadDir = await getDownloadsDirectory();
        if (downloadDir == null) {
          throw Exception('Unable to access Downloads folder');
        }
        
        // Create file in Downloads folder
        final file = File('${downloadDir.path}/$filename');
        await file.writeAsBytes(bytes);
        
        return '${downloadDir.path}/$filename';
      } else {
        // On desktop (Windows/macOS/Linux), use file picker
        final outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputPath == null) {
          throw Exception('Save cancelled by user');
        }

        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        return outputPath;
      }
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> _saveAsImage(CompatibilityResult result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final fileName = ScreenshotService.generateFileName(
        'compatibility_${result.personA.input.fullName}_${result.personB.input.fullName}'
          .replaceAll(' ', '_'),
      );
      
      final success = await ScreenshotService.saveToGallery(
        controller: _screenshotController,
        fileName: fileName,
      );
      
      if (!mounted) return;
      
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareAsImage(CompatibilityResult result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final fileName = ScreenshotService.generateFileName(
        'compatibility_${result.personA.input.fullName}_${result.personB.input.fullName}'
          .replaceAll(' ', '_'),
      );
      
      await ScreenshotService.shareImage(
        controller: _screenshotController,
        fileName: fileName,
        text: 'Check out our compatibility analysis!',
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Share failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareWithDetails(CompatibilityResult result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final formattedText = ShareService.formatCompatibilityReadingText(result);
      await ShareService.shareReading(
        text: formattedText,
        subject: 'Compatibility Analysis - ${result.personA.input.fullName} & ${result.personB.input.fullName}',
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Share failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compatibilityControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return state.when(
      data: (result) {
        if (result == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Compatibility')),
            body: const Center(child: Text('No data')),
          );
        }

        final compat = result.compatibility;
        final personA = result.personA;
        final personB = result.personB;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Compatibility Analysis'),
          ),
          body: Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Colors.white,
              child: GradientContainer(
                child: RefreshIndicator(
                  onRefresh: _refreshReading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overall compatibility score
                  Card(
                    elevation: AppElevation.lg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCompatibilityColor(compat.overall, isDarkMode)
                                .withValues(alpha: 0.2),
                            _getCompatibilityColor(compat.overall, isDarkMode)
                                .withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getCompatibilityIcon(compat.overall),
                            size: 64,
                            color: _getCompatibilityColor(compat.overall, isDarkMode),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            compat.overall,
                            style: AppTypography.headingLarge.copyWith(
                              color: _getCompatibilityColor(compat.overall, isDarkMode),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${compat.score} / ${compat.maxScore} points',
                            style: AppTypography.bodyLarge.copyWith(
                              color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LinearProgressIndicator(
                            value: compat.percentage / 100,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(
                              _getCompatibilityColor(compat.overall, isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Detailed scores
                  Text(
                    'Compatibility Breakdown',
                    style: AppTypography.headingMedium.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _CompatibilityMetric(
                    label: 'Life Path Compatibility',
                    value: compat.lifeSeal,
                    isDarkMode: isDarkMode,
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _CompatibilityMetric(
                    label: 'Soul Connection',
                    value: compat.soulNumber,
                    isDarkMode: isDarkMode,
                    icon: Icons.favorite,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _CompatibilityMetric(
                    label: 'Personality Match',
                    value: compat.personalityNumber,
                    isDarkMode: isDarkMode,
                    icon: Icons.people,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Side-by-side comparison
                  Text(
                    'Individual Profiles',
                    style: AppTypography.headingMedium.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PersonCard(
                          person: personA,
                          label: 'Person A',
                          color: AppColors.primary,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _PersonCard(
                          person: personB,
                          label: 'Person B',
                          color: AppColors.accent,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),
                ],
              ),
            ),
          ),
        ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: (_isSaving || _isExporting) ? null : () {
              showDialog(
                context: context,
                builder: (context) => ExportOptionsDialog(
                  isLoading: _isSaving || _isExporting,
                  onExportPdf: () => _exportPdf(ref, result),
                  onSaveLocal: () => _saveReading(ref, result),
                  onSaveImage: () => _saveAsImage(result),
                  onShareImage: () => _shareAsImage(result),
                  onShareWithDetails: () => _shareWithDetails(result),
                ),
              );
            },
            backgroundColor: AppColors.getAccentColorForTheme(isDarkMode),
            foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.black,
            icon: (_isSaving || _isExporting)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  )
                : const Icon(Icons.share),
            label: Text(
              _isSaving ? 'Saving...' : _isExporting ? 'Exporting...' : 'Share',
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Compatibility')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Compatibility')),
        body: Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Color _getCompatibilityColor(String level, bool isDark) {
    switch (level) {
      case 'Highly Compatible':
        return Colors.green;
      case 'Compatible':
      case 'Moderately Compatible':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getCompatibilityIcon(String level) {
    switch (level) {
      case 'Highly Compatible':
        return Icons.favorite;
      case 'Compatible':
      case 'Moderately Compatible':
        return Icons.thumb_up;
      default:
        return Icons.info_outline;
    }
  }
}

class _CompatibilityMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;
  final IconData icon;

  const _CompatibilityMetric({
    required this.label,
    required this.value,
    required this.isDarkMode,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(value);
    
    return Card(
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.bodyLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String value) {
    switch (value) {
      case 'Very Strong':
        return Colors.green;
      case 'Compatible':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

class _PersonCard extends StatelessWidget {
  final PersonReading person;
  final String label;
  final Color color;
  final bool isDarkMode;

  const _PersonCard({
    required this.person,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return Card(
      elevation: AppElevation.md,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              person.input.fullName,
              style: AppTypography.headingSmall.copyWith(
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            _NumberRow(
              label: 'Life Seal',
              value: person.interpretations.lifeSeal.number,
              color: color,
            ),
            _NumberRow(
              label: 'Soul',
              value: person.interpretations.soulNumber.number,
              color: color,
            ),
            _NumberRow(
              label: 'Personality',
              value: person.interpretations.personalityNumber.number,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _NumberRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              value.toString(),
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
