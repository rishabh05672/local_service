import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

// ─── Shimmer Box ─────────────────────────────────────────────────────────────
// ✅ Fixed: the child inside Shimmer.fromColors MUST be an opaque color.
//    Using a transparent/same color as baseColor makes the animation invisible.

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = const BorderRadius.all(Radius.circular(8)),
  });

  final double? width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface2 : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.darkSurface3 : const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // ✅ Must be opaque — shimmer overlays this with its gradient
          color: isDark ? AppColors.darkSurface2 : Colors.white,
          borderRadius: radius,
        ),
      ),
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────────
// ✅ Fixed: wrap entire card in one Shimmer.fromColors (better perf + visible)

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 80});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface2 : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.darkSurface3 : const Color(0xFFF8FAFC),
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingH,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : Colors.white,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface3 : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface3 : Colors.white,
                      borderRadius: AppRadius.r4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface3 : Colors.white,
                      borderRadius: AppRadius.r4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer List ─────────────────────────────────────────────────────────────

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 6, this.itemHeight = 80});
  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}

// ─── Shimmer Service Card ─────────────────────────────────────────────────────

class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface2 : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.darkSurface3 : const Color(0xFFF8FAFC),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : Colors.white,
          borderRadius: AppRadius.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface3 : Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface3 : Colors.white,
                      borderRadius: AppRadius.r4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface3 : Colors.white,
                      borderRadius: AppRadius.r4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Category Card ────────────────────────────────────────────────────

class ShimmerCategoryCard extends StatelessWidget {
  const ShimmerCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface2 : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.darkSurface3 : const Color(0xFFF8FAFC),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : Colors.white,
          borderRadius: AppRadius.r12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface3 : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface3 : Colors.white,
                borderRadius: AppRadius.r4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
