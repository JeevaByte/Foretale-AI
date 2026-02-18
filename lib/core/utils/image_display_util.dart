import 'package:flutter/material.dart';

/// Utility class for displaying images throughout the application
class ImageDisplayUtil {
  static const String _companyLogoPath = 'assets/images/logo/company_logo.png';
  static const String _productLogoPath = 'assets/images/logo/foretale_logo.png';
  static const String _uploadWizardIconPath = 'assets/images/icons/upload_icon.png';
  static const String _knowledgeBaseIconPath = 'assets/images/icons/knowledge_icon.png';
  static const String _controlsRegisterIconPath = 'assets/images/icons/controls_register_icon.png';
  static const String _reportsIconPath = 'assets/images/icons/reports_icon.png';
  static const String _agenticAIIconPath = 'assets/images/icons/agentic_ai_icon.png';

  static Widget companyLogo() {
    return _buildImage(
      path: _companyLogoPath,
      height: 50,
      width: 50,
      fit: BoxFit.contain,
      borderRadius: 12,
      color: null,
      errorWidget: null,
    );
  }

  static Widget productLogo() {
    return _buildImage(
      path: _productLogoPath,
      height: 200,
      width: 200,
      fit: BoxFit.contain,
      borderRadius: 12,
      color: null,
      errorWidget: null,
    );
  }

  static Widget uploadWizardIcon({double? size, Color? color}) {
    return _buildImage(
      path: _uploadWizardIconPath,
      height: size ?? 48,
      width: size ?? 48,
      fit: BoxFit.contain,
      borderRadius: 0,
      color: color,
      errorWidget: null,
    );
  }

  static Widget knowledgeBaseIcon({double? size, Color? color}) {
    return _buildImage(
      path: _knowledgeBaseIconPath,
      height: size ?? 48,
      width: size ?? 48,
      fit: BoxFit.contain,
      borderRadius: 0,
      color: color,
      errorWidget: null,
    );
  }

  static Widget controlsRegisterIcon({double? size, Color? color}) {
    return _buildImage(
      path: _controlsRegisterIconPath,
      height: size ?? 48,
      width: size ?? 48,
      fit: BoxFit.contain,
      borderRadius: 0,
      color: color,
      errorWidget: null,
    );
  }

  static Widget reportsIcon({double? size, Color? color}) {
    return _buildImage(
      path: _reportsIconPath,
      height: size ?? 48,
      width: size ?? 48,
      fit: BoxFit.contain,
      borderRadius: 0,
      color: color,
      errorWidget: null,
    );
  }

  static Widget agenticAIIcon({double? size, Color? color}) {
    return _buildImage(
      path: _agenticAIIconPath,
      height: size ?? 48,
      width: size ?? 48,
      fit: BoxFit.contain,
      borderRadius: 0,
      color: color,
      errorWidget: null,
    );
  }

  static Widget _buildImage({
    required String path,
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
    double borderRadius = 12,
    Color? color,
    Widget? errorWidget,
  }) {
    final image = Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              height: height ?? 50,
              width: width ?? 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: (height ?? 50) * 0.5,
                color: Colors.grey.shade400,
              ),
            );
      },
    );

    return borderRadius > 0
        ? ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image,
          )
        : image;
  }
}

