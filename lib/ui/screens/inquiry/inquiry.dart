//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/inquiry/create_question.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
import 'package:foretale_application/ui/widgets/ai_box/ai_box.dart';
import 'package:foretale_application/ui/screens/inquiry/inquiry_questions_lv.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';


class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final TextEditingController _searchController = TextEditingController();
  
  late InquiryQuestionModel inquiryQuestionModel;
  late UserDetailsModel userDetailsModel;

  @override
  void initState() {
    super.initState();
    inquiryQuestionModel = Provider.of<InquiryQuestionModel>(context, listen: false);
    userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    inquiryQuestionModel.updateQuestionIdSelection(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(context),
        const SizedBox(height: 8),
        Expanded(
          child: _buildMainContent(context, size),
        ),
      ],
    );

    return CustomPageWrapper(
      size: size,
      onBackPressed: () => Navigator.pop(context),
      onHomePressed: () => context.fadeNavigateTo(const ProjectModules()),
      additionalActions: [
        ActionItem(
          icon: Icons.add,
          onPressed: () => _navigateToCreateQuestion(context),
          tooltip: 'Create Question',
        ),
        ActionItem(
          icon: Icons.refresh,
          onPressed: () => inquiryQuestionModel.fetchQuestionsByProject(context),
          tooltip: 'Refresh',
        ),
      ],
      enableGradient: true,
      child: content,
    );
  }

  void _navigateToCreateQuestion(BuildContext context) {
    context.fadeNavigateTo(const QuestionsScreen(isNew: true));
  }


  Widget _buildTopSection(BuildContext context) {
    return const ProjectHeaderSection(
      projectName: "Gather",
      sectionTitle: 'Understanding business',
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          Flexible(
            flex: 6,
            child: const CustomContainer(
              title: "Available Questions",
              child: QuestionsInquiryLv(),
            ),
          ),
          const SizedBox(width: 4),
          Consumer<InquiryQuestionModel>(
            builder: (context, model, child) {
              if (model.getSelectedInquiryQuestionId == 0) {
                return const SizedBox.shrink();
              }
              return Flexible(
                flex: 2,
                child: CustomContainer(
                  title: "Chat",
                  padding: const EdgeInsets.all(2),
                  child: AIBox(
                    key: ValueKey('inquiry_chat_${model.getSelectedInquiryQuestionId}'),
                    drivingModel: model,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
