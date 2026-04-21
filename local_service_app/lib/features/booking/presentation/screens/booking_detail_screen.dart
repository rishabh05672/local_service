import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: BookingColors.confirmedSurface,
                borderRadius: AppRadius.card,
                border: Border.all(color: BookingColors.confirmed.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: BookingColors.confirmed, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Confirmed',
                          style: AppTypography.labelLarge(
                              color: BookingColors.confirmed)),
                      Text('ID: $bookingId',
                          style: AppTypography.bodySmall(
                              color: AppColors.grey500)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            const _DetailSection(
              title: 'Service',
              children: [
                _DetailRow(label: 'Service', value: 'Pipe Fixing'),
                _DetailRow(label: 'Category', value: 'Plumbing'),
                _DetailRow(label: 'Date', value: 'April 18, 2026'),
                _DetailRow(label: 'Time', value: '10:00 AM'),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            _DetailSection(
              title: 'Provider',
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('RK',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rahul Kumar',
                            style: AppTypography.labelLarge(
                                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.warning, size: 14),
                            Text('4.8',
                                style: AppTypography.bodySmall(
                                    color: AppColors.grey500)),
                            const SizedBox(width: AppSpacing.sm),
                            Text('142 jobs',
                                style: AppTypography.bodySmall(
                                    color: AppColors.grey400)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    AppIconButton(
                      icon: Icons.chat_bubble_rounded,
                      color: AppColors.primary,
                      onPressed: () => context.push('/chats/room1'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppIconButton(
                      icon: Icons.call_rounded,
                      color: AppColors.secondary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            const _DetailSection(
              title: 'Payment',
              children: [
                _DetailRow(label: 'Service Charge', value: '₹299'),
                _DetailRow(label: 'Platform Fee', value: '₹29'),
                _DetailRow(label: 'Total Paid', value: '₹328', highlight: true),
                _DetailRow(label: 'Payment Method', value: 'UPI'),
                _DetailRow(label: 'Status', value: '✅ Paid'),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Report an Issue',
              variant: AppButtonVariant.outlined,
              icon: Icons.flag_rounded,
              onPressed: () {},
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class BookingColors {
  static const Color confirmed = Color(0xFF3B82F6);
  static const Color confirmedSurface = Color(0xFFEFF6FF);
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.h5(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySmall(color: AppColors.grey500)),
          Text(value,
              style: highlight
                  ? AppTypography.labelMedium(color: AppColors.primary)
                  : AppTypography.bodySmall(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.grey800)),
        ],
      ),
    );
  }
}
