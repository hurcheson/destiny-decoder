import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// TIER 3: Enhanced Timeline Visualization with Interactive Storytelling
/// Features:
/// - Vertical journey timeline with connecting paths
/// - Visual metaphors (sprout → growth → harvest)
/// - Interactive phase exploration with smooth animations
/// - Current age indicator with pulsing animation
/// - Gradient progression showing life journey
/// - Planet-color coded phases
/// - Turning point markers with symbolic icons

class LifeTimeline extends StatefulWidget {
  final List<Map<String, dynamic>> lifeCycles;
  final List<Map<String, dynamic>> turningPoints;
  final int? currentAge;

  const LifeTimeline({
    super.key,
    required this.lifeCycles,
    required this.turningPoints,
    this.currentAge,
  });

  @override
  State<LifeTimeline> createState() => _LifeTimelineState();
}

class _LifeTimelineState extends State<LifeTimeline> with TickerProviderStateMixin {
  int? selectedLifeCycleIndex;
  int? selectedTurningPointIndex;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulsing animation for current age indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentPhase = _getCurrentPhaseLabel();
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;
    final accentColor = AppColors.getAccentColorForTheme(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current phase indicator (enhanced)
        if (currentPhase.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: accentColor, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'You are in your $currentPhase phase${widget.currentAge != null ? " (Age ${widget.currentAge})" : ""}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Vertical Journey Timeline (Tier 3 Enhancement)
        _buildVerticalJourneyTimeline(context, isDarkMode),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Detail panel with smooth animations and constraints
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildDetailPanel(context, isDarkMode),
          ),
        ),
      ],
    );
  }

  /// Determine current phase label if age is available.
  String _getCurrentPhaseLabel() {
    if (widget.currentAge == null || widget.lifeCycles.isEmpty) {
      return '';
    }

    final age = widget.currentAge!;
    final labels = ['Formative', 'Establishment', 'Fruit'];

    // Determine which phase based on age ranges in life cycles
    for (int i = 0; i < widget.lifeCycles.length; i++) {
      final cycle = widget.lifeCycles[i];
      final ageRange = cycle['age_range'] as String?;

      if (ageRange != null && _isInAgeRange(age, ageRange)) {
        return labels.isNotEmpty && i < labels.length ? labels[i] : '';
      }
    }
    return '';
  }

  /// TIER 3: Vertical Journey Timeline with Visual Metaphors
  Widget _buildVerticalJourneyTimeline(BuildContext context, bool isDarkMode) {
    // Visual metaphors for life phases
    final phaseIcons = [
      Icons.wb_sunny, // Sun/Dawn - Beginning
      Icons.trending_up, // Growth/Establishment
      Icons.spa, // Harvest/Wisdom
    ];
    
    final phaseEmojis = ['🌱', '🌳', '🍎']; // Sprout → Tree → Fruit
    
    return Column(
      children: List.generate(widget.lifeCycles.length, (index) {
        final cycle = widget.lifeCycles[index];
        final number = cycle['number'] as int?;
        final ageRange = cycle['age_range'] as String?;
        final isSelected = selectedLifeCycleIndex == index;
        final isCurrentPhase = widget.currentAge != null && 
                               ageRange != null && 
                               _isInAgeRange(widget.currentAge!, ageRange);
        
        final planetColor = AppColors.getPlanetColorForTheme(number ?? 1, isDarkMode);
        
        // Find turning points in this phase
        final turningPointsInPhase = _getTurningPointsForPhase(index);
        
        return Column(
          children: [
            // Life Cycle Phase Card
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedLifeCycleIndex = isSelected ? null : index;
                  selectedTurningPointIndex = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _EnhancedLifeCycleCard(
                  number: number ?? 0,
                  ageRange: ageRange ?? '',
                  phaseIndex: index,
                  phaseIcon: phaseIcons[index],
                  phaseEmoji: phaseEmojis[index],
                  isSelected: isSelected,
                  isCurrentPhase: isCurrentPhase,
                  planetColor: planetColor,
                  isDarkMode: isDarkMode,
                  pulseAnimation: isCurrentPhase ? _pulseAnimation : null,
                ),
              ),
            ),
            
            // Turning Points in this phase
            if (turningPointsInPhase.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ...turningPointsInPhase.map((tpData) {
                final tp = tpData['turningPoint'] as Map<String, dynamic>;
                final tpIndex = tpData['index'] as int;
                final tpNumber = tp['number'] as int?;
                final tpAge = tp['age'] as int?;
                final isTPSelected = selectedTurningPointIndex == tpIndex;
                
                return Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTurningPointIndex = isTPSelected ? null : tpIndex;
                        selectedLifeCycleIndex = null;
                      });
                    },
                    child: _TurningPointNode(
                      number: tpNumber ?? 0,
                      age: tpAge ?? 0,
                      isSelected: isTPSelected,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              }),
            ],
            
            // Connecting path (except for last item)
            if (index < widget.lifeCycles.length - 1)
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      planetColor.withValues(alpha: 0.5),
                      AppColors.getPlanetColorForTheme(
                        widget.lifeCycles[index + 1]['number'] as int? ?? 1,
                        isDarkMode,
                      ).withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      }),
    );
  }
  
  /// Get turning points that fall within a specific life cycle phase
  List<Map<String, dynamic>> _getTurningPointsForPhase(int phaseIndex) {
    final result = <Map<String, dynamic>>[];
    
    if (phaseIndex >= widget.lifeCycles.length) return result;
    
    final cycle = widget.lifeCycles[phaseIndex];
    final ageRange = cycle['age_range'] as String?;
    
    if (ageRange == null) return result;
    
    final rangeParts = ageRange.replaceAll('+', '').replaceAll(' ', '').split('–');
    if (rangeParts.isEmpty) return result;
    
    final startAge = int.tryParse(rangeParts[0]) ?? 0;
    final endAge = rangeParts.length > 1 ? (int.tryParse(rangeParts[1]) ?? 999) : 999;
    
    for (int i = 0; i < widget.turningPoints.length; i++) {
      final tp = widget.turningPoints[i];
      final age = tp['age'] as int?;
      
      if (age != null && age >= startAge && age <= endAge) {
        result.add({
          'turningPoint': tp,
          'index': i,
        });
      }
    }
    
    return result;
  }

  /// Check if age falls within a range string like "0-28" or "0 to 28".
  bool _isInAgeRange(int age, String range) {
    try {
      // Handle formats: "0-28", "0–30", "55+"
      final cleanRange = range.replaceAll(' ', '').replaceAll('to', '-');
      
      if (cleanRange.contains('+')) {
        final start = int.tryParse(cleanRange.replaceAll('+', ''));
        return start != null && age >= start;
      }
      
      final parts = cleanRange.split(RegExp(r'[-–]'));
      if (parts.length == 2) {
        final start = int.tryParse(parts[0].trim());
        final end = int.tryParse(parts[1].trim());
        if (start != null && end != null) {
          return age >= start && age <= end;
        }
      }
    } catch (e) {
      // Silent fail
    }
    return false;
  }

  /// Detail panel showing interpretation with enhanced visuals
  Widget _buildDetailPanel(BuildContext context, bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;
    
    if (selectedLifeCycleIndex != null) {
      final cycle = widget.lifeCycles[selectedLifeCycleIndex!];
      final number = cycle['number'] as int?;
      final interpretation = cycle['interpretation'] as String?;
      final ageRange = cycle['age_range'] as String?;
      final planetColor = AppColors.getPlanetColorForTheme(number ?? 1, isDarkMode);
      
      final phaseNames = ['Formative Phase', 'Establishment Phase', 'Fruit Phase'];
      final phaseName = selectedLifeCycleIndex! < phaseNames.length 
          ? phaseNames[selectedLifeCycleIndex!] 
          : 'Life Phase';

      return _EnhancedDetailCard(
        key: ValueKey('cycle_$selectedLifeCycleIndex'),
        title: phaseName,
        subtitle: 'Ages $ageRange • Number $number',
        content: interpretation ?? '',
        accentColor: planetColor,
        textColor: textColor,
        isDarkMode: isDarkMode,
      );
    }

    if (selectedTurningPointIndex != null) {
      final tp = widget.turningPoints[selectedTurningPointIndex!];
      final number = tp['number'] as int?;
      final interpretation = tp['interpretation'] as String?;
      final age = tp['age'] as int?;
      final planetColor = AppColors.getPlanetColorForTheme(number ?? 1, isDarkMode);

      return _EnhancedDetailCard(
        key: ValueKey('tp_$selectedTurningPointIndex'),
        title: 'Turning Point at Age $age',
        subtitle: 'Number $number • Key Transition',
        content: interpretation ?? '',
        accentColor: planetColor,
        textColor: textColor,
        isDarkMode: isDarkMode,
      );
    }

    // Default state - show journey overview
    final accentColor = AppColors.getAccentColorForTheme(isDarkMode);
    return _EnhancedDetailCard(
      key: const ValueKey('default'),
      title: 'Your Life Journey',
      subtitle: 'Tap any phase or turning point to explore',
      content: 'Your life unfolds through three distinct phases, each bringing unique lessons and opportunities. Key turning points mark moments of significant transition and growth.',
      accentColor: accentColor,
      textColor: textColor,
      isDarkMode: isDarkMode,
      icon: Icons.explore,
    );
  }
}

// ============================================================================
// TIER 3 ENHANCED COMPONENTS
// ============================================================================

/// Enhanced Life Cycle Card with visual metaphors and animations
class _EnhancedLifeCycleCard extends StatelessWidget {
  final int number;
  final String ageRange;
  final int phaseIndex;
  final IconData phaseIcon;
  final String phaseEmoji;
  final bool isSelected;
  final bool isCurrentPhase;
  final Color planetColor;
  final bool isDarkMode;
  final Animation<double>? pulseAnimation;

  static const phaseLabels = ['Formative', 'Establishment', 'Fruit'];
  static const phaseDescriptions = [
    'Building foundations',
    'Creating & establishing',
    'Harvest & wisdom',
  ];

  const _EnhancedLifeCycleCard({
    required this.number,
    required this.ageRange,
    required this.phaseIndex,
    required this.phaseIcon,
    required this.phaseEmoji,
    required this.isSelected,
    required this.isCurrentPhase,
    required this.planetColor,
    required this.isDarkMode,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final label = phaseIndex < phaseLabels.length ? phaseLabels[phaseIndex] : 'Phase';
    final description = phaseIndex < phaseDescriptions.length 
        ? phaseDescriptions[phaseIndex] 
        : '';
    
    final cardColor = planetColor.withValues(alpha: isDarkMode ? 0.15 : 0.1);
    final borderColor = planetColor.withValues(alpha: isDarkMode ? 0.4 : 0.3);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    Widget card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(
          color: isSelected ? planetColor : borderColor,
          width: isSelected ? 2.5 : 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: planetColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Phase icon/emoji
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: planetColor.withValues(alpha: 0.2),
              border: Border.all(color: planetColor, width: 2),
            ),
            child: Center(
              child: Text(
                phaseEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Phase details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.headingSmall.copyWith(
                    color: planetColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ages $ageRange',
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Number $number',
                  style: AppTypography.labelSmall.copyWith(
                    color: planetColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Current phase indicator
          if (isCurrentPhase)
            Icon(
              Icons.arrow_forward_ios,
              color: planetColor,
              size: 20,
            ),
        ],
      ),
    );

    // Add pulse animation for current phase
    if (isCurrentPhase && pulseAnimation != null) {
      return ScaleTransition(
        scale: pulseAnimation!,
        child: card,
      );
    }

    return card;
  }
}

/// Turning Point Node - compact marker within timeline
class _TurningPointNode extends StatelessWidget {
  final int number;
  final int age;
  final bool isSelected;
  final bool isDarkMode;

  const _TurningPointNode({
    required this.number,
    required this.age,
    required this.isSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final planetColor = AppColors.getPlanetColorForTheme(number, isDarkMode);
    final textColor = isDarkMode ? AppColors.darkText : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: planetColor.withValues(alpha: isDarkMode ? 0.12 : 0.08),
        border: Border.all(
          color: isSelected ? planetColor : planetColor.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: planetColor.withValues(alpha: 0.2),
              border: Border.all(color: planetColor, width: 2),
            ),
            child: Center(
              child: Text(
                age.toString(),
                style: AppTypography.labelMedium.copyWith(
                  color: planetColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Turning Point',
                style: AppTypography.labelSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Number $number',
                style: AppTypography.labelSmall.copyWith(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.star,
            color: planetColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}

/// Enhanced detail card with gradient header
class _EnhancedDetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;
  final Color accentColor;
  final Color textColor;
  final bool isDarkMode;
  final IconData? icon;

  const _EnhancedDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.accentColor,
    required this.textColor,
    required this.isDarkMode,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isDarkMode ? 0.15 : 0.1),
            accentColor.withValues(alpha: isDarkMode ? 0.08 : 0.05),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: accentColor, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headingSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.labelSmall.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              content,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
