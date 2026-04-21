import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

// ─── Booking State ────────────────────────────────────────────────────────────

class BookingFormState {
  const BookingFormState({
    this.isLoading = false,
    this.selectedDate,
    this.selectedTime,
    this.address,
    this.notes,
    this.errorMessage,
  });
  final bool isLoading;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? address;
  final String? notes;
  final String? errorMessage;

  BookingFormState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? address,
    String? notes,
    String? errorMessage,
  }) =>
      BookingFormState(
        isLoading: isLoading ?? this.isLoading,
        selectedDate: selectedDate ?? this.selectedDate,
        selectedTime: selectedTime ?? this.selectedTime,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        errorMessage: errorMessage,
      );
}

class BookingNotifier extends StateNotifier<BookingFormState> {
  BookingNotifier({required this.apiClient}) : super(const BookingFormState());
  final dynamic apiClient;

  void setDate(DateTime date) => state = state.copyWith(selectedDate: date);
  void setTime(TimeOfDay time) => state = state.copyWith(selectedTime: time);
  void setAddress(String address) => state = state.copyWith(address: address);
  void setNotes(String notes) => state = state.copyWith(notes: notes);

  Future<String?> placeBooking({required String serviceId}) async {
    if (state.selectedDate == null || state.selectedTime == null) {
      state = state.copyWith(errorMessage: 'Select date and time');
      return null;
    }
    if (state.address == null || state.address!.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter service address');
      return null;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // Replace with API
    // Mock booking ID
    state = state.copyWith(isLoading: false);
    return 'BK${DateTime.now().millisecondsSinceEpoch}';
  }

  void reset() => state = const BookingFormState();
}

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, BookingFormState>((ref) {
  return BookingNotifier(apiClient: ref.watch(apiClientProvider));
});

// ─── Booking Screen ───────────────────────────────────────────────────────────

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (d != null) ref.read(bookingNotifierProvider.notifier).setDate(d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) ref.read(bookingNotifierProvider.notifier).setTime(t);
  }

  Future<void> _book() async {
    ref.read(bookingNotifierProvider.notifier).setAddress(_addressController.text.trim());
    ref.read(bookingNotifierProvider.notifier).setNotes(_notesController.text.trim());
    final bookingId = await ref.read(bookingNotifierProvider.notifier).placeBooking(
      serviceId: widget.serviceId,
    );
    if (!mounted) return;
    if (bookingId != null) {
      context.push('/payment/$bookingId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service summary card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: AppRadius.r12,
                    ),
                    child: const Icon(Icons.home_repair_service_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pipe Fixing',
                            style: AppTypography.h5(color: Colors.white)),
                        Text('Plumbing • ₹299 onwards',
                            style: AppTypography.bodySmall(
                                color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Text('Schedule', style: AppTypography.h5(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
            const SizedBox(height: AppSpacing.md),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: _PickerCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: state.selectedDate != null
                        ? '${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}'
                        : 'Select Date',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PickerCard(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: state.selectedTime != null
                        ? state.selectedTime!.format(context)
                        : 'Select Time',
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('Address', style: AppTypography.h5(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _addressController,
              maxLines: 2,
              style: AppTypography.bodyMedium(
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900),
              decoration: InputDecoration(
                hintText: 'Enter your full address',
                prefixIcon: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary),
                hintStyle: AppTypography.bodyMedium(color: AppColors.grey400),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('Additional Notes', style: AppTypography.h5(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: AppTypography.bodyMedium(
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900),
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                hintStyle: AppTypography.bodyMedium(color: AppColors.grey400),
              ),
            ),

            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(state.errorMessage!,
                  style: AppTypography.bodySmall(color: AppColors.error)),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Price summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface2 : AppColors.primarySurface,
                borderRadius: AppRadius.card,
              ),
              child: const Column(
                children: [
                  _PriceRow(label: 'Service Charge', value: '₹299'),
                  _PriceRow(label: 'Platform Fee', value: '₹29'),
                  Divider(height: 16),
                  _PriceRow(label: 'Total', value: '₹328', bold: true),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            GradientButton(
              label: 'Confirm & Pay ₹328',
              icon: Icons.payment_rounded,
              isLoading: state.isLoading,
              onPressed: _book,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.r12,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface2 : AppColors.grey50,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.caption(color: AppColors.grey400)),
            Text(value,
                style: AppTypography.labelMedium(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey800)),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTypography.labelLarge(color: AppColors.grey800) : AppTypography.bodyMedium(color: AppColors.grey600)),
          Text(value, style: bold ? AppTypography.labelLarge(color: AppColors.primary) : AppTypography.bodyMedium(color: AppColors.grey700)),
        ],
      ),
    );
  }
}
