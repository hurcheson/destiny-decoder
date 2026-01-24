import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget to display enhanced, structured numerology interpretations
/// Replaces comma-separated text with organized categories and helpful explanations
class EnhancedInterpretationCard extends StatelessWidget {
  final Map<String, dynamic>? enhanced;
  final String? fallbackText;
  final Color accentColor;
  final bool isDarkMode;

  const EnhancedInterpretationCard({
    super.key,
    this.enhanced,
    this.fallbackText,
    required this.accentColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // If enhanced data is available, use it; otherwise fall back to plain text
    if (enhanced != null && enhanced!.isNotEmpty) {
      return _buildEnhancedContent(context);
    }
    
    return _buildFallbackContent(context);
  }

  Widget _buildEnhancedContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Essence
        if (enhanced!['title'] != null) ...[
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  enhanced!['title'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        
        // Essence - Brief overview
        if (enhanced!['essence'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    enhanced!['essence'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Strengths Section
        if (enhanced!['strengths'] != null && (enhanced!['strengths'] as List).isNotEmpty) ...[
          _buildSectionHeader(context, '💪', 'Key Strengths', Colors.green),
          const SizedBox(height: 8),
          ..._buildBulletList(context, enhanced!['strengths'] as List<dynamic>),
          const SizedBox(height: 16),
        ],
        
        // Opportunities Section
        if (enhanced!['opportunities'] != null && (enhanced!['opportunities'] as List).isNotEmpty) ...[
          _buildSectionHeader(context, '🌟', 'Opportunities', Colors.amber),
          const SizedBox(height: 8),
          ..._buildBulletList(context, enhanced!['opportunities'] as List<dynamic>),
          const SizedBox(height: 16),
        ],
        
        // Challenges Section
        if (enhanced!['challenges'] != null && (enhanced!['challenges'] as List).isNotEmpty) ...[
          _buildSectionHeader(context, '⚠️', 'Watch For', Colors.orange),
          const SizedBox(height: 8),
          ..._buildBulletList(context, enhanced!['challenges'] as List<dynamic>),
          const SizedBox(height: 16),
        ],
        
        // Guidance - Practical advice
        if (enhanced!['guidance'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: Colors.blue.shade400,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🧭',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guidance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enhanced!['guidance'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Special Note (if present)
        if (enhanced!['special_note'] != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Special Note',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enhanced!['special_note'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.5,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Compatibility Hint (if present)
        if (enhanced!['compatibility_hint'] != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.pink.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.favorite_outline,
                  color: Colors.pink.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Romantic Compatibility',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enhanced!['compatibility_hint'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.5,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackContent(BuildContext context) {
    if (fallbackText == null || fallbackText!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Text(
      fallbackText!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.5,
      ),
      softWrap: true,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String emoji, String title, Color color) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBulletList(BuildContext context, List<dynamic> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 28, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
