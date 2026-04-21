import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/core/widgets/shimmer_widgets.dart';
import 'package:local_service_app/core/widgets/state_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';
import 'package:local_service_app/features/home/presentation/logic/home_providers.dart';
import 'package:local_service_app/features/home/presentation/widgets/category_card.dart';
import 'package:local_service_app/features/home/presentation/widgets/service_card.dart';
import 'package:local_service_app/features/home/presentation/widgets/booking_summary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            // ✅ Fixed: dynamic background color to avoid color flash on scroll
            backgroundColor: _isScrolled 
                ? (isDark ? AppColors.darkSurface : AppColors.primary)
                : Colors.transparent,
            elevation: _isScrolled ? 4 : 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePaddingH, AppSpacing.md,
                        AppSpacing.pagePaddingH, AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Good day 👋',
                                      style: AppTypography.bodySmall(
                                          color: Colors.white.withValues(alpha: 0.6))),
                                  Text(user?.name ?? 'Welcome',
                                      style: AppTypography.h4(color: Colors.white)),
                                ],
                              ),
                            ),
                            AppAvatar(
                              imageUrl: user?.avatarUrl,
                              name: user?.name,
                              size: AppSpacing.avatarMd,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Search Bar
                        InkWell(
                          onTap: () {},
                          borderRadius: AppRadius.r12,
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: AppRadius.r12,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Text('Search services...',
                                    style: AppTypography.bodyMedium(
                                        color: Colors.white.withValues(alpha: 0.8))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: AppDurations.medium,
                  childAnimationBuilder: (w) => SlideAnimation(
                    verticalOffset: 30,
                    child: FadeInAnimation(child: w),
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // ── Active Bookings Banner ─────────────────────────────
                    if (homeState.activeBookings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pagePaddingH),
                        child: BookingSummaryCard(
                          booking: homeState.activeBookings.first,
                        ),
                      ),

                    // ── Categories ────────────────────────────────────────
                    _SectionHeader(
                      title: 'Categories',
                      onSeeAll: () {},
                    ),
                    if (homeState.isLoading)
                      const SizedBox(
                        height: 110,
                        child: ShimmerList(itemCount: 1, itemHeight: 110),
                      )
                    else if (homeState.categories.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.category_rounded,
                        title: 'No Categories',
                        subtitle: 'Check back later.',
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePaddingH),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemCount: homeState.categories.length,
                          itemBuilder: (_, i) =>
                              CategoryCard(category: homeState.categories[i]),
                        ),
                      ),

                    // ── Featured Services ─────────────────────────────────
                    _SectionHeader(
                      title: 'Featured Services',
                      onSeeAll: () {},
                    ),
                    if (homeState.isLoading)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePaddingH),
                          itemCount: 4,
                          itemBuilder: (_, __) => const ShimmerServiceCard(),
                        ),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePaddingH),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemCount: homeState.featuredServices.length,
                          itemBuilder: (_, i) => ServiceCard(
                            service: homeState.featuredServices[i],
                            onTap: () => context.push(AppRoutes.booking,
                                extra: homeState.featuredServices[i].id),
                          ),
                        ),
                      ),

                    // ── Nearby Providers ──────────────────────────────────
                    _SectionHeader(
                      title: 'Nearby Providers',
                      onSeeAll: () => context.go(AppRoutes.map),
                    ),
                    if (homeState.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                        child: ShimmerList(itemCount: 3),
                      )
                    else if (homeState.nearbyProviders.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.location_off_rounded,
                        title: 'No providers nearby',
                        subtitle: 'Enable location to find providers near you.',
                        actionLabel: 'Enable Location',
                        onAction: () => context.go(AppRoutes.map),
                      )
                    else
                      ...homeState.nearbyProviders
                          .take(5)
                          .map((p) => _ProviderListTile(provider: p)),

                    const SizedBox(height: AppSpacing.xl2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingH, AppSpacing.lg,
          AppSpacing.pagePaddingH, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTypography.h5(
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('See All',
                  style: AppTypography.labelSmall(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

class _ProviderListTile extends StatelessWidget {
  const _ProviderListTile({required this.provider});
  final dynamic provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingH, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: (Theme.of(context).brightness == Brightness.dark) ? AppShadows.cardDark : AppShadows.card,
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: provider.avatarUrl as String?,
            name: provider.name as String?,
            size: AppSpacing.avatarLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.name as String? ?? 'Provider',
                    style: AppTypography.h5(
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                Text(provider.category as String? ?? '',
                    style: AppTypography.bodySmall(color: AppColors.grey500)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 2),
                    Text('${provider.rating ?? 4.5}',
                        style: AppTypography.labelSmall(
                            color: AppColors.grey600)),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.grey400, size: 12),
                    Text('${provider.distance ?? '< 1'} km',
                        style: AppTypography.caption(
                            color: AppColors.grey400)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}
