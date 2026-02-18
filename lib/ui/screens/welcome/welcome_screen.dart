//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/quick_widgets/logo_text.dart';
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/responsive_wrap.dart';
//screen
import 'package:foretale_application/ui/screens/create_project/create_project.dart';
import 'package:foretale_application/ui/screens/landing/landing.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin<WelcomeScreen>, PageEntranceAnimations {
  @override
  void initState() {
    super.initState();
    initializeEntranceAnimations(
      fadeDuration: const Duration(milliseconds: 800),
      slideDuration: const Duration(milliseconds: 600),
    );
    startEntranceAnimations();
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomPageWrapper(
      size: size,
      workloadTheme: false,
      showBackButton: false,
      showHomeButton: false,
      child: Stack(
        children: [
          // Decorative background elements
          Positioned.fill(
            child: CustomPaint(
              painter: _WelcomeBackgroundPainter(
                colorScheme: colorScheme,
                isDark: theme.brightness == Brightness.dark,
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // Logo section at the top
              buildFadeTransition(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: context.spacing(size: SpacingSize.medium),
                    left: context.spacing(size: SpacingSize.medium),
                    right: context.spacing(size: SpacingSize.medium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ImageDisplayUtil.companyLogo(),
                      const SizedBox(width: 10),
                      const LogoText(),
                    ],
                  ),
                ),
              ),
              // Center content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing(size: SpacingSize.medium),
                      vertical: context.spacing(size: SpacingSize.large),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: buildSlideAndFadeTransition(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Main Question
                            _buildMainQuestion(context, theme, colorScheme),
                            const SizedBox(height: 24),
                            // Subtitle
                            _buildSubtitle(context, theme, colorScheme),
                            const SizedBox(height: 64),
                            // Action Buttons
                            _buildActionButtons(context, theme, colorScheme, size),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainQuestion(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final questionFontSize = context.responsiveFontSize(48);
    
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primary,
          BrandColors.accent,
          colorScheme.primary,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        'How would you like to assess the risk today?',
        textAlign: TextAlign.center,
        style: theme.textTheme.displayLarge?.copyWith(
          fontSize: questionFontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final subtitleFontSize = context.responsiveFontSize(18);
    
    return Text(
      'Start a new risk assessment project or continue with an existing one',
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: subtitleFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, ColorScheme colorScheme, Size size) {
    final buttonWidth = (size.width * 0.4).clamp(280.0, 400.0);
    final borderRadius = context.borderRadius * 1.5;
    
    return ResponsiveWrap(
      spacing: 32.0,
      runSpacing: 24.0,
      breakpoint: 700.0,
      minChildWidth: 280.0,
      maxChildWidth: 400.0,
      children: [
        _buildActionButton(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          title: 'Create New Project',
          subtitle: 'Start fresh with a new assessment',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () => _navigateToCreateProject(context),
          isPrimary: true,
          width: buttonWidth,
          borderRadius: borderRadius,
        ),
        _buildActionButton(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          title: 'Choose Existing Project',
          subtitle: 'Continue with your projects',
          icon: Icons.folder_open_rounded,
          onPressed: () => _navigateToLanding(context),
          isPrimary: false,
          width: buttonWidth,
          borderRadius: borderRadius,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
    required double width,
    required double borderRadius,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          constraints: const BoxConstraints(
            minHeight: 80.0,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      BrandColors.primaryLight,
                    ],
                  )
                : null,
            color: isPrimary
                ? null
                : colorScheme.surface.withValues(alpha: isDark ? 0.6 : 0.95),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isPrimary ? 0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? colorScheme.primary.withValues(alpha: 0.4)
                    : colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: isPrimary ? 20 : 12,
                offset: Offset(0, isPrimary ? 8 : 4),
                spreadRadius: isPrimary ? 0 : 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isPrimary
                        ? Colors.white
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: context.responsiveFontSize(18),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: isPrimary
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: context.responsiveFontSize(12),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: isPrimary
                              ? Colors.white.withValues(alpha: 0.9)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.9)
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    context.fadeNavigateTo(const CreateProject(isNew: true));
  }

  void _navigateToLanding(BuildContext context) {
    context.fadeNavigateTo(const LandingPage());
  }
}

/// Custom painter for decorative background elements
class _WelcomeBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;
  final bool isDark;

  _WelcomeBackgroundPainter({
    required this.colorScheme,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw subtle gradient circles in the background
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Large background circle - top right
    paint.shader = RadialGradient(
      colors: [
        colorScheme.primary.withValues(alpha: 0.08),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.2),
        radius: size.width * 0.4,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.4,
      paint,
    );

    // Medium background circle - bottom left
    paint.shader = RadialGradient(
      colors: [
        BrandColors.accent.withValues(alpha: 0.06),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.8),
        radius: size.width * 0.3,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      size.width * 0.3,
      paint,
    );

    // Small accent circle - center
    paint.shader = RadialGradient(
      colors: [
        colorScheme.primary.withValues(alpha: 0.04),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: size.width * 0.2,
      ),
    );
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
