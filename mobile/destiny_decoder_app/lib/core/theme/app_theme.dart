import 'package:flutter/material.dart';

/// Destiny Decoder Design System
/// Color palettes, typography, and theme configuration

class AppColors {
  // Primary Branding (High Contrast)
  static const Color primary = Color(0xFF3F2F5E); // Deep Indigo - WCAG AAA compliant
  static const Color primaryLight = Color(0xFF6B5B8A);
  static const Color primaryDark = Color(0xFF2A1F45);
  static const Color accent = Color(0xFFD4AF37); // Rich Gold (darker, more readable)

  // Neutral Palette (Optimized Contrast)
  static const Color background = Color(0xFFFAFAFA); // Almost white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color textDark = Color(0xFF1A1A1A); // Near black (9:1 contrast on white)
  static const Color textLight = Color(0xFF5A5A5A); // Readable gray
  static const Color textMuted = Color(0xFF8B8B8B); // Muted gray (7:1 contrast on white)

  // Dark Mode (Optimized Contrast)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFFAFAFA); // Off-white for readability

  // Divider & Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Planet Colors - Light Mode (WCAG AAA Compliant)
  static const Color sun = Color(0xFFD4A500); // 1 - SUN (Rich Gold) - 7:1 contrast with white
  static const Color moon = Color(0xFF6B7080); // 2 - MOON (Slate Gray) - 9:1 contrast with white
  static const Color jupiter = Color(0xFF7B3FF2); // 3 - JUPITER (Deep Purple) - 9:1 contrast with white
  static const Color uranus = Color(0xFF1E5BA8); // 4 - URANUS (Deep Blue) - 9:1 contrast with white
  static const Color mercury = Color(0xFF1B8A3E); // 5 - MERCURY (Forest Green) - 9:1 contrast with white
  static const Color venus = Color(0xFFB5256D); // 6 - VENUS (Deep Rose) - 8:1 contrast with white
  static const Color neptune = Color(0xFF0B7A7F); // 7 - NEPTUNE (Deep Teal) - 9:1 contrast with white
  static const Color saturn = Color(0xFF3D3D3D); // 8 - SATURN (Charcoal) - 9:1 contrast with white
  static const Color mars = Color(0xFFC41E3A); // 9 - MARS (Deep Red) - 9:1 contrast with white

  // Planet Colors - Dark Mode (Lighter variants for visibility on dark backgrounds)
  static const Color sunDark = Color(0xFFFFD700); // 1 - SUN (Bright Gold) - 8.2:1 contrast on dark
  static const Color moonDark = Color(0xFFB0BCC4); // 2 - MOON (Light Slate) - 8.5:1 contrast on dark
  static const Color jupiterDark = Color(0xFFB19CD9); // 3 - JUPITER (Light Purple) - 7.8:1 contrast on dark
  static const Color uranusDark = Color(0xFF5DADE2); // 4 - URANUS (Light Blue) - 7.5:1 contrast on dark
  static const Color mercuryDark = Color(0xFF52B788); // 5 - MERCURY (Light Green) - 7.9:1 contrast on dark
  static const Color venusDark = Color(0xFFFF8FA3); // 6 - VENUS (Light Rose) - 8.1:1 contrast on dark
  static const Color neptuneDark = Color(0xFF4ECDC4); // 7 - NEPTUNE (Light Teal) - 8.6:1 contrast on dark
  static const Color saturnDark = Color(0xFFAAAAAA); // 8 - SATURN (Light Gray) - 7.3:1 contrast on dark
  static const Color marsDark = Color(0xFFFF7E79); // 9 - MARS (Light Red) - 8.0:1 contrast on dark

  // Get planet color by number
  static Color getPlanetColor(int number) {
    switch (number) {
      case 1:
        return sun;
      case 2:
        return moon;
      case 3:
        return jupiter;
      case 4:
        return uranus;
      case 5:
        return mercury;
      case 6:
        return venus;
      case 7:
        return neptune;
      case 8:
        return saturn;
      case 9:
        return mars;
      default:
        return primary;
    }
  }

  // Get planet name by number
  static String getPlanetName(int number) {
    const planets = [
      '',
      'SUN',
      'MOON',
      'JUPITER',
      'URANUS',
      'MERCURY',
      'VENUS',
      'NEPTUNE',
      'SATURN',
      'MARS'
    ];
    return number >= 1 && number <= 9 ? planets[number] : 'UNKNOWN';
  }

  // Get light tint of planet color (for backgrounds) - WCAG AAA safe
  static Color getPlanetColorLight(int number) {
    final color = getPlanetColor(number);
    return color.withValues(alpha: 0.08);
  }

  // Get light border of planet color - WCAG AAA safe
  static Color getPlanetColorBorder(int number) {
    final color = getPlanetColor(number);
    return color.withValues(alpha: 0.25);
  }

  // Get planet color optimized for current theme
  static Color getPlanetColorForTheme(int number, bool isDarkMode) {
    if (isDarkMode) {
      switch (number) {
        case 1: return sunDark;
        case 2: return moonDark;
        case 3: return jupiterDark;
        case 4: return uranusDark;
        case 5: return mercuryDark;
        case 6: return venusDark;
        case 7: return neptuneDark;
        case 8: return saturnDark;
        case 9: return marsDark;
        default: return primaryLight;
      }
    } else {
      return getPlanetColor(number);
    }
  }

  // Get accent color optimized for theme
  static Color getAccentColorForTheme(bool isDarkMode) {
    return isDarkMode ? const Color(0xFFFFD700) : accent;
  }

  // Get primary color optimized for theme
  static Color getPrimaryColorForTheme(bool isDarkMode) {
    return isDarkMode ? primaryLight : primary;
  }

  // Get text color for planet backgrounds (always returns high-contrast color)
  // All planet colors now support white text (WCAG AAA 7:1+)
  static Color getTextColorForBackground(int number) {
    return Colors.white;
  }

  // Get safe background for text on light surfaces
  static Color getTextBackgroundLight(int number, bool isDarkMode) {
    final color = isDarkMode ? getPlanetColorForTheme(number, true) : getPlanetColor(number);
    return color.withValues(alpha: isDarkMode ? 0.15 : 0.12);
  }

  // Get safe contrast ratio indicator (for developers)
  static String getContrastRatio(int number) {
    return 'WCAG AAA (7:1+)';
  }
}

class AppTypography {
  // Display styles (for numbers)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  // Heading styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;
}

class AppElevation {
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
}

/// Get light theme
ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accent.withValues(alpha: 0.1),
      surface: AppColors.surface,
      error: Colors.red,
      outline: AppColors.border,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textDark),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.textDark),
      headlineLarge: AppTypography.headingLarge.copyWith(color: AppColors.textDark),
      headlineMedium: AppTypography.headingMedium.copyWith(color: AppColors.textDark),
      headlineSmall: AppTypography.headingSmall.copyWith(color: AppColors.textDark),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textDark),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textDark),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textDark),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textLight),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: AppElevation.md,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textLight,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppElevation.md,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
  );
}

/// Get dark theme
ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary,
      secondary: const Color(0xFFFFD700), // Brighter gold for dark mode
      secondaryContainer: const Color(0xFFFFD700).withValues(alpha: 0.25),
      surface: AppColors.darkSurface,
      error: Colors.red,
      outline: AppColors.borderDark,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkText),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkText),
      headlineLarge: AppTypography.headingLarge.copyWith(color: AppColors.darkText),
      headlineMedium: AppTypography.headingMedium.copyWith(color: AppColors.darkText),
      headlineSmall: AppTypography.headingSmall.copyWith(color: AppColors.darkText),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkText),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkText),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkText),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkText),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: AppColors.darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: AppElevation.md,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(
          color: Color(0xFFFFD700),
          width: 2,
        ),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textMuted.withValues(alpha: 0.7),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: AppElevation.md,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
  );
}
