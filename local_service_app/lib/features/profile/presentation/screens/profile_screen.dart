import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppAvatar(
                        imageUrl: user?.avatarUrl,
                        name: user?.name,
                        size: 80,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(user?.name ?? 'User',
                          style: AppTypography.h4(color: Colors.white)),
                      Text(user?.phone ?? '',
                          style: AppTypography.bodySmall(
                              color: Colors.white.withValues(alpha: 0.5))),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          (user?.role ?? 'customer').toUpperCase(),
                          style: AppTypography.labelSmall(color: Colors.white),
                        ),
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
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Stats row
                  const Row(
                    children: [
                      _StatCard(label: 'Bookings', value: '12', icon: Icons.receipt_long_rounded),
                      SizedBox(width: AppSpacing.sm),
                      _StatCard(label: 'Reviews', value: '8', icon: Icons.star_rounded),
                      SizedBox(width: AppSpacing.sm),
                      _StatCard(label: 'Saved', value: '5', icon: Icons.favorite_rounded),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Settings list
                  _ProfileSection(
                    title: 'Account',
                    tiles: [
                      _ProfileTile(
                        icon: Icons.edit_rounded,
                        color: AppColors.primary,
                        label: 'Edit Profile',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.location_on_rounded,
                        color: AppColors.secondary,
                        label: 'Saved Addresses',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.notifications_rounded,
                        color: AppColors.warning,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _ProfileSection(
                    title: 'Support',
                    tiles: [
                      _ProfileTile(
                        icon: Icons.help_rounded,
                        color: AppColors.info,
                        label: 'Help & FAQ',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.policy_rounded,
                        color: AppColors.grey500,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _ProfileTile(
                        icon: Icons.description_rounded,
                        color: AppColors.grey500,
                        label: 'Terms of Service',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    label: 'Sign Out',
                    variant: AppButtonVariant.danger,
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                  ),

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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(value,
                style: AppTypography.h4(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
            Text(label,
                style: AppTypography.caption(color: AppColors.grey400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.tiles});
  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.labelLarge(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadius.card,
            border: Border.all(
                color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r12,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: AppRadius.r8,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppTypography.bodyMedium(
                      color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey800)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}
