import 'package:flutter/material.dart';

abstract class AppTypography {
  static const String fontFamily = 'Poppins';

  // ─── Font Sizes ────────────────────────────────────────────────────────────
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 28.0;
  static const double xl4 = 32.0;
  static const double xl5 = 40.0;
  static const double xl6 = 48.0;
  static const double display = 56.0;

  // ─── Font Weights ──────────────────────────────────────────────────────────
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ─── Line Heights ──────────────────────────────────────────────────────────
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // ─── Letter Spacing ────────────────────────────────────────────────────────
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWidest = 1.0;

  // ─── Text Styles ───────────────────────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: display,
        fontWeight: extraBold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xl5,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
        color: color,
      );

  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xl3,
        fontWeight: bold,
        letterSpacing: letterSpacingTight,
        color: color,
      );

  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xl2,
        fontWeight: semiBold,
        color: color,
      );

  static TextStyle h4({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xl,
        fontWeight: semiBold,
        color: color,
      );

  static TextStyle h5({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: lg,
        fontWeight: semiBold,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: base,
        fontWeight: regular,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: md,
        fontWeight: regular,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sm,
        fontWeight: regular,
        height: lineHeightNormal,
        color: color,
      );

  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: md,
        fontWeight: semiBold,
        letterSpacing: letterSpacingWide,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sm,
        fontWeight: medium,
        letterSpacing: letterSpacingWide,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xs,
        fontWeight: medium,
        letterSpacing: letterSpacingWidest,
        color: color,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: xs,
        fontWeight: regular,
        color: color,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: md,
        fontWeight: semiBold,
        letterSpacing: letterSpacingWide,
        color: color,
      );

  static TextStyle chatMessage({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: md,
        fontWeight: regular,
        height: 1.4,
        color: color,
      );

  AppTypography._();
}
