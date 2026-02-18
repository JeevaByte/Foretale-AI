//core
import 'package:flutter/material.dart';
//amplify
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

/// A widget that displays a login form with logo and branding.
class CustomLoginScaffold extends StatelessWidget {
  const CustomLoginScaffold({
    super.key,
    required this.state,
    required this.body,
  });

  final AuthenticatorState state;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius * 0.67; // 8px
    final inputPadding = context.spacing(size: SpacingSize.medium) * 0.75; // 12px
    final inputHorizontalPadding = context.spacing(size: SpacingSize.medium); // 16px
    
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          bodyLarge: theme.textTheme.bodyLarge?.copyWith(
            fontSize: context.responsiveFontSize(16),
          ),
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(
            fontSize: context.responsiveFontSize(16),
          ),
          labelLarge: theme.textTheme.labelLarge?.copyWith(
            fontSize: context.responsiveFontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: colorScheme.copyWith(
          primary: colorScheme.primary,
          onPrimary: colorScheme.onPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: context.responsiveFontSize(16),
          ),
          labelStyle: theme.textTheme.bodyLarge?.copyWith(
            fontSize: context.responsiveFontSize(16),
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            fontSize: context.responsiveFontSize(12),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          hoverColor: colorScheme.secondary.withValues(alpha: 0.1),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.secondary,
              width: 3,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: inputPadding, horizontal: inputHorizontalPadding),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontSize: context.responsiveFontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Image/Visual section
        Expanded(
          flex: 1,
          child: _buildImageSection(context),
        ),
        // Right side - Login form
        Expanded(
          flex: 1,
          child: _buildLoginSection(context),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  BrandColors.primaryDark,
                  BrandColors.primary,
                  BrandColors.primaryLight,
                ]
              : [
                  BrandColors.primary,
                  BrandColors.primaryLight,
                  BrandColors.accent.withValues(alpha: 0.3),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _PremiumPatternPainter(
                color: colorScheme.onPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing(size: SpacingSize.large) * 2,
                  vertical: context.spacing(size: SpacingSize.large),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      padding: EdgeInsets.all(context.spacing(size: SpacingSize.medium) * 1.5),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onPrimary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ImageDisplayUtil.companyLogo(),
                    ),
                    SizedBox(height: context.spacing(size: SpacingSize.large) * 1.5),
                    // Brand text
                    Text(
                      'H E X A N G O',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: context.responsiveFontSize(32),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                        color: colorScheme.secondary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing(size: SpacingSize.medium)),
                    Text(
                      'Your trusted partner in risk and compliance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: context.responsiveFontSize(18),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3.0,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: colorScheme.background,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 480,
            ),
            padding: EdgeInsets.all(
              context.spacing(size: SpacingSize.large) * 3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spacing(size: SpacingSize.large) * 2),
                _buildHeader(context),
                SizedBox(height: context.spacing(size: SpacingSize.large) * 2),
                body,
                SizedBox(height: context.spacing(size: SpacingSize.large)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(28);
    final subtitleFontSize = context.responsiveFontSize(14);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        SizedBox(height: context.spacing(size: SpacingSize.small)),
        Text(
          'Sign in to continue to foretale.ai',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: subtitleFontSize,
            letterSpacing: 0.2,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for premium pattern overlay
class _PremiumPatternPainter extends CustomPainter {
  final Color color;

  _PremiumPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle grid pattern
    const spacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
