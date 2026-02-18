//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
//ui
import 'package:foretale_application/ui/screens/ai_assistant/widgets/shared_widgets.dart';
import 'package:foretale_application/ui/screens/test_case/test_config.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

class ExecutionMonitorCard extends StatelessWidget {
  const ExecutionMonitorCard({super.key});

  Widget _buildMetricsWrap(BuildContext context, int runningCount, int totalControls) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ResponsiveMetricsWrap(
      metrics: [
        MetricTile(
          label: 'running',
          value: '$runningCount',
          color: runningCount > 0
              ? BrandColors.info
              : (isDark ? BrandColors.textSecondaryDark : BrandColors.textSecondaryLight),
        ),
        MetricTile(
          label: 'controls',
          value: '$totalControls',
          color: isDark ? BrandColors.accent : BrandColors.primary,
          onTap: () => context.fadeNavigateTo(const TestConfigPage()),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress, int runningCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = context.borderRadius * 0.75;
    final progressColor = runningCount > 0 
        ? BrandColors.info 
        : (isDark ? BrandColors.textSecondaryDark : BrandColors.textSecondaryLight);
    
    return Column(
      children: [
        SizedBox(height: context.spacing(size: SpacingSize.small) * 0.8),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: 5.5,
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: progressColor.withValues(alpha: isDark ? 0.08 : 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.5,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor.withValues(alpha: 0.95),
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantModel>(
      builder: (context, aiModel, _) {
        final int runningCount = aiModel.getRunningTestsCount;
        final int totalControls = aiModel.getTotalControlsCount;
        final double progress = aiModel.getExecutionProgress;

        return InsightCard(
          title: 'Execution Monitor',
          subtitle: runningCount == 0
              ? 'No tests currently executing'
              : 'Tracking $runningCount active run${runningCount == 1 ? '' : 's'}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricsWrap(context, runningCount, totalControls),
              _buildProgressBar(context, progress, runningCount),
            ],
          ),
        );
      },
    );
  }
}

class _ResponsiveMetricsWrap extends StatelessWidget {
  final List<MetricTile> metrics;

  const _ResponsiveMetricsWrap({
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.medium) * 0.85;
    
    if (metrics.length == 2) {
      return Row(
        children: [
          Expanded(child: metrics[0]),
          SizedBox(width: spacing),
          Expanded(child: metrics[1]),
        ],
      );
    }
    
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: metrics,
    );
  }
}

