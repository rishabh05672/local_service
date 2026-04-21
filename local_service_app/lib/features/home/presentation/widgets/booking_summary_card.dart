import 'package:flutter/material.dart';
import 'package:local_service_app/features/home/presentation/logic/home_providers.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.booking});
  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Booking',
                    style: AppTypography.labelSmall(
                        color: Colors.white.withValues(alpha: 0.5))),
                Text(booking.service,
                    style: AppTypography.h5(color: Colors.white)),
                Text(
                  _statusLabel(booking.status),
                  style: AppTypography.bodySmall(
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: AppRadius.chip,
            ),
            child: Text(booking.status,
                style: AppTypography.labelSmall(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'confirmed' => '✅ Provider is on the way',
        'in_progress' => '🔧 Work in progress',
        'pending' => '⏳ Waiting for provider',
        _ => status,
      };
}
