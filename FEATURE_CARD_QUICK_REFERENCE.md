# Quick Reference - New UI/UX Components

## FeatureCard Usage Examples

### Primary Feature Card (Large, Prominent)
```dart
FeatureCard(
  title: 'Personal Reading',
  description: 'Unlock your numerological destiny and life path',
  icon: Icons.auto_awesome,
  gradient: FeatureCardGradients.primary,
  isPrimary: true,  // Makes it 180px tall
  onTap: () {
    // Your action
  },
)
```

### Secondary Feature Card (Standard)
```dart
FeatureCard(
  title: 'Compatibility Check',
  description: 'Discover the connection between two souls',
  icon: Icons.favorite_rounded,
  gradient: FeatureCardGradients.compatibility,
  onTap: () {
    Navigator.push(...);
  },
)
```

### Feature Card with Badge
```dart
FeatureCard(
  title: 'Reading History',
  description: 'Review your past readings and insights',
  icon: Icons.history_rounded,
  gradient: FeatureCardGradients.history,
  badge: '5 saved',  // Optional notification badge
  onTap: () {
    Navigator.push(...);
  },
)
```

---

## Available Gradient Presets

```dart
// Deep purple to indigo - Primary features
FeatureCardGradients.primary

// Pink to magenta - Romantic/relationship features
FeatureCardGradients.compatibility

// Teal to sea green - History/archive features
FeatureCardGradients.history

// Gold to rich gold - Premium/special features
FeatureCardGradients.golden

// Purple-blue to deep purple - Mystical features
FeatureCardGradients.cosmic
```

---

## Custom Gradient Example

```dart
FeatureCard(
  title: 'Custom Feature',
  description: 'Your custom description',
  icon: Icons.star,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFYOURCOLOR1),
      Color(0xFFYOURCOLOR2),
    ],
  ),
  onTap: () { },
)
```

---

## Animation Patterns Used

### Staggered Card Entry
```dart
TweenAnimationBuilder<double>(
  duration: const Duration(milliseconds: 600),
  tween: Tween(begin: 0.0, end: 1.0),
  curve: Curves.easeOutCubic,
  builder: (context, value, child) {
    return Transform.scale(
      scale: 0.9 + (0.1 * value),
      child: Opacity(opacity: value, child: child),
    );
  },
  child: FeatureCard(...),
)
```

### Expandable Section
```dart
AnimatedSize(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  child: _showContent 
      ? YourContent() 
      : const SizedBox.shrink(),
)
```

### Hero Transition
```dart
Hero(
  tag: 'unique-tag-${item.id}',
  child: YourWidget(),
)
```

---

## Design Tokens

### Card Dimensions
- **Primary card height:** 180px
- **Secondary card height:** 140px
- **Icon size (primary):** 48px
- **Icon size (secondary):** 36px
- **Border radius:** AppRadius.xl (16px)
- **Padding:** AppSpacing.lg / xl (16-24px)

### Elevation
- **Feature cards:** AppElevation.md
- **History cards:** AppElevation.md
- **Form card:** AppElevation.lg

### Animation Timing
- **Press animation:** 150ms
- **Page entrance:** 800ms
- **Form expand:** 400ms
- **Stagger delay:** 100ms per card

---

## Icon Recommendations

### Mystical/Spiritual
- `Icons.auto_awesome` - Personal reading, destiny
- `Icons.wb_sunny_rounded` - Daily insights, forecast
- `Icons.auto_fix_high` - Tarot, magic
- `Icons.nights_stay` - Moon, dreams

### Relationships
- `Icons.favorite_rounded` - Love, compatibility
- `Icons.people_rounded` - Community, connections
- `Icons.groups` - Group readings

### Knowledge/Learning
- `Icons.menu_book` - Learning, articles
- `Icons.school` - Education, tutorials
- `Icons.lightbulb_outline` - Tips, insights

### History/Time
- `Icons.history_rounded` - History, past readings
- `Icons.access_time` - Timeline, schedule
- `Icons.calendar_today` - Date-based features

### Premium/Special
- `Icons.diamond` - Premium features
- `Icons.star` - Favorites, special
- `Icons.workspace_premium` - VIP, upgrade

---

## Color Psychology Applied

| Feature | Gradient | Psychology |
|---------|----------|------------|
| Personal Reading | Purple → Indigo | Mystical, spiritual, royal |
| Compatibility | Pink → Magenta | Love, romance, connection |
| History | Teal → Sea Green | Memory, calm, reflection |
| Premium | Gold → Rich Gold | Luxury, value, enlightenment |
| Cosmic | Purple-Blue → Deep Purple | Universe, destiny, magic |

---

## Accessibility Guidelines

### Touch Targets
- ✅ Minimum: 140px (well above 48px requirement)
- ✅ Recommended: 180px for primary actions

### Text Contrast
- ✅ White text on gradients with drop shadows
- ✅ WCAG AAA compliant (7:1+ contrast)

### Visual Feedback
- ✅ Ripple effects on tap
- ✅ Scale animation on press
- ✅ Highlight state changes

---

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding** entire card on state changes
3. **Cache gradients** if used repeatedly
4. **Limit badge updates** to prevent unnecessary rebuilds
5. **Use `AnimatedSize`** instead of manual height animations

---

## Common Patterns

### Adding a New Feature to Dashboard
```dart
// In decode_form_page.dart, add after existing cards:

FeatureCard(
  title: 'Your New Feature',
  description: 'Brief description of what it does',
  icon: Icons.your_icon,
  gradient: FeatureCardGradients.cosmic, // Choose appropriate gradient
  badge: 'New', // Optional
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const YourFeaturePage(),
      ),
    );
  },
),
const SizedBox(height: AppSpacing.md), // Spacing
```

### Creating Dashboard Section Headers
```dart
Padding(
  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
  child: Text(
    'Section Title',
    style: AppTypography.labelLarge.copyWith(
      color: AppColors.textMuted,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
),
```

### Info Callout Box
```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.accent.withValues(alpha: 0.1),
        AppColors.primary.withValues(alpha: 0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(
      color: AppColors.accent.withValues(alpha: 0.3),
      width: 1.5,
    ),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, color: AppColors.accent),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(
          'Your helpful message here',
          style: AppTypography.bodySmall,
        ),
      ),
    ],
  ),
),
```

---

## Testing Checklist

When adding new feature cards:
- [ ] Test on various screen sizes
- [ ] Verify touch targets are 48px+ (already handled by card size)
- [ ] Check text readability on gradient backgrounds
- [ ] Test animations on low-end devices
- [ ] Verify navigation works correctly
- [ ] Test with accessibility tools (TalkBack/VoiceOver)
- [ ] Ensure proper spacing between cards
- [ ] Test dark mode (if applicable)

---

## Maintenance Notes

### When to Use Primary Card
- Main app feature (Personal Reading)
- Most common user action
- Feature you want to promote
- **Only use ONE primary card per screen**

### When to Use Secondary Card
- Supporting features
- Navigation options
- Related actions
- **Use 2-4 secondary cards typically**

### When to Add Badges
- Notification counts ("3 new")
- Item counts ("5 saved")
- Status labels ("New", "Beta")
- Promotional tags ("50% Off")
- **Keep badges short (1-2 words max)**

---

## Future-Proofing

The card system is designed to scale. Easy additions:

### Daily Features
```dart
FeatureCard(
  title: 'Daily Insight',
  description: 'Your forecast for ${DateFormat('EEEE').format(DateTime.now())}',
  icon: Icons.wb_sunny_rounded,
  gradient: FeatureCardGradients.golden,
  badge: 'Today',
  onTap: () => showDailyInsight(),
)
```

### Premium Upsell
```dart
FeatureCard(
  title: 'Unlock Premium',
  description: 'Get advanced readings and exclusive features',
  icon: Icons.diamond,
  gradient: FeatureCardGradients.golden,
  badge: '50% Off',
  onTap: () => showPaywall(),
)
```

### Community Features
```dart
FeatureCard(
  title: 'Community',
  description: 'Connect with others on their journey',
  icon: Icons.groups,
  gradient: FeatureCardGradients.cosmic,
  badge: '1.2k online',
  onTap: () => navigateToCommunity(),
)
```

---

**For detailed implementation report, see:** [UI_UX_DASHBOARD_REDESIGN_COMPLETE.md](UI_UX_DASHBOARD_REDESIGN_COMPLETE.md)
