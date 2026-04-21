import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double full = 999.0;

  // ─── BorderRadius Helpers ──────────────────────────────────────────────────
  static BorderRadius r4 = BorderRadius.circular(xs);
  static BorderRadius r8 = BorderRadius.circular(sm);
  static BorderRadius r12 = BorderRadius.circular(md);
  static BorderRadius r16 = BorderRadius.circular(lg);
  static BorderRadius r20 = BorderRadius.circular(xl);
  static BorderRadius r24 = BorderRadius.circular(xl2);
  static BorderRadius r32 = BorderRadius.circular(xl3);
  static BorderRadius circle = BorderRadius.circular(full);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static final BorderRadius button = BorderRadius.circular(lg);
  static final BorderRadius card = BorderRadius.circular(lg);
  static final BorderRadius input = BorderRadius.circular(md);
  static final BorderRadius chip = BorderRadius.circular(full);
  static const BorderRadius modal =
      BorderRadius.vertical(top: Radius.circular(xl2));
  static BorderRadius chatBubbleSent = const BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(xs),
  );
  static const BorderRadius chatBubbleReceived = BorderRadius.only(
    topLeft: Radius.circular(xs),
    topRight: Radius.circular(lg),
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );

  AppRadius._();
}

abstract class AppShadows {
  static List<BoxShadow> none = [];

  // ✅ Fixed: all shadows had alpha: 0.5 — now use perceptually correct values
  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lg = [
    BoxShadow(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> fab = [
    BoxShadow(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  AppShadows._();
}

abstract class AppDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration splash = Duration(milliseconds: 2500);
  static const Duration shimmer = Duration(milliseconds: 1500);

  AppDurations._();
}

abstract class AppBreakpoints {
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double laptop = 1024.0;
  static const double desktop = 1280.0;
  static const double wide = 1536.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= tablet && w < laptop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= laptop;

  AppBreakpoints._();
}
