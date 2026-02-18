//core
import 'package:flutter/material.dart';
//constants
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/create_test_model.dart';
//ui
//styles
import 'package:foretale_application/ui/widgets/custom_info_card_one_line.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:provider/provider.dart';

class RisksSection extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const RisksSection({
    super.key, 
    required this.isNew, 
    required this.tabController
  });

  @override
  State<RisksSection> createState() => _RisksSectionState();
}

class _RisksSectionState extends State<RisksSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTestModel>(
      builder: (context, createTestModel, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Business Risks Section
                    _buildRisksSection(context, createTestModel)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildActionButtons(context, createTestModel),
          ],
        );
      },
    );
  }

  Widget _buildAddRiskButton(BuildContext context, GlobalKey<FormState> riskFormKey, TextEditingController riskController, CreateTestModel createTestModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 1.5;
    return CustomIconButton(
      iconSize: iconSize,
      icon: Icons.add,
      tooltip: 'Add',
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      isEnabled: widget.isNew,
      onPressed: () {
        if (riskFormKey.currentState!.validate()) {
          createTestModel.addBusinessRisk(riskController.text.trim());
          riskController.clear();
        }
      },
    );
  }

  Widget _buildRisksTitle(BuildContext context, CreateTestModel createTestModel) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Text(
      'Risks (${createTestModel.getBusinessRisks.length})',
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDeleteRiskButton(BuildContext context, CreateTestModel createTestModel, int riskId) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 0.875;
    return CustomIconButton(
      onPressed: () {
        createTestModel.removeBusinessRisk(riskId);
      },
      icon: Icons.delete,
      tooltip: 'Delete',
      iconSize: iconSize,
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildRisksSection(BuildContext context, CreateTestModel createTestModel) {
    final TextEditingController riskController = TextEditingController();
    final GlobalKey<FormState> riskFormKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add new risk form
          Form(
            key: riskFormKey,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: riskController,
                    label: 'Enter a risk statement',
                    isEnabled: widget.isNew,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Risk is required';
                      }
                      return null;
                    }
                  ),
                ),
                SizedBox(width: context.spacing(size: SpacingSize.small)),
                _buildAddRiskButton(context, riskFormKey, riskController, createTestModel),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Display existing risks
          _buildRisksTitle(context, createTestModel),
          const SizedBox(height: 8),

          if (createTestModel.getBusinessRisks.isEmpty)
            const EmptyState(
              title: 'No risks added',
              subtitle: 'Add a risk to get started',
              icon: Icons.warning_outlined,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: createTestModel.getBusinessRisks.length,
              itemBuilder: (context, index) {
                final risk = createTestModel.getBusinessRisks[index];
                return CustomOneLineInfoCard(
                  title: risk.riskStatement,
                  trailing: widget.isNew ? _buildDeleteRiskButton(context, createTestModel, risk.riskId) : null,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CreateTestModel createTestModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.medium) * 2;
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        CustomIconButton(
          icon: Icons.arrow_back,
          iconSize: iconSize,
          onPressed: () => _handlePreviousButton(),
          tooltip: 'Previous',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
        SizedBox(width: spacing),
        // Next button
        CustomIconButton(
          icon: Icons.arrow_forward,
          iconSize: iconSize,
          onPressed: () => _handleNextButton(createTestModel),
          tooltip: 'Next',
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  void _handlePreviousButton() {
    widget.tabController.animateTo(widget.tabController.index - 1);
  }

  void _handleNextButton(CreateTestModel createTestModel) {
    if (createTestModel.getBusinessRisks.isEmpty) {
      SnackbarMessage.showErrorMessage(context, 'Please add at least one business risk');
      return;
    }
    widget.tabController.animateTo(widget.tabController.index + 1);
  }
}
