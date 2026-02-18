//core
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/ecs/ecs_task_service.dart';
import 'package:foretale_application/core/utils/file_size.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_bar.dart';
import 'package:foretale_application/core/utils/quick_widgets/build_tab_header.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/projects/project_modules.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';
import 'package:foretale_application/ui/widgets/category_list_widget.dart';
import 'package:foretale_application/ui/widgets/custom_text_field.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

//models
import 'package:foretale_application/models/file_upload_summary_model.dart';
import 'package:foretale_application/models/enums/upload_status_enum.dart';
//utils
import 'package:foretale_application/core/utils/message_helper.dart';

//screens
import 'package:foretale_application/ui/screens/data_upload/column_mapping_screen.dart';
import 'package:foretale_application/ui/screens/data_upload/data_quality_assessment.dart';
import 'package:foretale_application/ui/screens/data_upload/upload_confirmation.dart';
//widgets
import 'package:foretale_application/ui/widgets/custom_alert.dart';
import 'package:foretale_application/ui/widgets/custom_chip.dart';
import 'package:foretale_application/ui/widgets/custom_icon.dart';
import 'package:foretale_application/ui/widgets/custom_icon_button.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/core/utils/page_animations.dart';
import 'package:foretale_application/ui/widgets/custom_project_header_section.dart';
//services
import 'package:foretale_application/core/services/s3/s3_activites.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
//utils
import 'package:foretale_application/core/utils/responsive.dart';
//services
import 'package:foretale_application/core/services/mixins/polling_mixin.dart';

class UploadScreenWizard extends StatefulWidget {
  const UploadScreenWizard({super.key});

  @override
  State<UploadScreenWizard> createState() => _UploadScreenWizardState();
}

class UploadWizardPollingController extends ChangeNotifier with PollingMixin {}

class _UploadScreenWizardState extends State<UploadScreenWizard> with TickerProviderStateMixin<UploadScreenWizard>, PageEntranceAnimations {
  final String _currentFileName = "upload_screen_wizard.dart";

  late TabController _tabController;

  late ProjectDetailsModel _projectDetailsModel;
  late UploadSummaryModel _uploadSummaryModel;
  late UserDetailsModel _userDetailsModel;
  late UploadWizardPollingController _pollingController;

  FilePickerResult? _filePickerResult;

  final S3Service _s3Service = S3Service();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize entrance animations
    initializeEntranceAnimations();
    startEntranceAnimations();

    _projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _uploadSummaryModel = Provider.of<UploadSummaryModel>(context, listen: false);
    _userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    _pollingController = UploadWizardPollingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPage();
      
      if (mounted) {
        _startPollingIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    disposeEntranceAnimations();
    _tabController.dispose();
    _uploadSummaryModel.searchQuery = "";
    _searchController.dispose();
    _pollingController.stopPolling();
    _pollingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(context),
        const SizedBox(height: 28),
        _buildTabSection(context),
        const SizedBox(height: 8),
        _buildTabContent(context),
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
      enableGradient: true,
      child: buildSlideAndFadeTransition(child: content),
    );
  }

  Widget _buildTableTitle(BuildContext context, String tableName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      tableName,
      style: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return ProjectHeaderSection(
      projectName: _projectDetailsModel.getName,
      sectionTitle: 'Data upload wizard',
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: 
      buildTab(
        context,
        tabController: _tabController,
        tabs: [
          buildTabHeader(context, icon: Icons.grid_4x4_rounded, label: 'Choose & Upload'),
          buildTabHeader(context, icon: Icons.upload, label: 'Map Columns'),
          buildTabHeader(context, icon: Icons.confirmation_num, label: 'Confirm Upload'),
        ],
        onTap: (index, isActivateTabs) => _handleTabChange(index, isActivateTabs),
        isActivateTabs: true,
      ),
    );
  }

  void _handleTabChange(int index, bool isActivateTabs){
    if (_tabController.indexIsChanging && index > _tabController.previousIndex) {
      _tabController.animateTo(_tabController.previousIndex);
    }
  }

  Widget _buildTabContent(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildListTables(context),
            _buildMapColumns(context),
            _buildUploadConfirmation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMapColumns(BuildContext context) {
    return ColumnMappingScreen(onConfirm: () => _tabController.animateTo(2));
  }

  Widget _buildUploadConfirmation(BuildContext context) {
    return UploadConfirmationPage(
      onConfirm: () => _tabController.animateTo(0),
      pollingController: _pollingController,
      onStartPolling: _startPollingIfNeeded,
    );
  }

  Widget _buildListTables(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 6),
          Expanded(
            child: Consumer<UploadSummaryModel>(
              builder: (context, model, child) {
                if (model.getIsPageLoading){
                  return buildLoadingState(context);
                }
                return Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Consumer<UploadSummaryModel>(
                        builder: (context, model, child) {
                          final categories = ["All", ...model.getUploadSummaryList.map((e) => e.componentName).toSet()];
                          
                          return CategoryListWidget(
                            selectedCategory: model.getSelectedCategory,
                            onCategorySelected: (category) {model.setSelectedCategory = category;},
                            categories: categories,
                            getCount: (cat) => cat == 'All' 
                                ? model.getUploadSummaryList.length
                                : model.getUploadSummaryList.where((t) => t.componentName == cat).length,
                          );
                        },
                      ),
                    ),
                    Flexible(
                      flex: 7,
                      child: _buildTabChooseTable(context, model),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Selector<UploadSummaryModel, String>(
        selector: (context, model) => model.searchQuery,
        builder: (context, searchQuery, _) {
          return CustomTextField(
            controller: _searchController,
            label: "Search...",
            isEnabled: true,
            onChanged: (value) {
              _uploadSummaryModel.searchQuery = value.trim();
              _uploadSummaryModel.filterData();
            },
          );
        },
      ),
    );
  }

  Widget _buildTabChooseTable(BuildContext context, UploadSummaryModel model) {
    final sortedTables = [...model.getFilteredUploadSummaryList]..sort((a, b) => a.tableName.compareTo(b.tableName));

    if (sortedTables.isEmpty) {
      return const EmptyState(
        title: "No tables found",
        subtitle: "Please try again later or contact support",
        icon: Icons.folder_outlined
      );
    }

    return ListView.builder(
      key: const ValueKey<String>('tables'),
      itemCount: sortedTables.length,
      itemBuilder: (context, index) {
        final table = sortedTables[index];
        return _buildTableCard(context, table);
      },
    );
  }

  Widget _buildTableCard(BuildContext context, UploadSummary table) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade500, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Optional: Add tap functionality if needed
          },
          child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              expandedAlignment: Alignment.topLeft,
              title: _buildTableTitle(context, table.simpleText),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    CustomChip(
                      label: "${table.rowCount}",
                      leadingIcon: Icons.table_rows,
                      backgroundColor: Colors.transparent, 
                      border: Border.all(color: Colors.grey.shade500, width: 0.5),
                    ),
                    const SizedBox(width: 8),
                    CustomChip(
                      label: table.componentName,
                      leadingIcon: Icons.grid_view_outlined,
                      backgroundColor: Colors.transparent, 
                      border: Border.all(color: Colors.grey.shade500, width: 0.5),
                    ),
                  ],
                ),
              ),
              trailing: _buildTableCardTrailing(context, table),
              children: _buildTableCardChildren(context, table),
            ),
        ),
      ),
    );
  }

  Widget _buildTableCardTrailing(BuildContext context, UploadSummary table) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final iconSize = context.iconSize(size: IconSize.small);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconButton(
          icon: Icons.assessment_rounded,
          iconSize: iconSize,
          onPressed: () async {
            await _displayDataProfile(table.tableId, table.simpleText);
          },
          tooltip: "Data Profile",
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.cloud_upload_rounded,
          iconSize: iconSize,
          onPressed: () async {
            await _pickFile(table.tableId);
          },
          tooltip: "Upload data for ${table.simpleText}",
          isProcessing: 
            _uploadSummaryModel.getSelectedTableIdsForPickFile.contains(table.tableId) 
            ? true 
            : false,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
        )
      ],
    );
  }

  List<Widget> _buildTableCardChildren(BuildContext context, UploadSummary table) {
    return [
      if (table.uploads.isNotEmpty)
      const Divider(height: 1),
      if (table.uploads.isNotEmpty)
        ...table.uploads.map((file) => _buildFileListItem(context, file, table))
      else
        const EmptyState(
          title: "No files uploaded yet",
          subtitle: "Upload a file to get started",
          icon: Icons.file_upload_outlined,
        ),
    ];
  }

  Widget _buildFileListItem(BuildContext context, FileUpload file, UploadSummary table) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: file.uploadStatus == UploadStatus.completed
        ? const CustomIcon(icon: Icons.done_rounded,size: 16)
        : const CustomIcon(icon: Icons.file_upload_outlined,size: 16),
      title: _buildFileListItemTitle(context, file),
      trailing: _buildFileListItemTrailing(context, file, table),
      dense: true,
    );
  }

  Widget _buildFileListItemTitle(BuildContext context, FileUpload file) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                file.fileName,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing / 2),
              Row(
                children: [
                  Text(
                    "${file.rowCount.toString()} Rows",
                    style: theme.textTheme.bodySmall,
                  ),
                  SizedBox(width: spacing),
                  Text(
                    FileSizeFormatter.formatFileSize(file.fileSizeInBytes),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: spacing * 2.5),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            child: Text(
              file.message,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileUploadStatusIcon(UploadStatus uploadStatus) {
    switch (uploadStatus) {
      case UploadStatus.completed:
        return Icons.task_alt_rounded;
      case UploadStatus.waiting:
        return Icons.view_column_rounded;
      case UploadStatus.failed:
        return Icons.error_rounded;
      case UploadStatus.pending:
        return Icons.pending_actions_rounded;
    }
  }

  Color _getFileUploadStatusColor(UploadStatus uploadStatus) {
    switch (uploadStatus) {
      case UploadStatus.completed:
        return Colors.green;
      case UploadStatus.waiting:
        return Colors.amber;
      case UploadStatus.failed:
        return Colors.red;
      case UploadStatus.pending:
        return Colors.blue;
    }
  }

  String _getFileUploadStatusTooltip(UploadStatus uploadStatus) {
    switch (uploadStatus) {
      case UploadStatus.completed:
        return "File uploaded successfully";
      case UploadStatus.waiting:
        return "Waiting for user to confirm the mapping";
      case UploadStatus.failed:
        return "File upload failed. Please try again.";
      case UploadStatus.pending:
        return "File upload is pending.";
    }
  }

  Widget _buildFileListItemTrailing(BuildContext context, FileUpload file, UploadSummary table) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing(size: SpacingSize.small);
    final smallIconSize = context.iconSize(size: IconSize.small) * 0.7;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconButton(
          icon: _getFileUploadStatusIcon(file.uploadStatus),
          iconSize: smallIconSize,
          onPressed: () {
            _moveToMapping(
              table.tableId,
              file.fileUploadId,
              table.simpleText,
              file.fileName
            );
          },
          tooltip: _getFileUploadStatusTooltip(file.uploadStatus),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: _getFileUploadStatusColor(file.uploadStatus),
          padding: 3,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.delete_rounded,
          iconSize: smallIconSize,
          onPressed: () async {
            await _deleteFile(
              file.filePath,
              file.fileName,
              file.fileUploadId
            );
          },
          tooltip: "Delete file",
          isProcessing: _uploadSummaryModel.getSelectedFileUploadIdsForDeleteFile.contains(file.fileUploadId) 
            ? true
            : false,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          padding: 3,
        ),
        SizedBox(width: spacing),
        CustomIconButton(
          icon: Icons.download_rounded,
          iconSize: smallIconSize,
          onPressed: () async {
            await _downloadFile(file.filePath, file.fileName);
          },
          tooltip: "Download file",
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          padding: 3,
        ),
      ],
    );
  }

  void _moveToMapping(int tableId, int fileUploadId, String tableName, String fileName) {
    try {
      _uploadSummaryModel.activeTableSelectionId = tableId;
      _uploadSummaryModel.activeFileUploadId = fileUploadId;
      _uploadSummaryModel.activeTableSelectionName = tableName;
      _uploadSummaryModel.activeFileUploadSelectionName = fileName;

      _tabController.index = 1;
      _tabController.animateTo(1);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "moveToMapping");
    }
  }

  Future<void> _displayDataProfile(int tableId, String tableName) async {
    _uploadSummaryModel.activeTableSelectionId = tableId;
    //navigate to the data quality assessment page
    context.fadeNavigateTo(DataQualityAssessmentPage(tableName: tableName));
  }

  Future<void> _pickFile(int tableId) async {
    try {
      _uploadSummaryModel.setPickfileLoading = true;
      _uploadSummaryModel.addSelectedTableIdsForPickFile(tableId);

      String uuid = const Uuid().v4().toString().toLowerCase();
      String storagePath = 'public/data/${_projectDetailsModel.getActiveProjectId}/${_projectDetailsModel.getProjectTypeId}/$tableId/$uuid';

      _filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: true,
        readSequential: true,
        withData: true,
      );

      if (_filePickerResult != null) {
        for (var file in _filePickerResult!.files) {
          //check the file size
          if (!FileSizeValidator.isValid(file.size, 250)) {
            SnackbarMessage.showErrorMessage(
              context, 
              "We are working to upgrade the file size limit. You can upload files up to 250MB. ${file.name} is ${FileSizeFormatter.formatFileSize(file.size)}. Please consider splitting the file into smaller chunks.", 
              logError: false);
            continue;
          }

          final tableExists = await _uploadSummaryModel.fetchFileUploadTableExists(context, file.name, tableId);
          
          if (tableExists) {
            SnackbarMessage.showErrorMessage(context, "${file.name} already exists. ", logError: false);
            continue;
          } else {
            
            await S3Service().uploadFile(file, storagePath);
            int fileUploadId = await _uploadSummaryModel.insertFileUpload(
                context,
                storagePath,
                file.name,
                file.extension ?? "",
                file.size,
                0,
                0,
                tableId,
                '',
                file.name,
              );

            if (fileUploadId > 0) {
            //invoke the ecs task similar to confirmation page
            await ECSTaskService().invokeCSVUploadTask(csvUploadPayload: {
                'file_upload_id': fileUploadId,
                'user_id': _userDetailsModel.getUserMachineId,
              });
            }
          }
        }

        await _uploadSummaryModel.fetchFileUploadsByProject(context);
        
        // Start polling if we have pending uploads after file upload
        if (mounted && _uploadSummaryModel.hasPendingUploads()) {
          _startPollingIfNeeded();
        }
      }
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "pickFile");
    } finally{
      _filePickerResult = null;
      _uploadSummaryModel.setPickfileLoading = false;
      _uploadSummaryModel.removeSelectedTableIdsForPickFile(tableId);
    }
  }

  Future<void> _deleteFile(String filePath, String fileName, int fileUploadId) async {
    try {
      // Ensure context is mounted before showing dialog
      if (!mounted) return;
      
      if (!await showConfirmDialog(
          context: context,
          title: "Confirm Delete",
          content: "Are you sure you want to delete this file? This action cannot be undone. You may have to re-run the tests in the risk register to see the changes.")) {
        return;
      }

      _uploadSummaryModel.addSelectedFileUploadIdsForDeleteFile(fileUploadId);

      await _s3Service.deleteFile(path.join(filePath, fileName));
      await _uploadSummaryModel.deleteFileUpload(context, fileUploadId);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "deleteFile");
    } finally {
      _uploadSummaryModel.removeSelectedFileUploadIdsForDeleteFile(fileUploadId);
    }
  }

  Future<void> _downloadFile(String filePath, String fileName) async {
    try {
      await _s3Service.downloadFile(path.join(filePath, fileName));
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "downloadFile");
    }
  }

  Future<void> _loadPage() async {
    try {
      _uploadSummaryModel.setIsPageLoading = true;
      await _uploadSummaryModel.fetchFileUploadsByProject(context);
    } catch (e, errorStackTrace) {
      SnackbarMessage.showErrorMessage(context, e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_loadPage");
    } finally {
      _uploadSummaryModel.setIsPageLoading = false;
    }
  }

  void _startPollingIfNeeded() {
    if (_uploadSummaryModel.hasPendingUploads()) {
      // Start polling every 30 seconds when there are pending uploads
      _pollingController.setPollingInterval(const Duration(seconds: 15));
      _pollingController.startPollingMultiple(context, [
        _refreshPage,
      ]);
    }
  }

  Future<void> _refreshPage(BuildContext context) async {
    if (!mounted) return;
    
    try {
      await _uploadSummaryModel.fetchFileUploadsByProject(context);
      
      // Check if we still have pending uploads after refresh
      if (!_uploadSummaryModel.hasPendingUploads()) {
        // Stop polling if no more pending uploads
        _pollingController.stopPolling();
      }
    } catch (e, errorStackTrace) {
      if (!mounted) return;
      SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          showUserMessage: false,
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: errorStackTrace.toString(),
          errorSource: _currentFileName,
          severityLevel: 'Critical',
          requestPath: "_refreshPage");
    }
  }
}
