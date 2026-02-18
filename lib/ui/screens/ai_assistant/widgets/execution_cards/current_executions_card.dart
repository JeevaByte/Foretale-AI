//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//model
import 'package:foretale_application/models/ai_assistant_model.dart';
import 'package:foretale_application/models/tests_model.dart';
//ui
import 'package:foretale_application/ui/screens/ai_assistant/widgets/shared_widgets.dart';

class CurrentExecutionsCard extends StatelessWidget {
  const CurrentExecutionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantModel>(
      builder: (context, aiModel, _) {
        final List<Test> runningTests = aiModel.getRunningTests;
        final bool hasRunning = runningTests.isNotEmpty;
        final List<Test> visibleTests = runningTests.take(4).toList();

        return InsightCard(
          title: 'Currently Executing',
          subtitle: hasRunning ? 'Triggered' : 'All quiet—no runs in flight',
          expanded: true,
          child: hasRunning
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: visibleTests
                        .map(
                          (test) => AutomationTile(
                            title: test.testName,
                            timestamp: _buildApproximateCompletionLabel(test),
                          ),
                        )
                        .toList(),
                  ),
                )
              : const EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: 'All quiet',
                  subtitle: 'No runs in flight',
                ),
        );
      },
    );
  }

  String _buildApproximateCompletionLabel(Test test) {
    final String etaFromMessage = _extractEtaFromMessage(test.testConfigExecutionMessage);
    if (etaFromMessage.isNotEmpty) {
      return etaFromMessage;
    }

    final String? historicalDuration = test.lastRunCount;
    if (historicalDuration != null && historicalDuration.trim().isNotEmpty) {
      return '≈ $historicalDuration runtime';
    }

    return '≈ few minutes';
  }

  String _extractEtaFromMessage(String message) {
    if (message.isEmpty) {
      return '';
    }

    final RegExp etaRegex = RegExp(
      r'(~?\d+\s?(?:sec|secs|s|min|mins|minutes|hr|hrs|hours))',
      caseSensitive: false,
    );
    final Match? match = etaRegex.firstMatch(message);
    if (match == null) {
      return '';
    }

    return '≈ ${match.group(0)!.trim()} left';
  }
}


