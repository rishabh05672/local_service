import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({super.key, required this.child});
  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', path: AppRoutes.home),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chats', path: AppRoutes.chatList),
    _NavItem(icon: Icons.map_rounded, label: 'Map', path: AppRoutes.map),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', path: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _items.indexWhere((i) => i.path == location).clamp(0, _items.length - 1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              children: _items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = i == selectedIndex;
                
                return Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go(item.path);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        curve: Curves.easeOutCubic,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ Fixed: pill alpha changed from 0.5 to 0.12 (Material 3 standard)
                            AnimatedContainer(
                              duration: AppDurations.normal,
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 20 : 0,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                                borderRadius: AppRadius.chip,
                              ),
                              child: Icon(
                                item.icon,
                                size: AppSpacing.iconLg,
                                color: isSelected ? AppColors.primary : AppColors.grey400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: AppTypography.xs,
                                fontWeight: isSelected
                                    ? AppTypography.semiBold
                                    : AppTypography.medium,
                                color: isSelected ? AppColors.primary : AppColors.grey400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.path});
  final IconData icon;
  final String label;
  final String path;
}
