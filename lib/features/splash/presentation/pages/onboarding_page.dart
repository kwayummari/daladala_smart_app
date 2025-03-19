import 'package:daladala_smart_app/features/splash/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../widgets/onboarding_item.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingItem> _onboardingItems = [
    const OnboardingItem(
      image: 'assets/images/onboarding1.png',
      title: 'Find Your Route',
      description: 'Discover all available Daladala routes and stops near you with real-time updates.',
    ),
    const OnboardingItem(
      image: 'assets/images/onboarding2.png',
      title: 'Book Your Seats',
      description: 'Reserve your seats in advance and avoid the hassle of waiting in queues.',
    ),
    const OnboardingItem(
      image: 'assets/images/onboarding3.png',
      title: 'Track Your Journey',
      description: 'Track your Daladala in real-time and get timely arrival notifications.',
    ),
    const OnboardingItem(
      image: 'assets/images/onboarding4.png',
      title: 'Pay With Ease',
      description: 'Multiple payment options including mobile money, digital wallets, and cash.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) => _onboardingItems[index],
              ),
            ),
            
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Next or Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: _currentPage < _onboardingItems.length - 1
                    ? 'Next'
                    : 'Get Started',
                onPressed: _goToNextPage,
                icon: _currentPage < _onboardingItems.length - 1
                    ? Icons.arrow_forward
                    : Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}