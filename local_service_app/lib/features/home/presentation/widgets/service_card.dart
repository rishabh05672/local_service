import 'package:flutter/material.dart';
import 'package:local_service_app/features/home/presentation/logic/home_providers.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onTap});
  final ServiceEntity service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        width: 158,
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: (Theme.of(context).brightness == Brightness.dark) ? AppShadows.none : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg)),
              ),
              width: double.infinity,
              child: const Icon(Icons.home_repair_service_rounded,
                  color: Colors.white, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTypography.labelMedium(
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.px2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 12),
                      const SizedBox(width: 2),
                      Text('${service.rating ?? 4.5}',
                          style: AppTypography.caption(color: AppColors.grey500)),
                      const Spacer(),
                      Text('₹${service.price.toInt()}',
                          style: AppTypography.labelMedium(
                              color: AppColors.primary)),
                    ],
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
