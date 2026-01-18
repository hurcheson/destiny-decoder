import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/share_models.dart';

class LifeSealShareWidget extends StatefulWidget {
  final int lifeSealNumber;
  final String lifeSealName;
  final String description;
  final VoidCallback? onShare;

  const LifeSealShareWidget({
    super.key,
    required this.lifeSealNumber,
    required this.lifeSealName,
    required this.description,
    this.onShare,
  });

  @override
  State<LifeSealShareWidget> createState() => _LifeSealShareWidgetState();
}

class _LifeSealShareWidgetState extends State<LifeSealShareWidget> {
  bool _copiedToClipboard = false;

  Future<void> _shareViaSystem() async {
    final shareText = ShareContentFormatter.formatLifeSealShare(
      widget.lifeSealNumber,
      widget.description,
    );

    try {
      await Share.share(
        shareText,
        subject: 'My Life Seal: ${widget.lifeSealNumber} - ${widget.lifeSealName}',
      );
      widget.onShare?.call();
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _copyToClipboard() async {
    final shareText = ShareContentFormatter.formatLifeSealShare(
      widget.lifeSealNumber,
      widget.description,
    );

    await Clipboard.setData(ClipboardData(text: shareText));

    setState(() => _copiedToClipboard = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedToClipboard = false);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onShare?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),
        Text(
          'Share Your Life Seal',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Let others discover their own Life Seal journey',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareViaSystem,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: Icon(_copiedToClipboard ? Icons.check : Icons.copy),
                label: Text(_copiedToClipboard ? 'Copied!' : 'Copy'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ArticleShareWidget extends StatefulWidget {
  final String title;
  final String category;
  final String slug;
  final VoidCallback? onShare;

  const ArticleShareWidget({
    super.key,
    required this.title,
    required this.category,
    required this.slug,
    this.onShare,
  });

  @override
  State<ArticleShareWidget> createState() => _ArticleShareWidgetState();
}

class _ArticleShareWidgetState extends State<ArticleShareWidget> {
  bool _copiedToClipboard = false;

  Future<void> _shareViaSystem() async {
    final shareText = ShareContentFormatter.formatArticleShare(
      widget.title,
      widget.category,
    );

    try {
      await Share.share(
        shareText,
        subject: widget.title,
      );
      widget.onShare?.call();
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _copyToClipboard() async {
    final shareText = ShareContentFormatter.formatArticleShare(
      widget.title,
      widget.category,
    );

    await Clipboard.setData(ClipboardData(text: shareText));

    setState(() => _copiedToClipboard = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedToClipboard = false);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onShare?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareViaSystem,
            icon: const Icon(Icons.share),
            label: const Text('Share Article'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _copyToClipboard,
          icon: Icon(_copiedToClipboard ? Icons.check : Icons.copy),
          label: Text(_copiedToClipboard ? 'Copied!' : 'Copy'),
        ),
      ],
    );
  }
}
