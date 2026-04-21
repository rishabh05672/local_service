import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openRazorpay() {
    setState(() => _isProcessing = true);
    final idempotencyKey = _uuid.v4();

    // NOTE: Razorpay key is fetched from backend — never hardcoded here.
    // In production: fetch razorpay_order_id from backend /api/v1/payments/create-order
    final options = {
      'key': 'rzp_test_XXXXXXXXXXXXXXXXXX', // Replace via backend API
      'amount': 32800, // In paise — ₹328
      'name': 'LocalServe',
      'description': 'Booking #${widget.bookingId}',
      'order_id': '', // Set from backend response
      'prefill': {
        'contact': '',
        'email': '',
      },
      'notes': {
        'bookingId': widget.bookingId,
        'idempotencyKey': idempotencyKey,
      },
      'theme': {'color': '#6C63FF'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnack('Payment failed to open. Try again.', isError: true);
    }
  }

  void _onSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    // Verify on backend: response.paymentId, response.orderId, response.signature
    _showSuccessSheet();
  }

  void _onError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    _showSnack(response.message ?? 'Payment failed.', isError: true);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    _showSnack('External wallet: ${response.walletName}', isError: false);
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modal),
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.successSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Payment Successful!',
                style: AppTypography.h3(color: AppColors.grey900)),
            const SizedBox(height: AppSpacing.sm),
            Text('Your booking is confirmed. Provider will be in touch soon.',
                style: AppTypography.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: 'View Booking',
              icon: Icons.receipt_long_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/booking/${widget.bookingId}');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Back to Home',
              variant: AppButtonVariant.ghost,
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                borderRadius: AppRadius.card,
                border: Border.all(
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary',
                      style: AppTypography.h5(
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.white
                                  : AppColors.grey900)),
                  const Divider(height: 20),
                  _PayRow(
                      label: 'Booking ID',
                      value: '#${widget.bookingId.substring(0, 10)}...'),
                  const _PayRow(label: 'Service', value: 'Pipe Fixing'),
                  const _PayRow(label: 'Service Charge', value: '₹299'),
                  const _PayRow(label: 'Platform Fee', value: '₹29'),
                  const Divider(height: 16),
                  const _PayRow(
                      label: 'Total Payable', value: '₹328', highlight: true),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Payment methods
            Text('Pay With',
                style: AppTypography.h5(
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white
                        : AppColors.grey900)),
            const SizedBox(height: AppSpacing.md),

            _PayMethodTile(
              icon: Icons.account_balance_wallet_rounded,
              label: 'UPI / Wallets / Cards',
              subtitle: 'Powered by Razorpay',
              selected: true,
              onTap: () {},
            ),

            const SizedBox(height: AppSpacing.xl),

            // Security badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded,
                    color: AppColors.success, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text('256-bit SSL Encrypted Payment',
                    style: AppTypography.caption(color: AppColors.grey400)),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            GradientButton(
              label: _isProcessing ? 'Processing...' : 'Pay ₹328 Securely',
              icon: Icons.payment_rounded,
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _openRazorpay,
            ),

            const SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                'By proceeding you agree to our Terms of Service.',
                style: AppTypography.caption(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.xl2),
          ],
        ),
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow(
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
          Text(label, style: AppTypography.bodySmall(color: AppColors.grey500)),
          Text(value,
              style: highlight
                  ? AppTypography.labelLarge(color: AppColors.primary)
                  : AppTypography.bodySmall(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.grey800)),
        ],
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySurface
              : ((Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.darkSurface2
                  : AppColors.grey50),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : ((Theme.of(context).brightness == Brightness.dark)
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.grey500,
                size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.labelMedium(
                          color: selected
                              ? AppColors.primary
                              : ((Theme.of(context).brightness ==
                                      Brightness.dark)
                                  ? Colors.white
                                  : AppColors.grey800))),
                  Text(subtitle,
                      style: AppTypography.caption(color: AppColors.grey400)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
