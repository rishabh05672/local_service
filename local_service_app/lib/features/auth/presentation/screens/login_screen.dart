import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Keep transparent status bar with light icons on gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          phone: _phoneController.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      context.push(AppRoutes.otp, extra: _phoneController.text.trim());
    } else {
      final err = ref.read(authNotifierProvider).errorMessage;
      _showError(err ?? 'Failed to send OTP. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background gradient header ─────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.40,
              child: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePaddingH),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ Fixed: was alpha 0.5 (yellow/white block) — now 0.15 (subtle glass)
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: AppRadius.r20,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.handyman_rounded,
                              size: 38, color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'LocalServe',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.xl3,
                            fontWeight: AppTypography.extraBold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.regular,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Form card ─────────────────────────────────────────────────
            Positioned.fill(
              top: size.height * 0.32,
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xl2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePaddingH,
                        AppSpacing.xl,
                        AppSpacing.pagePaddingH,
                        AppSpacing.xl,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back 👋',
                              style: AppTypography.h3(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.grey900),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Enter your phone number to receive a one-time password.',
                              style: AppTypography.bodyMedium(
                                  color: AppColors.grey500),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Phone input
                            AppTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '+91 98765 43210',
                              prefixIcon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                              onFieldSubmitted: (_) => _sendOtp(),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (v.trim().replaceAll(RegExp(r'\D'), '').length < 10) {
                                  return 'Enter a valid 10-digit phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Send OTP button
                            GradientButton(
                              label: 'Send OTP',
                              icon: Icons.sms_rounded,
                              isLoading: authState.isLoading,
                              onPressed: _sendOtp,
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: AppTypography.bodySmall(
                                        color: AppColors.grey500)),
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.register),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('Register',
                                      style: AppTypography.labelMedium(
                                          color: AppColors.primary)),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.xl2),

                            // Info box
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primary.withValues(alpha: 0.10)
                                    : AppColors.primarySurface,
                                borderRadius: AppRadius.r12,
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.20)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: AppColors.primary, size: 18),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Providers and admins use the same login flow.',
                                      style: AppTypography.bodySmall(
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
