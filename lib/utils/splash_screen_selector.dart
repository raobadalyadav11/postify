import 'package:flutter/material.dart';

import '../views/splash/splash_screen.dart';
import '../views/splash/animated_splash_screen.dart';
import '../views/splash/minimal_splash_screen.dart';
import '../views/splash/creative_splash_screen.dart';
import '../views/splash/modern_splash_screen.dart';
import '../views/splash/glassmorphism_splash_screen.dart';
import '../views/splash/neon_splash_screen.dart';

enum SplashScreenType {
  original,
  animated,
  minimal,
  creative,
  modern,
  glassmorphism,
  neon,
}

class SplashScreenSelector {
  static Widget getSplashScreen(SplashScreenType type) {
    switch (type) {
      case SplashScreenType.original:
        return const SplashScreen();
      case SplashScreenType.animated:
        return const AnimatedSplashScreen();
      case SplashScreenType.minimal:
        return const MinimalSplashScreen();
      case SplashScreenType.creative:
        return const CreativeSplashScreen();
      case SplashScreenType.modern:
        return const ModernSplashScreen();
      case SplashScreenType.glassmorphism:
        return const GlassmorphismSplashScreen();
      case SplashScreenType.neon:
        return const NeonSplashScreen();
    }
  }

  static List<SplashScreenDemo> getAllSplashScreens() {
    return [
      SplashScreenDemo(
        name: 'Original',
        description: 'Classic gradient splash screen',
        type: SplashScreenType.original,
        preview: Icons.gradient,
      ),
      SplashScreenDemo(
        name: 'Animated',
        description: 'Particle effects and smooth animations',
        type: SplashScreenType.animated,
        preview: Icons.auto_awesome,
      ),
      SplashScreenDemo(
        name: 'Minimal',
        description: 'Clean and simple design',
        type: SplashScreenType.minimal,
        preview: Icons.minimize,
      ),
      SplashScreenDemo(
        name: 'Creative',
        description: 'Wave animations and creative elements',
        type: SplashScreenType.creative,
        preview: Icons.waves,
      ),
      SplashScreenDemo(
        name: 'Modern',
        description: 'Dark theme with modern aesthetics',
        type: SplashScreenType.modern,
        preview: Icons.dark_mode,
      ),
      SplashScreenDemo(
        name: 'Glassmorphism',
        description: 'Frosted glass effect with blur',
        type: SplashScreenType.glassmorphism,
        preview: Icons.blur_on,
      ),
      SplashScreenDemo(
        name: 'Neon',
        description: 'Cyberpunk neon glow effects',
        type: SplashScreenType.neon,
        preview: Icons.flash_on,
      ),
    ];
  }
}

class SplashScreenDemo {
  final String name;
  final String description;
  final SplashScreenType type;
  final IconData preview;

  SplashScreenDemo({
    required this.name,
    required this.description,
    required this.type,
    required this.preview,
  });
}