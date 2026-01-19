import 'package:flutter/material.dart';

/// Example preview cards showing sample decode results
/// Gives users a taste of what they'll get before entering their birthdate
class ExampleDecodePreview extends StatelessWidget {
  final VoidCallback? onTryIt;

  const ExampleDecodePreview({
    super.key,
    this.onTryIt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Here\'s what you\'ll discover:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Example Life Seal Card
        _ExampleCard(
          icon: '🌟',
          title: 'Life Seal Number',
          subtitle: 'Your Core Life Purpose',
          exampleValue: '7',
          exampleDescription:
              'You are a spiritual seeker with deep analytical abilities.',
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Example Soul Number Card
        const _ExampleCard(
          icon: '✨',
          title: 'Soul Number',
          subtitle: 'Your Inner Desires',
          exampleValue: '3',
          exampleDescription:
              'You seek creative expression and joy in life.',
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
        ),
        const SizedBox(height: 12),

        // Example Personality Number Card
        const _ExampleCard(
          icon: '👤',
          title: 'Personality Number',
          subtitle: 'How Others See You',
          exampleValue: '5',
          exampleDescription:
              'You appear adventurous and free-spirited to others.',
          gradient: LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        ),
        const SizedBox(height: 16),

        if (onTryIt != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTryIt,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Try it with your birthdate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String exampleValue;
  final String exampleDescription;
  final Gradient gradient;

  const _ExampleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.exampleValue,
    required this.exampleDescription,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      exampleValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exampleDescription,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive feature showcase with tap to expand
class InteractiveFeatureCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final List<String> features;
  final Color? color;

  const InteractiveFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    this.color,
  });

  @override
  State<InteractiveFeatureCard> createState() =>
      _InteractiveFeatureCardState();
}

class _InteractiveFeatureCardState extends State<InteractiveFeatureCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: color,
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.features
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Before/After comparison to show value proposition
class BeforeAfterComparison extends StatelessWidget {
  const BeforeAfterComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Transform Your Self-Understanding',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: _ComparisonCard(
                title: 'Before',
                icon: '😕',
                color: Colors.grey,
                items: [
                  'Feeling lost',
                  'Unclear purpose',
                  'Relationship confusion',
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            Expanded(
              child: _ComparisonCard(
                title: 'After',
                icon: '✨',
                color: Theme.of(context).colorScheme.primary,
                items: const [
                  'Clear direction',
                  'Know your strengths',
                  'Better relationships',
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final List<String> items;

  const _ComparisonCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
