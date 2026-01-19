import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../../core/config/app_config.dart';
import '../../../core/api/analytics_api_client.dart';
import '../../../core/utils/life_seal_card_generator.dart';
import '../../../core/utils/article_card_generator.dart';
import '../../../core/utils/share_image_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/share_models.dart';

class LifeSealShareWidget extends StatefulWidget {
  final int lifeSealNumber;
  final String lifeSealName;
  final String planet;
  final String description;
  final VoidCallback? onShare;

  const LifeSealShareWidget({
    super.key,
    required this.lifeSealNumber,
    required this.lifeSealName,
    required this.planet,
    required this.description,
    this.onShare,
  });

  @override
  State<LifeSealShareWidget> createState() => _LifeSealShareWidgetState();
}

class _LifeSealShareWidgetState extends State<LifeSealShareWidget> {
  bool _copiedToClipboard = false;
  bool _sharingImage = false;
  final _analyticsClient = AnalyticsApiClient();

  String _generateRefCode([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _shareViaSystem() async {
    final refCode = _generateRefCode();
    final shareText = ShareContentFormatter.formatLifeSealShare(
      widget.lifeSealNumber,
      widget.description,
      AppConfig.appShareUrl,
      refCode,
    );

    try {
      await Share.share(
        shareText,
        subject: 'My Life Seal: ${widget.lifeSealNumber} - ${widget.lifeSealName}',
      );
      widget.onShare?.call();
      // Track share event
      _analyticsClient.recordShareEvent(
        eventType: 'life_seal',
        lifeSealNumber: widget.lifeSealNumber,
        refCode: refCode,
      );    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _shareImageViaSystem() async {
    setState(() => _sharingImage = true);
    final refCode = _generateRefCode();
    
    try {
      final accentColor = AppColors.getPlanetColorForTheme(
        widget.lifeSealNumber,
        Theme.of(context).brightness == Brightness.dark,
      );
      
      final imageBytes = await LifeSealCardGenerator.generateLifeSealCard(
        lifeSealNumber: widget.lifeSealNumber,
        lifeSealName: widget.lifeSealName,
        planet: widget.planet,
        accentColor: accentColor,
      );

      if (imageBytes != null) {
        final shareText = ShareContentFormatter.formatLifeSealShare(
          widget.lifeSealNumber,
          widget.description,
          AppConfig.appShareUrl,
          refCode,
        );

        await ShareImageService.shareImage(
          imageBytes: imageBytes,
          fileName: 'life_seal_${widget.lifeSealNumber}_$refCode.png',
          shareText: shareText,
          subject: 'My Life Seal: ${widget.lifeSealNumber} - ${widget.lifeSealName}',
        );

        widget.onShare?.call();
        
        _analyticsClient.recordShareEvent(
          eventType: 'life_seal',
          lifeSealNumber: widget.lifeSealNumber,
          refCode: refCode,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Life Seal card shared!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Share image error: $e');
    } finally {
      if (mounted) {
        setState(() => _sharingImage = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final refCode = _generateRefCode();
    final shareText = ShareContentFormatter.formatLifeSealShare(
      widget.lifeSealNumber,
      widget.description,
      AppConfig.appShareUrl,
      refCode,
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
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onShare?.call();

    // Track copy event for Life Seal
    _analyticsClient.recordShareEvent(
      eventType: 'life_seal',
      lifeSealNumber: widget.lifeSealNumber,
      refCode: refCode,
    );
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sharingImage ? null : _shareImageViaSystem,
            icon: _sharingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image),
            label: Text(_sharingImage ? 'Generating...' : 'Share as Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
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
  final int readTime;
  final VoidCallback? onShare;

  const ArticleShareWidget({
    super.key,
    required this.title,
    required this.category,
    required this.slug,
    required this.readTime,
    this.onShare,
  });

  @override
  State<ArticleShareWidget> createState() => _ArticleShareWidgetState();
}

class _ArticleShareWidgetState extends State<ArticleShareWidget> {
  bool _copiedToClipboard = false;
  bool _sharingImage = false;
  final _analyticsClient = AnalyticsApiClient();

  String _generateRefCode([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _shareViaSystem() async {
    final refCode = _generateRefCode();
    final shareText = ShareContentFormatter.formatArticleShare(
      widget.title,
      widget.category,
      widget.slug,
      AppConfig.appShareUrl,
      refCode,
    );

    try {
      await Share.share(
        shareText,
        subject: widget.title,
      );
      widget.onShare?.call();
      // Track share event
      _analyticsClient.recordShareEvent(
        eventType: 'article',
        slug: widget.slug,
        refCode: refCode,
      );    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  Future<void> _shareImageViaSystem() async {
    setState(() => _sharingImage = true);
    final refCode = _generateRefCode();
    
    try {
      final categoryColor = _getCategoryColor(widget.category);
      
      final imageBytes = await ArticleCardGenerator.generateArticleCard(
        title: widget.title,
        category: widget.category,
        readTime: widget.readTime,
        categoryColor: categoryColor,
      );

      if (imageBytes != null) {
        final shareText = ShareContentFormatter.formatArticleShare(
          widget.title,
          widget.category,
          widget.slug,
          AppConfig.appShareUrl,
          refCode,
        );

        await ShareImageService.shareImage(
          imageBytes: imageBytes,
          fileName: '${widget.slug}_$refCode.png',
          shareText: shareText,
          subject: widget.title,
        );

        widget.onShare?.call();
        
        _analyticsClient.recordShareEvent(
          eventType: 'article',
          slug: widget.slug,
          refCode: refCode,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article card shared!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Share image error: $e');
    } finally {
      if (mounted) {
        setState(() => _sharingImage = false);
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'basics':
        return Colors.blue;
      case 'life-seals':
        return Colors.purple;
      case 'cycles':
        return Colors.orange;
      case 'compatibility':
        return Colors.pink;
      case 'advanced':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _copyToClipboard() async {
    final refCode = _generateRefCode();
    final shareText = ShareContentFormatter.formatArticleShare(
      widget.title,
      widget.category,
      widget.slug,
      AppConfig.appShareUrl,
      refCode,
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
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    widget.onShare?.call();

    // Track copy event for Article
    _analyticsClient.recordShareEvent(
      eventType: 'article',
      slug: widget.slug,
      refCode: refCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareViaSystem,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: Icon(_copiedToClipboard ? Icons.check : Icons.copy),
                label: Text(_copiedToClipboard ? 'Copied!' : 'Copy'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sharingImage ? null : _shareImageViaSystem,
            icon: _sharingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image),
            label: Text(_sharingImage ? 'Generating...' : 'Share Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
