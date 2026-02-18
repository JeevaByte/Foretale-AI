//core
import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
import 'package:provider/provider.dart';
//utils
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
//ui
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_blank_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_date_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_numeric_fields.dart';
import 'package:foretale_application/ui/screens/datagrids/data_assessment/sfdg_dq_text_fields.dart';
//model
import 'package:foretale_application/models/data_assessment_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:foretale_application/ui/widgets/custom_enclosure.dart';


class DataQualityAssessmentPage extends StatefulWidget {
  final String tableName;
  const DataQualityAssessmentPage({
    super.key, 
    required this.tableName
  });

  @override
  State<DataQualityAssessmentPage> createState() => _DataQualityAssessmentPageState();
}

class _DataQualityAssessmentPageState extends State<DataQualityAssessmentPage> with TickerProviderStateMixin, PageEntranceAnimations {
  final String _currentFileName = "data_quality_assessment.dart";
  String loadText = 'Loading...';

  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;

  late DataQualityProfileModel _dataQualityProfileModel;
  late ProjectDetailsModel _projectDetailsModel;

  @override
  void initState() {
    super.initState();
    _dataQualityProfileModel = Provider.of<DataQualityProfileModel>(context, listen: false);
    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _tabController = TabController(length: _dataQualityProfileModel.getCategories.length, vsync: this);
    
    // Initialize entrance animations
    initializeEntranceAnimations();
    startEntranceAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {          
      await _loadPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    disposeEntranceAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(context),
        const SizedBox(height: 20),
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
          icon: Icons.refresh,
          onPressed: () => _loadPage(),
          tooltip: 'Refresh',
        ),
      ],
      child: content,
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'Data Profile - ${widget.tableName}',
    );
  }

  Widget _buildMainContent(BuildContext context, Size size) {
    return Consumer<DataQualityProfileModel>(
      builder: (context, model, __) {  
        if (model.getIsPageLoading) {
          return buildLoadingState(context);
        }

        if (model.getFilteredCategories().isEmpty) {
          return EmptyState(
            title: "No data profile found",
            subtitle: "Please try again later or contact support",
            icon: Icons.assessment_outlined,
          );
        }

        if (model.getSelectedCategory == null) {
          return EmptyState(
            title: "No data profile categories found",
            subtitle: "Data profile is not available",
            icon: Icons.assessment_outlined,
          );
        }
        
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                  Flexible(
                    flex: 1,
                    child: CustomContainer(
                      title: "Choose a category",
                      child: _buildCategoriesList(model.getFilteredCategories(), model),
                    ),
                  ),
                const SizedBox(width: 30),
                // Right side - Data grid
                Flexible(
                  flex: 7,
                  child: CustomContainer(
                    title: "Data profile for '${model.getSelectedCategory!}'",
                    child: _buildDataGridForCategory(model.getSelectedCategory!, model)
                  )
                ),
              ]
            ),
          ),
        );
      }
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, bool isSelected, DataQualityProfileModel model) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(size: SpacingSize.small)),
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primary.withValues(alpha: 0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.borderRadius * 0.67),
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ListTile(
        title: Text(
          category,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: () {
          model.setSelectedCategory = category;
        },
      ),
    );
  }

  Widget _buildCategoriesList(List<String> filteredCategories, DataQualityProfileModel model) {
    return ListView.builder(
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final isSelected = model.getSelectedCategory == category;
        
        return _buildCategoryItem(context, category, isSelected, model);
      },
    );
  }

  Widget _buildDataGridForCategory(String category, DataQualityProfileModel model) {
    final profiles = model.getProfilesForCategory(category);

    switch (category.toLowerCase()) {
      case 'text':
        return TextFieldsDataGrid(profiles: profiles);
      case 'numeric':
        return NumericFieldsDataGrid(profiles: profiles);
      case 'blank':
        return NullFieldsDataGrid(profiles: profiles);
      case 'date':
        return DateFieldsDataGrid(profiles: profiles);
      default:
        return EmptyState(
          title: "No profile available for '$category'",
          subtitle: "Please try again later or contact support for assistance",
          icon: Icons.assessment_outlined,
        );
    }
  }

  Future<void> _loadPage() async {
    try {
      _dataQualityProfileModel.setIsPageLoading = true;
      await _dataQualityProfileModel.fetchDataQualityRepByTable(context);
    } catch (e, errorStackTrace) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(context, e.toString(),
            logError: true,
            errorMessage: e.toString(),
            errorStackTrace: errorStackTrace.toString(),
            errorSource: _currentFileName,
            severityLevel: 'Critical',
            requestPath: "_loadPage");
      }
    } finally {
      _dataQualityProfileModel.setIsPageLoading = false;
    }
  }
}
