import 'package:flutter/material.dart';
import 'package:local_service_app/features/home/presentation/logic/home_providers.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category});
  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);

    return InkWell(
      borderRadius: AppRadius.r12,
      onTap: () {},
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          borderRadius: AppRadius.r12,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.name,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.semiBold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
