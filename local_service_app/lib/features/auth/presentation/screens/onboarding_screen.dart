import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:local_service_app/core/config/router.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.search_rounded,
      gradientColors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
      title: 'Find Local Services',
      subtitle: 'Browse hundreds of trusted service providers in your neighbourhood — plumbers, cleaners, electricians & more.',
    ),
    _OnboardPage(
      icon: Icons.calendar_today_rounded,
      gradientColors: [Color(0xFF00D4AA), Color(0xFF00A37C)],
      title: 'Book Instantly',
      subtitle: 'Schedule at your convenience. Real-time availability, instant confirmation, and smart reminders.',
    ),
    _OnboardPage(
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFEC4899)],
      title: 'Safe & Secure',
      subtitle: 'Verified providers, insured bookings, and end-to-end encrypted payments for your peace of mind.',
    ),
    _OnboardPage(
      icon: Icons.chat_bubble_rounded,
      gradientColors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
      title: 'Chat in Real Time',
      subtitle: 'WhatsApp-style chat with your provider. Share photos, location, and updates — all in one place.',
    ),
  ];

  Future<void> _complete() async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: AppConstants.kOnboardingDone, value: 'true');
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: Text(
                  'Skip',
                  style: AppTypography.labelMedium(color: AppColors.grey400),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardPageWidget(page: _pages[i]),
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingH,
                AppSpacing.lg,
                AppSpacing.pagePaddingH,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.grey700,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GradientButton(
                    label: isLast ? 'Get Started' : 'Next',
                    icon: isLast
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (isLast) {
                        _complete();
                      } else {
                        _pageController.nextPage(
                          duration: AppDurations.medium,
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
}

class _OnboardPageWidget extends StatelessWidget {
  const _OnboardPageWidget({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.gradientColors.first.withValues(alpha: 0.5),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(page.icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xl2),

          Text(
            page.title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.xl3,
              fontWeight: AppTypography.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            page.subtitle,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.md,
              fontWeight: AppTypography.regular,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
