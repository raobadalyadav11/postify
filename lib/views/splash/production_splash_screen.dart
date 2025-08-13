import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class ProductionSplashScreen extends StatefulWidget {
  const ProductionSplashScreen({super.key});

  @override
  State<ProductionSplashScreen> createState() => _ProductionSplashScreenState();
}

class _ProductionSplashScreenState extends State<ProductionSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<double> _progressValue;

  bool _showProgress = false;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
      setState(() => _showProgress = true);
      _progressController.forward();
    });
  }

  void _initializeApp() async {
    try {
      final steps = [
        {'text': 'Loading resources...', 'delay': 500},
        {'text': 'Checking connectivity...', 'delay': 800},
        {'text': 'Initializing services...', 'delay': 600},
        {'text': 'Setting up preferences...', 'delay': 700},
        {'text': 'Almost ready...', 'delay': 500},
      ];

      for (var step in steps) {
        await Future.delayed(Duration(milliseconds: step['delay'] as int));
        if (mounted) {
          setState(() => _loadingText = step['text'] as String);
        }
      }

      // Initialize controllers if not already initialized
      try {
        Get.find<AuthController>();
      } catch (e) {
        Get.put(AuthController());
      }

      try {
        Get.find<ThemeController>();
      } catch (e) {
        Get.put(ThemeController());
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Fallback initialization
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() async {
    try {
      final authController = Get.find<AuthController>();

      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Check first time user
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('first_time') ?? true;

      if (isFirstTime) {
        await prefs.setBool('first_time', false);
        Get.offAll(() => const OnboardingScreen(),
            transition: Transition.fadeIn);
      } else if (authController.isAuthenticated) {
        Get.offAll(() => const HomeScreen(), transition: Transition.fadeIn);
      } else {
        Get.offAll(() => const LoginScreen(), transition: Transition.fadeIn);
      }
    } catch (e) {
      // Fallback navigation in case of error
      debugPrint('Navigation error: $e');
      Get.offAll(() => const OnboardingScreen(), transition: Transition.fadeIn);
    }
  }

  LinearGradient _getThemeGradient() {
    try {
      final themeController = Get.find<ThemeController>();
      return themeController.isDarkMode
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F2937),
                Color(0xFF111827),
              ],
            )
          : AppTheme.primaryGradientDecoration;
    } catch (e) {
      // Fallback gradient if theme controller is not available
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2196F3),
          Color(0xFF1976D2),
          Color(0xFF0D47A1),
        ],
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getThemeGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildAppName(),
              const SizedBox(height: 16),
              _buildTagline(),
              const Spacer(flex: 2),
              _buildLoadingSection(),
              const SizedBox(height: 32),
              _buildCopyright(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value * 0.1,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.campaign,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return FadeTransition(
      opacity: _textFade,
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.white.withOpacity(0.7),
        child: Text(
          'app_name'.tr,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _textFade,
      child: Text(
        'tagline'.tr,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return AnimatedOpacity(
      opacity: _showProgress ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Container(
            width: 280,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressValue,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressValue.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  borderRadius: BorderRadius.circular(3),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return FadeTransition(
      opacity: _textFade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          'copyright'.tr,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
