import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bgController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();
    // ✅ Fixed: Use edgeToEdge from the start — no flash when navigating away
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _bgController.forward();
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    await _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final tokenManager = ref.read(tokenManagerProvider);
    final hasToken = await tokenManager.hasValidToken();

    final storage = ref.read(secureStorageProvider);
    final onboardingDone =
        await storage.read(key: AppConstants.kOnboardingDone);

    if (!mounted) return;

    if (onboardingDone != 'true') {
      context.go(AppRoutes.onboarding);
    } else if (hasToken) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: FadeTransition(
          opacity: _bgOpacity,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // ── Animated Logo ──────────────────────────────────────────
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.r24,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ── Animated Text ──────────────────────────────────────────
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          const Text(
                            'LocalServe',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.xl4,
                              fontWeight: AppTypography.extraBold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Services at your doorstep',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.md,
                              fontWeight: AppTypography.regular,
                              color: Colors.white.withValues(alpha: 0.60),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // ── Loading Indicator ──────────────────────────────────────
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl2),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
