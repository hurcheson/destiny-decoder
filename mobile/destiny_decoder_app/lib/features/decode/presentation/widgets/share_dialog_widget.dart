import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sharing/providers/share_tracking_provider.dart';

/// Dialog widget for sharing decoded readings across social platforms.
/// Supports WhatsApp, Instagram, Twitter, and clipboard copy with
/// platform-specific URL schemes and share tracking.
class ShareDialogWidget extends ConsumerStatefulWidget {
  final int lifeSealNumber;
  final String keyTakeaway;
  final String shareText;
  final VoidCallback? onShareComplete;

  const ShareDialogWidget({
    super.key,
    required this.lifeSealNumber,
    required this.keyTakeaway,
    required this.shareText,
    this.onShareComplete,
  });

  @override
  ConsumerState<ShareDialogWidget> createState() => _ShareDialogWidgetState();
}

class _ShareDialogWidgetState extends ConsumerState<ShareDialogWidget> {
  bool _isSharing = false;


  /// Generate the share text that will be shared to social platforms.
  String _generateShareText() {
    return '''
Check out my Life Seal #${widget.lifeSealNumber} reading from Destiny Decoder!

KEY INSIGHT:
${widget.keyTakeaway}

${widget.shareText.isNotEmpty ? '\nFULL READING:\n${widget.shareText}' : ''}

Discover your destiny: https://destiny-decoder.app
'''.trim();
  }

  /// Share to WhatsApp using the URL scheme.
  Future<void> _shareToWhatsApp() async {
    try {
      _setSharing(true);
      final text = _generateShareText();
      final encodedText = Uri.encodeComponent(text);
      final whatsappUrl = Uri.parse("whatsapp://send?text=$encodedText");

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        _recordShare('whatsapp');
      } else {
        _showError('WhatsApp not installed');
      }
    } catch (e) {
      _showError('Failed to share to WhatsApp: $e');
    } finally {
      _setSharing(false);
    }
  }

  /// Share to Instagram via clipboard and system share.
  /// Note: Instagram doesn't support direct deep linking for share content,
  /// so we copy to clipboard and show instructions.
  Future<void> _shareToInstagram() async {
    try {
      _setSharing(true);
      final text = _generateShareText();
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: text));
      
      // Show snackbar with instructions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Copied to clipboard! Open Instagram to share'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Open Instagram',
              onPressed: () async {
                final instagramUrl = Uri.parse("https://www.instagram.com/");
                if (await canLaunchUrl(instagramUrl)) {
                  await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        );
      }
      
      _recordShare('instagram');
    } catch (e) {
      _showError('Failed to share to Instagram: $e');
    } finally {
      _setSharing(false);
    }
  }

  /// Share to Twitter using the web intent.
  Future<void> _shareToTwitter() async {
    try {
      _setSharing(true);
      final text = _generateShareText();
      final encodedText = Uri.encodeComponent(text);
      final twitterUrl = Uri.parse(
        "https://twitter.com/intent/tweet?text=$encodedText&url=https://destiny-decoder.app"
      );

      if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
        _recordShare('twitter');
      } else {
        _showError('Could not open Twitter');
      }
    } catch (e) {
      _showError('Failed to share to Twitter: $e');
    } finally {
      _setSharing(false);
    }
  }

  /// Copy share text to clipboard.
  Future<void> _copyToClipboard() async {
    try {
      _setSharing(true);
      final text = _generateShareText();
      await Clipboard.setData(ClipboardData(text: text));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      _recordShare('copy_clipboard');
    } catch (e) {
      _showError('Failed to copy: $e');
    } finally {
      _setSharing(false);
    }
  }

  /// Record the share event with backend tracking.
  /// Asynchronously logs the share to the backend API.
  void _recordShare(String platform) async {
    try {
      // Log share event to backend
      await ref.read(shareTrackingProvider.notifier).logShare(
        lifeSealNumber: widget.lifeSealNumber,
        platform: platform,
        shareText: widget.shareText,
      );
      
      if (mounted) {
        // Show confirmation after successful logging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share tracked! Thanks for sharing Life Seal #${widget.lifeSealNumber}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      // Log error but don't block the share - tracking is secondary to actual sharing
      if (mounted) {
        debugPrint('Failed to track share: $e');
      }
    } finally {
      widget.onShareComplete?.call();
    }
  }

  void _setSharing(bool value) {
    if (mounted) {
      setState(() => _isSharing = value);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Your Reading',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share Life Seal #${widget.lifeSealNumber} with your friends',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 24),

            // Share Buttons Grid
            _buildShareButton(
              icon: Icons.share,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onPressed: _isSharing ? null : _shareToWhatsApp,
            ),
            const SizedBox(height: 12),
            _buildShareButton(
              icon: Icons.camera_alt,
              label: 'Instagram',
              color: const Color(0xFFE1306C),
              onPressed: _isSharing ? null : _shareToInstagram,
            ),
            const SizedBox(height: 12),
            _buildShareButton(
              icon: Icons.message,
              label: 'Twitter',
              color: const Color(0xFF1DA1F2),
              onPressed: _isSharing ? null : _shareToTwitter,
            ),
            const SizedBox(height: 12),
            _buildShareButton(
              icon: Icons.content_copy,
              label: 'Copy to Clipboard',
              color: Colors.deepPurple,
              onPressed: _isSharing ? null : _copyToClipboard,
            ),

            const SizedBox(height: 20),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your reading is personalized to your Life Seal number and will help friends discover their own destiny.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[300],
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: _isSharing ? 0 : 4,
        ),
      ),
    );
  }
}
