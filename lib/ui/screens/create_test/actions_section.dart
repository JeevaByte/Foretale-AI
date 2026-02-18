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

class ActionsSection extends StatefulWidget {
  final bool isNew;
  final TabController tabController;

  const ActionsSection({
    super.key, 
    required this.isNew, 
    required this.tabController
  });

  @override
  State<ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<ActionsSection> {
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
                    // Business Actions Section
                    _buildActionsSection(context, createTestModel),
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

  Widget _buildAddActionButton(BuildContext context, GlobalKey<FormState> actionFormKey, TextEditingController actionController, CreateTestModel createTestModel) {
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
        if (actionFormKey.currentState!.validate()) {
          createTestModel.addBusinessAction(actionController.text.trim());
          actionController.clear();
        }
      },
    );
  }

  Widget _buildActionsTitle(BuildContext context, CreateTestModel createTestModel) {
    final theme = Theme.of(context);
    final fontSize = context.responsiveFontSize(14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Actions (${createTestModel.getBusinessActions.length})',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        )
      ],
    );
  }

  Widget _buildDeleteActionButton(BuildContext context, CreateTestModel createTestModel, int actionId) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = context.iconSize(size: IconSize.small) * 0.875;
    return CustomIconButton(
      onPressed: () {
        createTestModel.removeBusinessAction(actionId);
      },
      icon: Icons.delete,
      tooltip: 'Delete',
      iconSize: iconSize,
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildActionsSection(BuildContext context, CreateTestModel createTestModel) {
    final TextEditingController actionController = TextEditingController();
    final GlobalKey<FormState> actionFormKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add new action form
          Form(
            key: actionFormKey,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: actionController,
                    label: 'Enter a recommended action',
                    isEnabled: widget.isNew,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Action is required';
                      }
                      return null;
                    }
                  ),
                ),
                SizedBox(width: context.spacing(size: SpacingSize.small)),
                _buildAddActionButton(context, actionFormKey, actionController, createTestModel),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Display existing actions
          _buildActionsTitle(context, createTestModel),
          const SizedBox(height: 8),

          if (createTestModel.getBusinessActions.isEmpty)
            const EmptyState(
              title: 'No actions added',
              subtitle: 'Add an action to get started',
              icon: Icons.work_outline,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: createTestModel.getBusinessActions.length,
              itemBuilder: (context, index) {
                final action = createTestModel.getBusinessActions[index];
                return CustomOneLineInfoCard(
                  title: action.businessAction,
                  trailing: widget.isNew ? _buildDeleteActionButton(context, createTestModel, action.actionId) : null,
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
    if (createTestModel.getBusinessActions.isEmpty) {
      SnackbarMessage.showErrorMessage(context, 'Please add at least one business action');
      return;
    }
    widget.tabController.animateTo(widget.tabController.index + 1);
  }
}
