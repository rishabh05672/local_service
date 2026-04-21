import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  // Selected role: 'customer' or 'provider'
  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    // ✅ Fixed: Added slide + fade animation to match login UX
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Since mock flow requires OTP verification for registration too,
    // we first send an OTP. The actual registration happens after verify.
    final authNotif = ref.read(authNotifierProvider.notifier);
    final success = await authNotif.sendOtp(
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      // Pass registration data to OTP screen
      context.push(
        AppRoutes.otp,
        extra: {
          'phone': _phoneController.text.trim(),
          'isRegister': true,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        },
      );
    } else {
      final err = ref.read(authNotifierProvider).errorMessage;
      _showError(err ?? 'Validation failed. Please try again.');
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
              height: size.height * 0.35,
              child: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePaddingH),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: AppRadius.r16,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.5),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => context.go(AppRoutes.login),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.xl3,
                            fontWeight: AppTypography.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Join LocalServe to book or offer services',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.sm,
                            color: Colors.white.withValues(alpha: 0.7),
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
              top: size.height * 0.28,
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
                            // Role Selector
                            _RoleSelector(
                              selectedRole: _selectedRole,
                              onChanged: (r) =>
                                  setState(() => _selectedRole = r),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Fields
                            AppTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              prefixIcon: Icons.person_rounded,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            AppTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '+91 98765 43210',
                              prefixIcon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
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
                            const SizedBox(height: AppSpacing.lg),

                            AppTextField(
                              controller: _emailController,
                              label: 'Email (Optional)',
                              hint: 'john@example.com',
                              prefixIcon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) => _register(),
                            ),
                            const SizedBox(height: AppSpacing.xl2),

                            GradientButton(
                              label: 'Continue',
                              icon: Icons.arrow_forward_rounded,
                              isLoading: authState.isLoading,
                              onPressed: _register,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Login redirect
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account? ",
                                    style: AppTypography.bodySmall(
                                        color: AppColors.grey500)),
                                TextButton(
                                  onPressed: () => context.go(AppRoutes.login),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text('Login',
                                      style: AppTypography.labelMedium(
                                          color: AppColors.primary)),
                                ),
                              ],
                            ),
                            // Extra space for bottom safe area when scrolled
                            SizedBox(
                                height: MediaQuery.of(context).padding.bottom +
                                    16),
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

// ─── Custom Role Selector ─────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selectedRole, required this.onChanged});

  final String selectedRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface2 : AppColors.grey100;
    final actColor = isDark ? AppColors.primaryDark : Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.r16,
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: 'Customer',
              icon: Icons.search_rounded,
              isSelected: selectedRole == 'customer',
              activeColor: actColor,
              onTap: () => onChanged('customer'),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: 'Provider',
              icon: Icons.handyman_rounded,
              isSelected: selectedRole == 'provider',
              activeColor: actColor,
              onTap: () => onChanged('provider'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.grey400 : AppColors.grey600);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: AppRadius.r12,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : AppShadows.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium(
                color: color,
              ).copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
