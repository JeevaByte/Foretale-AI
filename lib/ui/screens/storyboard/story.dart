//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/models/result_model.dart';
//screen
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/screens/storyboard/widgets/story_analysis_panel.dart';
import 'package:foretale_application/ui/screens/storyboard/widgets/story_chart_section.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with TickerProviderStateMixin<StoryPage>, PageEntranceAnimations {
  final String _currentFileName = "story.dart";
  late ResultModel _resultModel;

  @override
  void initState() {
    super.initState();
    _resultModel = Provider.of<ResultModel>(context, listen: false);
    initializeEntranceAnimations();
    startEntranceAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _loadPage();
      }
    });
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return buildSlideAndFadeTransition(
      child: _buildMainContent(context, size),
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side - Dimensions, Facts, Graphs
            Flexible(
              flex: 2,
              child: Consumer<ResultModel>(
                builder: (context, resultModel, __) {
                  return CustomContainer(
                    title: "Analysis",
                    child: StoryAnalysisPanel(resultModel: resultModel),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            // Right side - Chart Display
            Flexible(
              flex: 5,
              child: Consumer<ResultModel>(
                builder: (context, resultModel, __) {
                  if (resultModel.getSelectedTestId == 0) {
                    return CustomContainer(
                      title: "Chart",
                      child: EmptyState(
                          title: "No test selected",
                          subtitle: "Select a test from the result page to view charts",
                          icon: Icons.analytics_outlined,
                        ),
                    );
                  }
                  
                  return CustomContainer(
                    title: "Chart",
                    child: resultModel.getIsPageLoading
                        ? buildLoadingState(context)
                        : StoryChartSection(resultModel: resultModel),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPage() async {
    if (!mounted) return;
    
    try {
      if (_resultModel.getSelectedTestId > 0) {
        await _resultModel.fetchSavedChartConfigs(context, _resultModel.getSelectedTestId);
      }
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(
        context,
        e.toString(),
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: errorStackTrace.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_loadPage",
      );
    }
  }
}
