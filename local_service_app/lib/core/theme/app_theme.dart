import 'package:flutter/material.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.lightSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.grey900,
        ),
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.grey900,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h5(color: AppColors.grey900),
          iconTheme: const IconThemeData(color: AppColors.grey700),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingH,
            vertical: AppSpacing.xs,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.button(color: Colors.white),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.button(color: AppColors.primary),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.button(color: AppColors.primary),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium(color: AppColors.grey400),
          labelStyle: AppTypography.bodyMedium(color: AppColors.grey600),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primarySurface,
          selectedColor: AppColors.primary,
          labelStyle: AppTypography.labelSmall(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge(color: AppColors.grey900),
          headlineLarge: AppTypography.h1(color: AppColors.grey900),
          headlineMedium: AppTypography.h2(color: AppColors.grey900),
          headlineSmall: AppTypography.h3(color: AppColors.grey900),
          titleLarge: AppTypography.h4(color: AppColors.grey900),
          titleMedium: AppTypography.h5(color: AppColors.grey900),
          bodyLarge: AppTypography.bodyLarge(color: AppColors.grey800),
          bodyMedium: AppTypography.bodyMedium(color: AppColors.grey700),
          bodySmall: AppTypography.bodySmall(color: AppColors.grey500),
          labelLarge: AppTypography.labelLarge(color: AppColors.grey900),
          labelMedium: AppTypography.labelMedium(color: AppColors.grey600),
          labelSmall: AppTypography.labelSmall(color: AppColors.grey400),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h5(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.button(color: Colors.white),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.button(color: AppColors.primaryLight),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface2,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium(color: AppColors.grey600),
          labelStyle: AppTypography.bodyMedium(color: AppColors.grey400),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.grey600,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 0,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge(color: Colors.white),
          headlineLarge: AppTypography.h1(color: Colors.white),
          headlineMedium: AppTypography.h2(color: Colors.white),
          headlineSmall: AppTypography.h3(color: Colors.white),
          titleLarge: AppTypography.h4(color: Colors.white),
          titleMedium: AppTypography.h5(color: Colors.white),
          bodyLarge: AppTypography.bodyLarge(color: AppColors.grey200),
          bodyMedium: AppTypography.bodyMedium(color: AppColors.grey300),
          bodySmall: AppTypography.bodySmall(color: AppColors.grey500),
          labelLarge: AppTypography.labelLarge(color: Colors.white),
          labelMedium: AppTypography.labelMedium(color: AppColors.grey300),
          labelSmall: AppTypography.labelSmall(color: AppColors.grey500),
        ),
      );

  AppTheme._();
}
