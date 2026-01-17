import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/screenshot_service.dart';
import '../../../core/utils/share_service.dart';
import 'decode_controller.dart';
import 'timeline.dart';
import 'widgets/cards.dart';
import 'widgets/animated_number.dart';
import 'widgets/export_dialog.dart';
import '../../history/presentation/history_controller.dart';
import '../../daily_insights/view/daily_insights_page.dart';

class DecodeResultPage extends ConsumerStatefulWidget {
  const DecodeResultPage({super.key});

  @override
  ConsumerState<DecodeResultPage> createState() => _DecodeResultPageState();
}

class _DecodeResultPageState extends ConsumerState<DecodeResultPage>
    with SingleTickerProviderStateMixin {
  final _overviewController = ScrollController();
  final _numbersController = ScrollController();
  final _timelineController = ScrollController();
  final _screenshotController = ScreenshotController();
  bool _isSaving = false;
  TabController? _tabController;

  @override
  void dispose() {
    _overviewController.dispose();
    _numbersController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  /// Refresh the current reading - reloads from stored result
  Future<void> _refreshReading() async {
    // Since we're already on the result page with data loaded,
    // a "refresh" scrolls to top and provides visual refresh feedback
    _scrollToTop();
    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Widget _wrapAnimated(Widget child, bool reduceMotion) {
    if (reduceMotion) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (widget, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.02, 0.02),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: widget),
        );
      },
      child: child,
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    bool isDarkMode,
    dynamic lifeSeal,
    AsyncValue<bool> exportState,
    dynamic result,
    ScrollController controller,
  ) {
    final accent = AppColors.getAccentColorForTheme(isDarkMode);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: 100, // Extra padding for FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AnimatedHeroNumberCard(
              number: lifeSeal.number,
              label: 'YOUR LIFE SEAL',
              subtitle: lifeSeal.planet,
              backgroundColor: AppColors.getPlanetColorForTheme(lifeSeal.number, isDarkMode),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Tap Export PDF anytime. Swipe tabs for Numbers and Timeline.',
            style: AppTypography.bodyMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              'Summary: Your Life Seal is ${lifeSeal.number} (${lifeSeal.planet}). Explore detailed interpretations under the Numbers tab.',
              style: AppTypography.bodySmall.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersTab(
    BuildContext context,
    bool isDarkMode,
    dynamic lifeSeal,
    dynamic soulNumber,
    dynamic personalityNumber,
    dynamic personalYear,
    dynamic result,
    ScrollController controller,
  ) {
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: 100, // Extra padding for FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Core Numbers',
            style: AppTypography.headingMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.md),
          StaggeredNumberGrid(
            isDarkMode: isDarkMode,
            items: [
              {
                'number': soulNumber.number,
                'label': 'Soul Number',
              },
              {
                'number': personalityNumber.number,
                'label': 'Personality',
              },
              {
                'number': personalYear.number,
                'label': 'Personal Year',
              },
              {
                'number': (result.core['physical_name_number'] as int?) ?? 0,
                'label': 'Physical Name',
              },
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Accordion sections
          _buildInterpretationAccordion(
            context,
            isDarkMode,
            lifeSeal.number,
            'Life Seal',
            lifeSeal.content,
            initiallyExpanded: true,
          ),
          _buildInterpretationAccordion(
            context,
            isDarkMode,
            soulNumber.number,
            'Soul Number',
            soulNumber.content,
          ),
          _buildInterpretationAccordion(
            context,
            isDarkMode,
            personalityNumber.number,
            'Personality Number',
            personalityNumber.content,
          ),
          _buildInterpretationAccordion(
            context,
            isDarkMode,
            personalYear.number,
            'Personal Year',
            personalYear.content,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(
    BuildContext context,
    bool isDarkMode,
    List<Map<String, dynamic>> lifeCycles,
    List<Map<String, dynamic>> turningPoints,
    String dateOfBirth,
    ScrollController controller,
  ) {
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: 100, // Extra padding for FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Life Journey',
            style: AppTypography.headingMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          LifeTimeline(
            lifeCycles: lifeCycles,
            turningPoints: turningPoints,
            currentAge: _calculateAge(dateOfBirth),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    // Get the current tab index from the tab controller
    final currentTabIndex = _tabController?.index ?? 0;
    
    ScrollController controller;
    switch (currentTabIndex) {
      case 1:
        controller = _numbersController;
        break;
      case 2:
        controller = _timelineController;
        break;
      default:
        controller = _overviewController;
    }
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildInterpretationAccordion(
    BuildContext context,
    bool isDarkMode,
    int number,
    String title,
    Map<String, dynamic> interpretation, {
    bool initiallyExpanded = false,
  }) {
    final color = AppColors.getPlanetColorForTheme(number, isDarkMode);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;
    final bg = color.withValues(alpha: isDarkMode ? 0.14 : 0.08);
    final border = color.withValues(alpha: isDarkMode ? 0.35 : 0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          title: Text(
            '$title: $number',
            style: AppTypography.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            if (interpretation.isNotEmpty) ...[
              Text(
                interpretation['title'] ?? '',
                style: AppTypography.headingSmall.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                interpretation['summary'] ?? '',
                style: AppTypography.bodyMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._buildBulletList(
                'Strengths',
                List<String>.from(interpretation['strengths'] ?? []),
                color,
                textColor,
              ),
              ..._buildBulletList(
                'Weaknesses',
                List<String>.from(interpretation['weaknesses'] ?? []),
                color,
                textColor,
              ),
              if (interpretation['spiritual_focus'] != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Spiritual Focus',
                  style: AppTypography.labelMedium.copyWith(color: color),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  interpretation['spiritual_focus'] ?? '',
                  style: AppTypography.bodySmall.copyWith(color: textColor),
                ),
              ],
            ] else ...[
              Text(
                'No detailed interpretation available',
                style: AppTypography.bodySmall.copyWith(color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decodeControllerProvider);
    final exportState = ref.watch(pdfExportStateProvider);
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final reduceMotion =
      MediaQuery.maybeOf(context)?.disableAnimations == true ||
        dispatcher.accessibilityFeatures.disableAnimations == true;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return state.when(
      data: (result) {
        if (result == null) {
          return const Scaffold(
            body: Center(child: Text('No result available.')),
          );
        }

        final lifeSeal = result.lifeSeal;
        final soulNumber = result.soulNumber;
        final personalityNumber = result.personalityNumber;
        final personalYear = result.personalYear;

        // Extract life cycles and turning points from core
        final lifeCycles = (result.core['life_cycles'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .toList() ??
            [];
        final turningPoints = (result.core['turning_points'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .toList() ??
            [];

        final isExporting = exportState.isLoading || (exportState.value ?? false);

        return DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              // Store reference to tab controller for scroll-to-top
              _tabController = DefaultTabController.of(context);

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Your Destiny'),
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  scrolledUnderElevation: 0,
                  bottom: TabBar(
                    indicatorColor: AppColors.getAccentColorForTheme(isDarkMode),
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Numbers'),
                      Tab(text: 'Timeline'),
                    ],
                  ),
                ),
                floatingActionButton: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'daily_insights',
                      onPressed: () {
                        final lifeSealNumber = lifeSeal.number;
                        final dayOfBirth = DateTime.parse(result.input.dateOfBirth).day;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DailyInsightsPage(
                              lifeSeal: lifeSealNumber,
                              dayOfBirth: dayOfBirth,
                              // If you want a specific date, pass ISO yyyy-MM-dd; else omit for today
                              // targetDate: DateTime.now().toIso8601String().split('T').first,
                            ),
                          ),
                        );
                      },
                      backgroundColor: AppColors.getAccentColorForTheme(isDarkMode),
                      foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.black,
                      icon: const Icon(Icons.today),
                      label: const Text('Daily Insights'),
                    ),
                    const SizedBox(height: 12),
                    EnhancedExportFAB(
                      isLoading: isExporting,
                      backgroundColor: AppColors.getAccentColorForTheme(isDarkMode),
                      foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.black,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ExportOptionsDialog(
                            isLoading: isExporting || _isSaving,
                            onExportPdf: () => _exportPdf(ref, result),
                            onSaveLocal: () => _saveReading(ref, result),
                            onSaveImage: () => _saveAsImage(result),
                            onShareImage: () => _shareAsImage(result),
                            onShareWithDetails: () => _shareWithDetails(result),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'back_to_top',
                      mini: true,
                      onPressed: _scrollToTop,
                      backgroundColor: AppColors.getPrimaryColorForTheme(isDarkMode),
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                body: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    color: Colors.white,
                    child: GradientContainer(
                      child: RefreshIndicator(
                        onRefresh: _refreshReading,
                        child: TabBarView(
                          children: [
                            _wrapAnimated(
                              _buildOverviewTab(
                                context,
                                isDarkMode,
                                lifeSeal,
                                exportState,
                                result,
                                _overviewController,
                              ),
                              reduceMotion,
                            ),
                            _wrapAnimated(
                              _buildNumbersTab(
                              context,
                              isDarkMode,
                              lifeSeal,
                              soulNumber,
                              personalityNumber,
                              personalYear,
                              result,
                              _numbersController,
                            ),
                            reduceMotion,
                          ),
                          _wrapAnimated(
                            _buildTimelineTab(
                              context,
                              isDarkMode,
                              lifeCycles,
                              turningPoints,
                              result.input.dateOfBirth,
                              _timelineController,
                            ),
                            reduceMotion,
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBulletList(
    String title,
    List<String> items,
    Color accentColor,
    Color textColor,
  ) {
    if (items.isEmpty) return [];

    return [
      const SizedBox(height: AppSpacing.md),
      Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: accentColor,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '●',
                style: TextStyle(color: accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: AppTypography.bodySmall.copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Calculate age from date of birth string (format: YYYY-MM-DD).
  int? _calculateAge(String dateOfBirth) {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Future<void> _exportPdf(
    WidgetRef ref,
    dynamic result,
  ) async {
    final exportStateNotifier = ref.read(pdfExportStateProvider.notifier);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Set loading state
      exportStateNotifier.state = const AsyncValue.loading();

      // Get controller and export PDF
      final controller = ref.read(decodeControllerProvider.notifier);
      final pdfBytes = await controller.exportPdf(
        fullName: result.input.fullName,
        dateOfBirth: result.input.dateOfBirth,
      );

      // Save file with user-chosen location
      final filePath = await _saveFileMobile(
        pdfBytes,
        'destiny_reading_${result.input.fullName.replaceAll(' ', '_')}.pdf',
      );

      if (!mounted) return;

      // Show success with file location and open button
      messenger.showSnackBar(
        SnackBar(
          content: Text('PDF saved to:\n$filePath'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              try {
                final uri = Uri.file(filePath);
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Could not open file'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Could not open file: $e'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Set success state
      exportStateNotifier.state = const AsyncValue.data(false);
    } catch (e) {
      // Set error state
      exportStateNotifier.state = AsyncValue.error(e, StackTrace.current);
      exportStateNotifier.state = const AsyncValue.data(false);

      // Show error message
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveReading(
    WidgetRef ref,
    dynamic result,
  ) async {
    if (_isSaving) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(historyControllerProvider.notifier).addFromResult(result);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Reading saved to history'),
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
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveAsImage(dynamic result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final fileName = ScreenshotService.generateFileName(
        result.input.fullName.replaceAll(' ', '_'),
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

  Future<void> _shareAsImage(dynamic result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final fileName = ScreenshotService.generateFileName(
        result.input.fullName.replaceAll(' ', '_'),
      );
      
      await ScreenshotService.shareImage(
        controller: _screenshotController,
        fileName: fileName,
        text: 'Check out my Destiny Decoder reading!',
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

  Future<void> _shareWithDetails(dynamic result) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final formattedText = ShareService.formatDecodeReadingText(result);
      await ShareService.shareReading(
        text: formattedText,
        subject: 'My Destiny Reading - ${result.input.fullName}',
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

  void _downloadFileWeb(List<int> bytes, String filename) {
    // For web platform - would need to use dart:html
    // Not implemented in this mobile-focused app
    throw UnsupportedError('Web download not implemented');
  }

  Future<String> _saveFileMobile(
    List<int> bytes,
    String filename,
  ) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile: Prefer the public Downloads folder so the user can access the file.
        final downloadsDir = await _resolveDownloadsDir();

        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsBytes(bytes);

        // Verify file was created with content
        if (!await file.exists()) {
          throw Exception('File was not created at: ${file.path}');
        }

        final fileSize = await file.length();
        if (fileSize == 0) {
          throw Exception('File was created but is empty (0 bytes)');
        }

        return file.path;
      } else {
        // On desktop: Use FilePicker to let user choose location
        final outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF Report',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          lockParentWindow: true,
        );

        if (outputPath == null) {
          throw Exception('Save cancelled by user');
        }

        // Write file to chosen location
        final file = File(outputPath);
        await file.writeAsBytes(bytes);

        // Verify file was actually created and has content
        if (!await file.exists()) {
          throw Exception('File was not created at: $outputPath');
        }

        final fileSize = await file.length();
        if (fileSize == 0) {
          throw Exception('File was created but is empty (0 bytes)');
        }

        return outputPath;
      }
    } catch (e) {
      throw Exception('Failed to save PDF: ${e.toString()}');
    }
  }

  // Try multiple candidate paths to land in a user-visible Downloads directory.
  Future<Directory> _resolveDownloadsDir() async {
    // Common public downloads paths first (more user-accessible on many Android devices).
    final candidates = <Directory>[
      Directory('/storage/emulated/0/Download'),
      Directory('/sdcard/Download'),
    ];

    for (final dir in candidates) {
      if (await dir.exists()) {
        return dir;
      }
      try {
        await dir.create(recursive: true);
        return dir;
      } catch (_) {
        // Continue trying other options.
      }
    }

    // Fallback: platform-provided downloads directory (may be app-scoped on some devices).
    final fallback = await getDownloadsDirectory();
    if (fallback != null) {
      return fallback;
    }

    throw Exception('Unable to access a Downloads folder');
  }
}
/// Staggered number grid with cascading animation
class StaggeredNumberGrid extends StatefulWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> items;

  const StaggeredNumberGrid({
    super.key,
    required this.isDarkMode,
    required this.items,
  });

  @override
  State<StaggeredNumberGrid> createState() => _StaggeredNumberGridState();
}

class _StaggeredNumberGridState extends State<StaggeredNumberGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List<AnimationController>.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
            ))
        .toList();

    // Stagger the animations with 100ms delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return FadeTransition(
          opacity: _animations[index],
          child: ScaleTransition(
            scale: _animations[index],
            child: NumberCard(
              number: item['number'] as int,
              label: item['label'] as String,
              backgroundColor: AppColors.getPlanetColorForTheme(
                item['number'] as int,
                widget.isDarkMode,
              ),
            ),
          ),
        );
      },
    );
  }
}