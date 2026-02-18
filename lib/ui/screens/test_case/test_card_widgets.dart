import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/ui/screens/analysis/result.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/animation/animated_checkbox.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/screens/test_case/test_service.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/widgets/animation/animated_switcher.dart';
import 'package:foretale_application/ui/widgets/category_list_widget.dart';
import 'package:foretale_application/ui/widgets/custom_radio_button.dart';

enum FilterOption { all, selected, unselected }

// TestsListView Widget
class TestsListView extends StatefulWidget {
  const TestsListView({super.key});

  @override
  _TestsListViewState createState() => _TestsListViewState();
}

class _TestsListViewState extends State<TestsListView> {
  String selectedCategory = "All";
  FilterOption filterOption = FilterOption.all;

  late final TestsModel _testsModel;
  late InquiryResponseModel _inquiryResponseModel;

  @override
  void initState() {
    super.initState();

    _testsModel = Provider.of<TestsModel>(context, listen: false);
    _inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inquiryResponseModel.clearResponseList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: double.infinity,
            ),
            child: Column(
              children: [
                _buildToggleFilter(),
                SizedBox(height: context.spacing(size: SpacingSize.medium)),
                Expanded(
                  child: _buildCategoryList(selectedCategory, (cat) => setState(() => selectedCategory = cat)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer<TestsModel>(
            builder: (context, model, child) {
              var testsList = selectedCategory == "All" 
                                ? model.filteredTestsList 
                                : model.filteredTestsList.where((test) => test.testCategory == selectedCategory).toList();
              
              // Apply filter based on selected option
              if (filterOption == FilterOption.selected) {
                testsList = testsList.where((test) => test.isSelected).toList();
              } else if (filterOption == FilterOption.unselected) {
                testsList = testsList.where((test) => !test.isSelected).toList();
              }

              return testsList.isEmpty
                ? _buildNoTestsFound(context)
                : CustomAnimatedSwitcher(
                    child: ListView.builder(
                      key: ValueKey<String>(selectedCategory),
                      itemCount: testsList.length,
                      itemBuilder: (context, index) {
                        final test = testsList[index];
                        return _buildTestCard(context, test);
                      },
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }

  //navigate to the result screen
  void _navigateToResultScreen(BuildContext context, Test test) {
    context.fadeNavigateTo(ResultScreen(test: test));
  }
  
  Widget _buildTestNameText(BuildContext context, String testName) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(16);
    return Text(
      testName,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildActionsButton(BuildContext context, Test test) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExpandableActionsButton(
      actions: [
        ActionItem(
          icon: test.showDescription ? Icons.info : Icons.info_outline,
          onPressed: () => _testsModel.toggleTestDescription(test.testId),
          tooltip: test.showDescription ? "Hide description" : "Show description",
          isActive: test.showDescription,
        ),
        ActionItem(
          icon: Icons.delete_rounded,
          onPressed: () => test.isProjectCreatedTest ? TestService.onDeleteTestTap(context, test, _testsModel) : null,
          tooltip: "Delete test permanently",
          isActive: test.isProjectCreatedTest,
        ),
        ActionItem(
          icon: test.markAsCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          onPressed: () => test.isSelected ? TestService.onMarkAsCompletedTap(context, test, _testsModel) : null,
          tooltip: test.markAsCompleted ? "Mark as review pending" : "Mark as reviewed",
          isActive: test.markAsCompleted,
        ),
        ActionItem(
          icon: test.config.trim().isNotEmpty ? Icons.settings : Icons.settings_outlined,
          onPressed: () => test.isSelected ? TestService.onViewConfigurationTap(context, test, _testsModel) : null,
          tooltip: "Script",
          isActive: test.config.trim().isNotEmpty && test.configImpactStatement.trim().isNotEmpty,
        ),
        ActionItem(
          icon: test.config.trim().isNotEmpty ? Icons.play_circle_fill_rounded : Icons.play_circle_outline_rounded,
          onPressed: () => test.isSelected ? TestService.saveAndRunSqlQuery(context, test, test.config, test.configImpactStatement) : null,
          tooltip: "Run",
          isActive: test.config.trim().isNotEmpty && test.configImpactStatement.trim().isNotEmpty,
        ),
      ],
      backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
      activeColor: colorScheme.primary,
      inactiveColor: colorScheme.primary,
      expansionDirection: Axis.horizontal,
      iconSize: context.iconSize(size: IconSize.small),
      actionIconSize: context.iconSize(size: IconSize.small),
      buttonSize: context.iconSize(size: IconSize.medium) * 1.25,
    );
  }

  Widget _buildTestDescriptionText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(14);
    return Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.9),
        height: 1.4,
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildTestChips(BuildContext context, Test test) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final runSpacing = context.spacing(size: SpacingSize.small) * 0.75;
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        CustomChip(
          label: test.testCode, 
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
          textColor: colorScheme.primary.withValues(alpha: 0.8), 
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5)
        ),
        CustomChip(
          label: test.testCriticality, 
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
          textColor: colorScheme.primary.withValues(alpha: 0.8), 
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5)
        ),
        CustomChip(
          label: test.testRunType, 
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
          textColor: colorScheme.primary.withValues(alpha: 0.8), 
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5)
        ),
        CustomChip(
          label: test.testRunProgram, 
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1), 
          textColor: colorScheme.primary.withValues(alpha: 0.8), 
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5)
        ),
      ],
    );
  }

  Widget _buildTestCard(BuildContext context, Test test) {   
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = (_testsModel.getSelectedTestId == test.testId);
    final borderRadius = context.borderRadius;
    
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(size: SpacingSize.small)),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.5), 
          width: isSelected ? 2 : 0.5
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => test.isSelected ? TestService.onTestTap(context, _inquiryResponseModel, _testsModel, test) : null,
            child: Padding(
              padding: EdgeInsets.all(context.cardPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftSideOfCard(context, test),
                  SizedBox(width: context.spacing(size: SpacingSize.medium)),
                  _buildRightSideOfCard(context, test),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildLeftSideOfCard(BuildContext context, Test test) {
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedCheckbox(
                isSelected: test.isSelected,
                onTap: () => TestService.handleTestSelection(context, test),
              ),
              SizedBox(width: context.spacing(size: SpacingSize.medium)),
              Expanded(
                child: _buildTestNameText(context, test.testName),
              ),
              
              // Combined actions button
              _buildActionsButton(context, test),
            ],
          ),
          SizedBox(height: context.spacing(size: SpacingSize.small)),
          // Test description
          if(test.showDescription)
          _buildTestDescriptionText(context, test.testDescription),
          if(test.showDescription)
          SizedBox(height: context.spacing(size: SpacingSize.medium)),
          // Impact statement
          if(test.showImpact)
          _buildTestDescriptionText(context, test.impactStatement),
          if(test.showImpact)
          SizedBox(height: context.spacing(size: SpacingSize.medium)),
          _buildTestDescriptionText(context, "Possible Risks: ${test.identifiedRisks}"),
          SizedBox(height: context.spacing(size: SpacingSize.medium)),
          _buildTestChips(context, test),
        ],
      ),
    );
  }

  Widget _buildRightSideOfCard(BuildContext context, Test test) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildShowResultsWidget(context, test),
        ],
      ),
    );
  }

  Widget _buildShowResultsWidget(BuildContext context, Test test) {
    bool showResults = test.testConfigExecutionStatus == "Completed";
    String tooltip = showResults ? 'Show results' : test.testConfigExecutionMessage.replaceAll('<ERR_START>', '').replaceAll('<ERR_END>', '');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent
      ),
      child: GestureDetector(
        onTap: () {
          if(!test.isSelected && test.testId == 0){
            return;
          }

          TestService.onTestTapShowResults(context, _inquiryResponseModel, _testsModel, test);
          if(showResults){
            _navigateToResultScreen(context, test);
          }
        },
        child: Column(
          children: [
            _buildStatusIndicator(context, test.testConfigExecutionStatus, tooltip),
            const SizedBox(height: 2),
            _buildLastRunCount(context, test.lastRunCount),
            const SizedBox(height: 4),

          ],
        ),
      ),
    );
  }

  Widget _buildLastRunCount(BuildContext context, String? lastRunCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontSize = context.responsiveFontSize(12);
    
    return Text(
      (lastRunCount?? '') + (lastRunCount?.isNotEmpty ?? false ? ' ago' : ''),
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status, String tooltip) {
    const statusConfig = {
      "Completed": {
        "label": "EXECUTED",
        "backgroundColor": Colors.green,
      },
      "Running": {
        "label": "RUNNING", 
        "backgroundColor": Colors.amber,
      },
      "Failed": {
        "label": "FAILED",
        "backgroundColor": Colors.red,
      },
    };

    final config = statusConfig[status];
    final color = config?["backgroundColor"] as MaterialColor?;
    final label = config?["label"] as String? ?? status;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius;
    final fontSize = context.responsiveFontSize(9);
    
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 100, // Fixed width for consistency
        height: 24, // Fixed height for consistency
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing(size: SpacingSize.small),
          vertical: context.spacing(size: SpacingSize.small) / 2,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color != null ? color.withValues(alpha: 0.3) : colorScheme.outline.withValues(alpha: 0.5),
            width: 0.5
          ),
        ),
        child: Center(
          child: Text(
            label.isEmpty ? "PENDING" : label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color ?? colorScheme.secondary,
              letterSpacing: 1.0,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
    );
  }

  Widget _buildNoTestsFound(BuildContext context) {
    return const Center(
      child: EmptyState(
        title: "No tests found",
        subtitle: "Start by creating a new test",
        icon: Icons.search_off,
      ),
    );
  }

  // Category List Widget Methods
  Widget _buildCategoryList(String selectedCategory, Function(String) onCategorySelected) {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final categories = ["All", ...model.getTestsList.map((e) => e.testCategory).toSet()];
        
        return CategoryListWidget(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
          categories: categories,
          getCount: (cat) => cat == 'All' 
              ? model.getTestsList.length
              : model.getTestsList.where((t) => t.testCategory == cat).length,
        );
      },
    );
  }

  // Toggle Filter Widget
  Widget _buildToggleFilter() {
    return Consumer<TestsModel>(
      builder: (context, model, child) {
        final selectedCount = model.getTestsList.where((test) => test.isSelected).length;
        final unselectedCount = model.getTestsList.where((test) => !test.isSelected).length;
        final allCount = model.getTestsList.length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleHeader(context),
            _buildToggleContent(context, selectedCount, unselectedCount, allCount),
          ],
        );
      },
    );
  }

  Widget _buildToggleHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = context.borderRadius;
    final iconSize = context.iconSize(size: IconSize.small) * 1.25;
    final fontSize = context.responsiveFontSize(14);
    final padding = context.spacing(size: SpacingSize.medium);
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.spacing(size: SpacingSize.small),
        0,
        context.spacing(size: SpacingSize.small),
        context.spacing(size: SpacingSize.small),
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
        child: Row(
          children: [
            Icon(
              Icons.checklist_rounded,
              color: colorScheme.primary,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Text(
              "Show selected",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleContent(BuildContext context, int selectedCount, int unselectedCount, int allCount) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = context.borderRadius;
    final margin = context.spacing(size: SpacingSize.small);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing(size: SpacingSize.small) / 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomRadioButton<FilterOption>(
                  groupValue: filterOption,
                  onChanged: (value) => setState(() => filterOption = value),
                  options: [
                    RadioOption(value: FilterOption.all, label: 'All ($allCount)'),
                    RadioOption(value: FilterOption.selected, label: 'Selected ($selectedCount)'),
                    RadioOption(value: FilterOption.unselected, label: 'Unselected ($unselectedCount)'),
                  ],
                  activeColor: colorScheme.secondary,
                  inactiveColor: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

} 
