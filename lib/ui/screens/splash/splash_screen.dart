import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/ui/screens/welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Rotation animation controller (infinite)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Scale animation with elastic effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
    
    // Navigate after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _startAnimations() {
    // Start fade animation immediately
    _fadeController.forward();
    
    // Start scale animation with slight delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
    
    // Start slide animation for text
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    
    // Start progress animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    BrandColors.backgroundDark,
                    BrandColors.primaryDark,
                    BrandColors.backgroundDark,
                  ]
                : [
                    BrandColors.backgroundLight,
                    BrandColors.primaryLight.withOpacity(0.1),
                    BrandColors.backgroundLight,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo with premium effects
                _buildPremiumLogo(isDark),
                const SizedBox(height: 40),
                // Brand name with gradient text
                _buildGradientText(context, isDark),
                const SizedBox(height: 60),
                // Premium loading indicator
                _buildPremiumLoader(isDark),
                const SizedBox(height: 20),
                // Tagline
                _buildTagline(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLogo(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 0.05, // Subtle rotation
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? BrandColors.surfaceElevatedDark : BrandColors.surfaceLight)
                        .withOpacity(0.8),
                    (isDark ? BrandColors.surfaceDark : BrandColors.backgroundLight)
                        .withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ImageDisplayUtil.companyLogo(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientText(BuildContext context, bool isDark) {
    return SlideTransition(
      position: _slideAnimation,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: isDark
                ? [
                    BrandColors.accentDark,
                    BrandColors.accent,
                    BrandColors.accentDark,
                  ]
                : [
                    BrandColors.primary,
                    BrandColors.accent,
                    BrandColors.primary,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: Text(
          'foretale.ai',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
                fontSize: 42,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: (isDark ? BrandColors.accentDark : BrandColors.primary)
                        .withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildTagline(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          'faster, accurate, and reliable risk and compliance analytics platform',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark
                    ? BrandColors.textSecondaryDark
                    : BrandColors.textSecondaryLight,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildPremiumLoader(bool isDark) {
    return SizedBox(
      width: 200,
      height: 4,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? BrandColors.accentDark : BrandColors.accent)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: isDark
                    ? BrandColors.surfaceElevatedDark
                    : BrandColors.backgroundDim,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? BrandColors.accentDark : BrandColors.accent,
                ),
                minHeight: 4,
              ),
            ),
          );
        },
      ),
    );
  }

}
