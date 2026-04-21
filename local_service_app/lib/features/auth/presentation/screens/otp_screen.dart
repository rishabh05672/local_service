import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _resendSeconds = 60;
  Timer? _timer;
  bool _isRegisterFlow = false;
  Map<String, dynamic>? _registerData;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        _isRegisterFlow = extra['isRegister'] == true;
        _registerData = extra;
      }
      _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    _resendSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    final phone = _registerData?['phone'] as String? ?? widget.phone;
    await ref.read(authNotifierProvider.notifier).sendOtp(phone: phone);
    _startTimer();
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6) return;
    FocusScope.of(context).unfocus();

    bool success;
    if (_isRegisterFlow && _registerData != null) {
      success = await ref.read(authNotifierProvider.notifier).register(
            name: _registerData!['name'] as String,
            phone: _registerData!['phone'] as String,
            otp: otp,
            role: _registerData!['role'] as String,
            email: _registerData!['email'] as String?,
          );
    } else {
      success = await ref.read(authNotifierProvider.notifier).verifyOtpAndLogin(
            phone: widget.phone,
            otp: otp,
          );
    }

    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.home);
    } else {
      final err = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Invalid OTP. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
        ),
      );
      _otpController.clear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTypography.h4(
          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface2 : AppColors.grey100,
        borderRadius: AppRadius.r12,
        border: Border.all(color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primarySurface,
        border: Border.all(color: AppColors.primary),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppShadows.fab,
              ),
              child: const Icon(Icons.sms_rounded, color: Colors.white, size: 42),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Enter OTP', style: AppTypography.h3(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
            const SizedBox(height: AppSpacing.sm),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodyMedium(color: AppColors.grey500),
                children: [
                  const TextSpan(text: 'We sent a 6-digit code to '),
                  TextSpan(
                    text: widget.phone.isNotEmpty ? widget.phone : (_registerData?['phone'] ?? ''),
                    style: AppTypography.labelMedium(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // PIN input
            Pinput(
              controller: _otpController,
              focusNode: _focusNode,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              onCompleted: _verify,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Verify button
            GradientButton(
              label: 'Verify & Continue',
              icon: Icons.check_circle_rounded,
              isLoading: authState.isLoading,
              onPressed: () => _verify(_otpController.text),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive OTP? ",
                    style: AppTypography.bodySmall(color: AppColors.grey500)),
                _resendSeconds > 0
                    ? Text(
                        'Resend in ${_resendSeconds}s',
                        style: AppTypography.labelSmall(color: AppColors.grey400),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Resend OTP',
                            style: AppTypography.labelMedium(
                                color: AppColors.primary)),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
