import 'package:flutter/material.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

/// Responsive layout builder — adapts to phone/tablet/desktop.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= AppBreakpoints.laptop && desktop != null) {
          return desktop!(context, constraints);
        }
        if (width >= AppBreakpoints.tablet && tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// Grid that adjusts column count by screen width.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= AppBreakpoints.laptop
        ? desktopColumns
        : width >= AppBreakpoints.tablet
            ? tabletColumns
            : mobileColumns;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (width - (AppSpacing.pagePaddingH * 2) - (spacing * (columns - 1))) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Returns adaptive horizontal padding based on screen width.
extension ResponsivePadding on BuildContext {
  double get horizontalPadding {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= AppBreakpoints.desktop) return w * 0.15;
    if (w >= AppBreakpoints.laptop) return w * 0.10;
    if (w >= AppBreakpoints.tablet) return AppSpacing.xl;
    return AppSpacing.pagePaddingH;
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: horizontalPadding);
}
