import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_container.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
// Utils
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
// Models
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
// Widgets
import 'package:foretale_application/core/utils/message_helper.dart';

class QuestionsInquiryLv extends StatefulWidget {
  const QuestionsInquiryLv({super.key});

  @override
  State<QuestionsInquiryLv> createState() => _QuestionsInquiryLvState();
}

class _QuestionsInquiryLvState extends State<QuestionsInquiryLv> {
  final String _currentFileName = "inquiry_questions_lv.dart";
  late InquiryQuestionModel inquiryQuestionModel;
  late InquiryResponseModel inquiryResponseModel;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Track loading state for each button using a map
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InquiryQuestionModel>(
      builder: (context, model, child) {
        final questions = model.getFilteredQuestionsList;
        return Column(
          children: [
            _buildStatusMetrics(model),
            _buildSearchAndAddBar(context, model),
            if (model.getIsPageLoading)
              buildLoadingState(context)
            else
            Flexible(
              fit: FlexFit.loose,
              child: questions.isEmpty
                  ? _buildEmptyState()
                  : _buildQuestionsList(context, questions, model),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusMetrics(InquiryQuestionModel model) {
    final allQuestions = model.getFilteredQuestionsList;
    final openCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'open')
        .length;
    final closeCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'close')
        .length;
    final deferCount = allQuestions
        .where((q) => q.questionStatus.toLowerCase() == 'defer')
        .length;

    return _buildStatusMetricsContent(context, openCount, closeCount, deferCount);
  }

  Widget _buildQuestionsList(BuildContext context, List<dynamic> questions, InquiryQuestionModel model) {
    final padding = context.spacing(size: SpacingSize.medium);
    return ListView.builder(
      key: ValueKey<String>(_searchQuery),
      controller: _scrollController,
      padding: EdgeInsets.all(padding),
      itemCount: questions.length,
      itemBuilder: (context, index) => _buildQuestionCard(context, model, questions[index]),
    );
  }

  Widget _buildStatusMetricsContent(BuildContext context, int openCount, int closeCount, int deferCount) {
    final padding = context.spacing(size: SpacingSize.medium);
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusMetric(context, "Open", openCount, Colors.green),
          _buildStatusMetric(context, "Closed", closeCount, Colors.red),
          _buildStatusMetric(context, "Deferred", deferCount, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSearchAndAddBar(BuildContext context, InquiryQuestionModel model) {
    return _buildSearchAndAddBarContent(context, model);
  }

  Widget _buildSearchAndAddBarContent(BuildContext context, InquiryQuestionModel model) {
    final padding = context.cardPadding;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: CustomTextField(
              controller: _searchController,
              label: "Search...",
              isEnabled: true,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
                model.filterData(_searchQuery);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, InquiryQuestionModel model, dynamic question) {
    final isSelected = (model.getSelectedInquiryQuestionId == question.questionId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius * 1.5;
    final padding = context.cardPadding;
    
    return Hero(
      tag: 'question-${question.questionId}',
      child: Container(
        margin: EdgeInsets.only(bottom: spacing * 0.75),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary.withValues(alpha: 0.15) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.outline.withValues(alpha: 0.5), 
            width: isSelected ? 2 : 0.5
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async{
               await _handleQuestionCardTap(context, model, question);
            },
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeftSideOfCard(context, model, question),
                    ],
                  ),
                  const SizedBox(height: 3),
                  _buildSecondRowCard(context, model, question),
                   const SizedBox(height: 3),
                  _buildActionButtons(context, model, question)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSideOfCard(BuildContext context, InquiryQuestionModel model, dynamic question) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(16);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              fontSize: fontSize,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondRowCard(BuildContext context, InquiryQuestionModel model, dynamic question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildInfoChip(context, Icons.work_outline_rounded, question.topic),
        const SizedBox(width: 16),
        _buildInfoChip(context, Icons.calendar_today_outlined, question.createdDate, iconSize: 12),
        const SizedBox(width: 16),
        _buildInfoChip(context, Icons.person_outline_rounded, question.createdBy.isEmpty ? 'Unknown' : question.createdBy, iconSize: 12),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, InquiryQuestionModel model, dynamic question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            _buildStatusIconButton(
              context,
              icon: Icons.lock_open_rounded,
              tooltip: "Mark as Open",
              color: Colors.green,
              statusValue: 'Open',
              question: question,
            ),
            const SizedBox(width: 8),
            _buildStatusIconButton(
              context,
              icon: Icons.check_circle_outline_rounded,
              tooltip: "Mark as Close",
              color: Colors.red,
              statusValue: 'Close',
              question: question,
            ),
            const SizedBox(width: 8),
            _buildStatusIconButton(
              context,
              icon: Icons.access_time_rounded,
              tooltip: "Mark as Defer",
              color: Colors.orange,
              statusValue: 'Defer',
              question: question,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, {double? iconSize}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final defaultIconSize = context.iconSize(size: IconSize.small) * 0.875;
    final chipIconSize = iconSize ?? defaultIconSize;
    final fontSize = context.responsiveFontSize(12);
    final spacing = context.spacing(size: SpacingSize.small) / 2;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: chipIconSize,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: fontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMetric(BuildContext context, String label, int count, Color color) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final iconSize = context.iconSize(size: IconSize.small) * 0.25;
    final fontSize = context.responsiveFontSize(14);
    
    return ModernContainer(
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: iconSize, color: color),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              "$label: $count",
              style: textTheme.titleSmall?.copyWith(
                color: color,
                fontSize: fontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      title: "No questions yet",
      subtitle: "Please create a new question",
      icon: Icons.question_answer_outlined,
    );
  }

  Widget _buildStatusIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color color,
    required String statusValue,
    required dynamic question,
  }) {
    final isSelected = question.questionStatus.toLowerCase() == statusValue.toLowerCase();
    // Create a unique key for this button's loading state
    final loadingKey = '${question.questionId}_$statusValue';
    final isLoading = _loadingStates[loadingKey] ?? false;
    final iconSize = context.iconSize(size: IconSize.medium) * 1.5;

    return CustomIconButton(
      icon: icon,
      iconSize: iconSize,
      onPressed: () async {
        await _iconStatusToggle(context, question, statusValue, loadingKey);
      },
      tooltip: tooltip,
      backgroundColor: color.withValues(alpha: 0.1),
      iconColor: isSelected ? color : color.withValues(alpha: 0.2),
      isProcessing: isLoading,
      borderWidth: isSelected ? 2 : 0.5,
    );

  }

  Future<void> _iconStatusToggle(BuildContext context, dynamic question, String statusValue, String loadingKey) async {
    try {
        setState(() {
          _loadingStates[loadingKey] = true;
        });

        int resultId = await inquiryQuestionModel.updateQuestionStatus(context, question, statusValue);

        if (resultId > 0) {
          setState(() {
            _loadingStates[loadingKey] = false;
          });
        }
      } catch (e) {
        setState(() {
          _loadingStates[loadingKey] = false;
        });

        SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: e.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_iconStatusToggle"
          );
      }
  }

  Future<void> _handleQuestionCardTap(BuildContext context, InquiryQuestionModel model, dynamic question) async {
    try {
      inquiryResponseModel.setIsPageLoading(true);
      model.updateQuestionIdSelection(question.questionId);
      await inquiryResponseModel.fetchResponsesByReference(context, question.questionId, 'question');
    } catch (e) {
      SnackbarMessage.showErrorMessage(context, 
        "Something went wrong! Please contact support for assistance.",
        logError: true,
        errorMessage: e.toString(),
        errorStackTrace: e.toString(),
        errorSource: _currentFileName,
        severityLevel: 'Critical',
        requestPath: "_handleQuestionCardTap",
      );
    } finally {
      inquiryResponseModel.setIsPageLoading(false);
    } 
  }

  Future<void> _loadResponses() async {
    await inquiryResponseModel.fetchResponsesByReference(context, inquiryQuestionModel.getSelectedInquiryQuestionId, 'question');
  }

  Future<void> _loadPage() async {
    try {
      inquiryQuestionModel.setIsPageLoading = true;
      await inquiryQuestionModel.fetchQuestionsByProject(context);

      if (inquiryQuestionModel.getSelectedInquiryQuestionId > 0) {
        await _loadResponses();
      }
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      inquiryQuestionModel.setIsPageLoading = false;
    } 
  }  
}
