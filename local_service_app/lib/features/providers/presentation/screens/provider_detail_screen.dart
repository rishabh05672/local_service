import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({super.key, required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.cardGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppAvatar(name: 'Rahul Kumar', size: 80),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Rahul Kumar',
                          style: AppTypography.h4(color: Colors.white)),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text('Verified Provider',
                              style: AppTypography.bodySmall(
                                  color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatBadge(value: '4.8', label: '★ Rating'),
                          _StatBadge(value: '142', label: 'Jobs Done'),
                          _StatBadge(value: '5 yr', label: 'Experience'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Book Now',
                          icon: Icons.calendar_today_rounded,
                          height: 44,
                          onPressed: () => context.push('/booking/s1'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppIconButton(
                        icon: Icons.chat_bubble_rounded,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primarySurface,
                        size: 44,
                        onPressed: () => context.push('/chats/room1'),
                        bordered: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppIconButton(
                        icon: Icons.call_rounded,
                        color: AppColors.secondary,
                        backgroundColor: AppColors.secondarySurface,
                        size: 44,
                        onPressed: () {},
                        bordered: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text('About',
                      style: AppTypography.h5(
                          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Professional plumber with 5+ years of experience. Specializes in pipe fixing, water heater installation, and bathroom fittings. Available 7 days a week.',
                    style: AppTypography.bodyMedium(color: AppColors.grey500),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text('Services Offered',
                      style: AppTypography.h5(
                          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                  const SizedBox(height: AppSpacing.sm),

                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: const [
                      'Pipe Fixing', 'Leak Repair', 'Water Heater',
                      'Bathroom Fitting', 'Drain Cleaning',
                    ].map((s) => Chip(
                      label: Text(s),
                      backgroundColor: AppColors.primarySurface,
                      labelStyle: AppTypography.labelSmall(color: AppColors.primary),
                    )).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text('Reviews',
                      style: AppTypography.h5(
                          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                  const SizedBox(height: AppSpacing.sm),

                  ...const [
                    _ReviewData('Amit', 5, 'Great service! Very professional.'),
                    _ReviewData('Priya', 4, 'Came on time, fixed the issue quickly.'),
                  ].map((r) => _ReviewTile(review: r)),

                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(value,
              style:
                  AppTypography.h4(color: Colors.white)),
          Text(label,
              style: AppTypography.caption(
                  color: Colors.white70)),
        ],
      ),
    );
  }
}

class _ReviewData {
  const _ReviewData(this.name, this.rating, this.comment);
  final String name;
  final int rating;
  final String comment;
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final _ReviewData review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.card,
        border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: review.name, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(review.name,
                    style: AppTypography.labelMedium(
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
              ),
              Row(
                children: List.generate(
                  review.rating,
                  (_) => const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment,
              style: AppTypography.bodySmall(color: AppColors.grey500)),
        ],
      ),
    );
  }
}
