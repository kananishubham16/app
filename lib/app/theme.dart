import 'package:flutter/material.dart';
import 'package:learning_setu/models/performance_model.dart';

/// AppColors defines the central color palette and helper methods
/// for the Learning Setu educational platform.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1565C0); // Primary Blue
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color onPrimaryContainer = Color(0xFF001B3F);

  // Secondary Brand Colors
  static const Color secondary = Color(0xFF00897B); // Secondary Teal
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color onSecondaryContainer = Color(0xFF00201C);

  // Tertiary Brand Colors
  static const Color tertiary = Color(0xFFF57C00); // Tertiary Orange
  static const Color tertiaryLight = Color(0xFFFFB74D);
  static const Color tertiaryContainer = Color(0xFFFFE0B2);
  static const Color onTertiaryContainer = Color(0xFF2E1500);

  // Performance Colors
  static final Color weakColor = Colors.red.shade600;
  static final Color averageColor = Colors.amber.shade700;
  static final Color strongColor = Colors.green.shade600;
  static const Color notAssessedColor = Colors.grey;

  // Background and Neutral Surface Colors
  static const Color background = Color(0xFFF8FAFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color dividerColor = Color(0xFFE2E8F0);

  /// Returns the corresponding color for a given [PerformanceLevel].
  static Color getPerformanceColor(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.weak:
        return weakColor;
      case PerformanceLevel.average:
        return averageColor;
      case PerformanceLevel.strong:
        return strongColor;
      case PerformanceLevel.notAssessed:
        return notAssessedColor;
    }
  }

  /// Returns an [IconData] representing the trend or status for [PerformanceLevel].
  static IconData getPerformanceIcon(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.weak:
        return Icons.trending_down_rounded;
      case PerformanceLevel.average:
        return Icons.trending_flat_rounded;
      case PerformanceLevel.strong:
        return Icons.trending_up_rounded;
      case PerformanceLevel.notAssessed:
        return Icons.help_outline_rounded;
    }
  }

  /// Returns a soft background color suitable for chips and badges.
  static Color getPerformanceBackgroundColor(PerformanceLevel level) {
    return getPerformanceColor(level).withOpacity(0.12);
  }

  /// Returns a subtle border color for performance chips.
  static Color getPerformanceBorderColor(PerformanceLevel level) {
    return getPerformanceColor(level).withOpacity(0.35);
  }
}

/// AppTheme provides a comprehensive Material 3 theme tailored
/// for an education context with high readability, large touch targets,
/// rounded shapes, and accessibility support.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      error: Colors.red.shade700,
      onError: Colors.white,
      outline: const Color(0xFFCBD5E1),
      outlineVariant: AppColors.dividerColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      // High-readability Typography for Education
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),

      // Card Theme: 12px rounded radius
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Large Touch Targets & Rounded Corners for Buttons (min 48dp)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1.5,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
