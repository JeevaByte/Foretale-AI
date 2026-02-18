//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
import 'package:foretale_application/models/ai_session_model.dart';
//ui
import 'package:foretale_application/ui/screens/ai_assistant/widgets/shared_widgets.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
//constants
import 'package:foretale_application/core/constants/colors/app_colors_v2.dart';

class SavedSessionsCard extends StatelessWidget {
  const SavedSessionsCard({super.key});

  Widget _buildTitleWidget(BuildContext context, AIAssistantModel aiModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'SAVED SESSIONS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark 
                  ? BrandColors.textSecondaryDark 
                  : BrandColors.textSecondaryLight,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              fontSize: context.responsiveFontSize(9),
            ),
          ),
        ),
        CustomIconButton(
          icon: Icons.add,
          onPressed: () {
            aiModel.setSelectedSessionId(null);
          },
          tooltip: 'Start a new Session',
          iconSize: context.iconSize(size: IconSize.small),
          padding: 1,
          iconColor: isDark ? BrandColors.accent : BrandColors.primary,
          backgroundColor: isDark 
              ? BrandColors.accent.withValues(alpha: 0.15) 
              : BrandColors.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantModel>(
      builder: (context, aiModel, _) {
        return InsightCard(
          title: 'Saved Sessions',
          subtitle: 'Pinned conversations & briefs',
          expanded: true,
          titleWidget: _buildTitleWidget(context, aiModel),
          child: const SavedSessionsList(),
        );
      },
    );
  }
}

class SavedSessionsList extends StatelessWidget {
  const SavedSessionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantModel>(
      builder: (context, aiModel, _) {
        final List<AISession> sessions = aiModel.getSessions;
        
        if (sessions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.chat_bubble_outline,
            title: 'No saved sessions',
          );
        }

        final List<AISession> sortedSessions = List.from(sessions)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        final String? selectedSessionId = aiModel.getSelectedSessionId;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: context.spacing(size: SpacingSize.small) * 0.3,
            horizontal: context.spacing(size: SpacingSize.small) * 0.3,
          ),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: sortedSessions.length,
            itemBuilder: (context, index) {
              final session = sortedSessions[index];
              final bool isSelected = selectedSessionId == session.sessionId;
              return AutomationTile(
                title: session.promptDescription,
                timestamp: _formatDifferenceInDays(session.differenceInDays),
                isSelected: isSelected,
                onTap: () {
                  aiModel.setSelectedSessionId(
                    isSelected ? null : session.sessionId,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatDifferenceInDays(int differenceInDays) {
    return differenceInDays > 0 ? '$differenceInDays day${differenceInDays == 1 ? '' : 's'} ago' : 'Just now';
  }
}

