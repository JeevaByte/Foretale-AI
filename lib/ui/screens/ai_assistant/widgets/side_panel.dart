//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
//ui
import 'package:foretale_application/ui/screens/ai_assistant/widgets/execution_cards/current_executions_card.dart';
import 'package:foretale_application/ui/screens/ai_assistant/widgets/execution_cards/execution_monitor_card.dart';
import 'package:foretale_application/ui/screens/ai_assistant/widgets/execution_cards/saved_sessions_card.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

class StatusBadgesSection extends StatelessWidget {
  const StatusBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantModel>(
      builder: (context, aiModel, _) {
        final badges = <Widget>[];
        badges.add(
          _StatusBadge(
            icon: Icons.wifi_tethering_rounded,
            iconColor: aiModel.getIsSynced ? BrandColors.info : BrandColors.danger,
            backgroundColor: aiModel.getIsSynced 
                ? BrandColors.info.withValues(alpha: 0.12) 
                : BrandColors.danger.withValues(alpha: 0.12),
            label: aiModel.getIsSynced ? 'Synced' : 'Not Synced',
          ),
        );
        badges.add(
          _StatusBadge(
            icon: Icons.security_rounded,
            iconColor: aiModel.getIsGuardrailActivated ? BrandColors.success : BrandColors.warning,
            backgroundColor: aiModel.getIsGuardrailActivated 
                ? BrandColors.success.withValues(alpha: 0.12) 
                : BrandColors.warning.withValues(alpha: 0.12),
            label: aiModel.getIsGuardrailActivated ? 'Guardrail Active' : 'Guardrail Inactive',
          ),
        );
        badges.add(
          _StatusBadge(
            icon: Icons.analytics_rounded,
            iconColor: aiModel.getIsExplainableAIEnabled ? BrandColors.accent : BrandColors.textSecondaryLight,
            backgroundColor: aiModel.getIsExplainableAIEnabled 
                ? BrandColors.accent.withValues(alpha: 0.12) 
                : BrandColors.textSecondaryLight.withValues(alpha: 0.08),
            label: aiModel.getIsExplainableAIEnabled ? 'Explainable AI' : 'Explainable AI Disabled',
          ),
        );
        
        if (badges.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: badges
              .map((badge) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing(size: SpacingSize.small) * 0.25,
                      ),
                      child: badge,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = context.borderRadius * 0.75;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing(size: SpacingSize.small) * 0.75,
        vertical: context.spacing(size: SpacingSize.small) * 0.625,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: iconColor.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: isDark ? 6 : 4,
            offset: const Offset(0, 1.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 11.5,
            ),
          ),
          SizedBox(width: context.spacing(size: SpacingSize.small) * 0.625),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: context.responsiveFontSize(10),
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? BrandColors.textPrimaryDark.withValues(alpha: 0.9)
                    : BrandColors.textPrimaryLight.withValues(alpha: 0.85),
                letterSpacing: 0.15,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius * 1.25;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BrandColors.surfaceDark.withValues(alpha: 0.95),
                  BrandColors.surfaceElevatedDark.withValues(alpha: 0.98),
                ],
                stops: const [0.0, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BrandColors.surfaceLight.withValues(alpha: 0.98),
                  BrandColors.backgroundDim.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 1.0],
              ),
        border: Border.all(
          color: isDark
              ? BrandColors.borderDark.withValues(alpha: 0.3)
              : BrandColors.borderLight.withValues(alpha: 0.25),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: isDark ? 24 : 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? BrandColors.accent.withValues(alpha: 0.03)
                : BrandColors.primary.withValues(alpha: 0.02),
            blurRadius: isDark ? 32 : 20,
            offset: const Offset(0, 0),
            spreadRadius: isDark ? -4 : -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(spacing * 1.1),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StatusBadgesSection(),
              SizedBox(height: spacing * 1.25),
              const ExecutionMonitorCard(),
              SizedBox(height: spacing * 0.85),
              Expanded(
                flex: 1,
                child: const CurrentExecutionsCard(),
              ),
              SizedBox(height: spacing * 0.85),
              Expanded(
                flex: 1,
                child: const SavedSessionsCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

