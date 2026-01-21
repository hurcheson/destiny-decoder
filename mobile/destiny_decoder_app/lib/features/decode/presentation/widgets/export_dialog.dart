import 'package:flutter/material.dart';

/// Enhanced export options dialog with multiple sharing methods
class ExportOptionsDialog extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback? onShare;
  final VoidCallback? onSaveLocal;
  final VoidCallback? onSaveImage;
  final VoidCallback? onShareImage;
  final VoidCallback? onShareWithDetails;
  final bool isLoading;

  const ExportOptionsDialog({
    super.key,
    required this.onExportPdf,
    this.onShare,
    this.onSaveLocal,
    this.onSaveImage,
    this.onShareImage,
    this.onShareWithDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primary = isDarkMode ? const Color(0xFF6B5B8A) : const Color(0xFF3F2F5E);
    final accent = isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFD4AF37);
    final textColor = isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF1A1A1A);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              isDarkMode
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFFAFAFA),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.share, color: accent, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Export Options',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how to export your reading',
                style: TextStyle(
                  fontSize: 14,
                  color: primary.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 24),

              // Export Options Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
              children: [
                // PDF Export
                _ExportOption(
                  icon: Icons.picture_as_pdf,
                  label: 'Export',
                  description: 'Professional 4-page report',
                  color: Colors.red,
                  isLoading: isLoading,
                  onTap: isLoading ? null : () {
                    Navigator.pop(context);
                    onExportPdf();
                  },
                ),

                // Share Option
                if (onShare != null)
                  _ExportOption(
                    icon: Icons.share,
                    label: 'Share Reading',
                    description: 'Send to friends & family',
                    color: accent,
                    isLoading: isLoading,
                    onTap: isLoading ? null : () {
                      Navigator.pop(context);
                      onShare!();
                    },
                  ),

                // Save Locally
                if (onSaveLocal != null)
                  _ExportOption(
                    icon: Icons.bookmark,
                    label: 'Save Reading',
                    description: 'Keep in your library',
                    color: primary,
                    isLoading: isLoading,
                    onTap: isLoading ? null : () {
                      Navigator.pop(context);
                      onSaveLocal!();
                    },
                  ),

                // Save as Image
                if (onSaveImage != null)
                  _ExportOption(
                    icon: Icons.image,
                    label: 'Save Full Page Image',
                    description: 'Save to photo gallery',
                    color: Colors.blue,
                    isLoading: isLoading,
                    onTap: isLoading ? null : () {
                      Navigator.pop(context);
                      onSaveImage!();
                    },
                  ),

                // Share as Image
                if (onShareImage != null)
                  _ExportOption(
                    icon: Icons.photo_camera,
                    label: 'Share Full Page Image',
                    description: 'Share as picture',
                    color: Colors.purple,
                    isLoading: isLoading,
                    onTap: isLoading ? null : () {
                      Navigator.pop(context);
                      onShareImage!();
                    },
                  ),

                // Share with Details
                if (onShareWithDetails != null)
                  _ExportOption(
                    icon: Icons.share_outlined,
                    label: 'Share Details',
                    description: 'With reading summary',
                    color: Colors.teal,
                    isLoading: isLoading,
                    onTap: isLoading ? null : () {
                      Navigator.pop(context);
                      onShareWithDetails!();
                    },
                  ),

                // Close option
                _ExportOption(
                  icon: Icons.close,
                  label: 'Close',
                  description: 'Return to reading',
                  color: Colors.grey,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your reading is generated fresh each time using your birth data.',
                      style: TextStyle(
                        fontSize: 12,
                        color: primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual export option tile
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color.withValues(alpha: isDarkMode ? 0.15 : 0.08);
    final borderColor = color.withValues(alpha: isDarkMode ? 0.35 : 0.25);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: bgColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Export FAB with better visual
class EnhancedExportFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const EnhancedExportFAB({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<EnhancedExportFAB> createState() => _EnhancedExportFABState();
}

class _EnhancedExportFABState extends State<EnhancedExportFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EnhancedExportFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        widget.backgroundColor ??
        (isDarkMode ? const Color(0xFF6B5B8A) : const Color(0xFF3F2F5E));
    final fgColor = widget.foregroundColor ?? Colors.white;

    return RotationTransition(
      turns: _controller,
      child: FloatingActionButton.extended(
        onPressed: widget.isLoading ? null : widget.onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: widget.isLoading ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(widget.isLoading ? Icons.hourglass_top : Icons.download),
        label: Text(
          widget.isLoading ? 'Exporting...' : 'Share',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
