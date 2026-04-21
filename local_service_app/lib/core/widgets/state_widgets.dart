import 'package:flutter/material.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

// ─── Empty State Widget ───────────────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.imagePath,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imagePath;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, height: 160, fit: BoxFit.contain)
            else
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.h4(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, AppSpacing.buttonHeight),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Error State Widget ───────────────────────────────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Oops! Something went wrong',
              style: AppTypography.h4(color: AppColors.grey900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, AppSpacing.buttonHeight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Network Error Widget ─────────────────────────────────────────────────────

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'No Internet Connection',
      subtitle: 'Check your connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
