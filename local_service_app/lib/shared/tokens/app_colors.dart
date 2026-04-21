import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D37CC);
  static const Color primarySurface = Color(0xFFEEEDFF);

  static const Color secondary = Color(0xFF00D4AA);
  static const Color secondaryLight = Color(0xFF5FFFDF);
  static const Color secondaryDark = Color(0xFF00A37C);
  static const Color secondarySurface = Color(0xFFE0FFF9);

  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentSurface = Color(0xFFFFEEEE);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFFF7ED);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ─── Neutral ─────────────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ─── Dark Mode Surface ────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A35);
  static const Color darkSurface2 = Color(0xFF242444);
  static const Color darkSurface3 = Color(0xFF2E2E58);
  static const Color darkBorder = Color(0xFF3A3A70);

  // ─── Light Mode Surface ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF0F0FF);
  static const Color lightBorder = Color(0xFFE8E8FF);

  // ─── Chat ─────────────────────────────────────────────────────────────────
  static const Color chatBubbleSent = Color(0xFF6C63FF);
  static const Color chatBubbleReceived = Color(0xFFFFFFFF);
  static const Color chatBubbleReceivedDark = Color(0xFF242444);
  static const Color chatBackground = Color(0xFFF0F0FF);
  static const Color chatBackgroundDark = Color(0xFF0F0F23);

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color pending = Color(0xFFF59E0B);
  static const Color confirmed = Color(0xFF3B82F6);
  static const Color inProgress = Color(0xFF8B5CF6);
  static const Color completed = Color(0xFF22C55E);
  static const Color cancelled = Color(0xFFEF4444);
  static const Color disputed = Color(0xFFEC4899);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F0F23), Color(0xFF1A1A35), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient shimmerGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A35), Color(0xFF2E2E58), Color(0xFF1A1A35)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ─── Transparency ─────────────────────────────────────────────────────────
  // ✅ Fixed: correct alpha values (were all wrong at 0.5)
  static Color white10 = Colors.white.withValues(alpha: 0.10);
  static Color white20 = Colors.white.withValues(alpha: 0.20);
  static Color white30 = Colors.white.withValues(alpha: 0.30);
  static Color black10 = Colors.black.withValues(alpha: 0.10);
  static Color black20 = Colors.black.withValues(alpha: 0.20);
  static Color black50 = Colors.black.withValues(alpha: 0.50);
  static Color primary10 = primary.withValues(alpha: 0.10);
  static Color primary20 = primary.withValues(alpha: 0.20);

  // ─── Map ──────────────────────────────────────────────────────────────────
  static const Color mapPinCustomer = Color(0xFF6C63FF);
  static const Color mapPinProvider = Color(0xFF00D4AA);
  static const Color mapRouteColor = Color(0xFF6C63FF);

  AppColors._();
}
