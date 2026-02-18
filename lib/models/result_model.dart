import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foretale_application/config/config_s3.dart';
import 'package:foretale_application/core/services/database/handling_crud.dart';
import 'package:foretale_application/models/abstracts/chat_driving_model.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/tests_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_grid/custom_grid_columns.dart';
import 'package:provider/provider.dart';

enum CustomCellType {
  text,
  number,
  currency,
  percentage,
  date,
  categorical,
  badge,
  checkbox,
  dropdown,
  save
}

class TableColumn{
  final String tableName;
  final String columnName;
  final String columnLabel;
  final String columnDescription;
  final String dataType;
  final String cellType;
  final bool isVisible;
  final bool isFeedbackColumn;
  final List<String> allowedValues;

  TableColumn({
    this.tableName = '',
    this.columnName = '',
    this.columnLabel = '',
    this.columnDescription = '',
    this.dataType = '',
    this.cellType = '',
    this.isVisible = false,
    this.isFeedbackColumn = false,
    this.allowedValues = const [],
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      tableName: json['table_name'] ?? '',
      columnName: json['column_name'] ?? '',
      columnLabel: json['column_alias'] ?? '',
      columnDescription: json['column_description'] ?? '',
      dataType: json['data_type'] ?? '',
      cellType: json['cell_type'] ?? '',
      isVisible: json['is_visible'] ?? false,
      isFeedbackColumn: json['is_feedback_column'] ?? false,
      allowedValues: json['allowable_values'].toString().split(',').map((e) => e.trim()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_name': tableName,
      'column_name': columnName,
      'column_label': columnLabel,
      'column_description': columnDescription,
      'data_type': dataType,
      'cell_type': cellType,
      'is_visible': isVisible,
      'is_feedback_column': isFeedbackColumn,
      'allowable_values': allowedValues,
    };
  }
}

class FeedbackData{
  final int feedbackId;
  final int projectId;
  final int testId;
  final String tableReference;
  final String hashKey;
  final String feedbackStatus;
  final String feedbackCategory;
  final String severityRating;
  final bool isFinal;
  final String lastUpdatedBy;
  final String lastUpdatedOn;
  final bool isSelected;

  FeedbackData({
    this.feedbackId = 0,
    this.projectId = 0,
    this.testId = 0,
    this.tableReference = '',
    this.hashKey = '',
    this.feedbackStatus = '',
    this.feedbackCategory = '',
    this.severityRating = '',
    this.isFinal = false,
    this.lastUpdatedBy = '',
    this.lastUpdatedOn = '',
    this.isSelected = false,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      feedbackId: json['feedback_id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      testId: json['test_id'] ?? 0,
      tableReference: json['table_reference'] ?? '',
      hashKey: json['hash_key']?.toString() ?? '',
      feedbackStatus: json['feedback_status'] ?? '',
      feedbackCategory: json['feedback_category'] ?? '',
      severityRating: json['severity_rating'] ?? '',
      isFinal: json['is_final'] ?? false,
      lastUpdatedBy: json['last_updated_by'] ?? '',
      lastUpdatedOn: json['last_updated_on'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class SavedChartConfig {
  final String name;
  final String metaStructure;

  SavedChartConfig({
    this.name = '',
    this.metaStructure = '',
  });

  factory SavedChartConfig.fromJson(Map<String, dynamic> json) {
    return SavedChartConfig(
      name: json['name'] ?? '',
      metaStructure: json['meta_structure'] ?? '',
    );
  }

  // Helper method to parse the meta structure JSON and get chart config values
  Map<String, String> getParsedConfig() {
    if (metaStructure.isEmpty) {
      return {};
    }
    
    try {
      final parsed = jsonDecode(metaStructure);
      if (parsed is Map<String, dynamic>) {
        return {
          'dimension': parsed['dimension']?.toString() ?? '',
          'fact': parsed['fact']?.toString() ?? '',
          'aggregation': parsed['aggregation']?.toString() ?? '',
          'chartType': parsed['chartType']?.toString() ?? '',
        };
      }
    } catch (e) {
      // If parsing fails, return empty map
    }
    
    return {};
  }
}

class ResultModel with ChangeNotifier implements ChatDrivingModel {
  final CRUD _crudService = CRUD();
  
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredTableData = [];
  List<FeedbackData> feedbackData = [];
  List<TableColumn> tableColumnsList = [];
  List<CustomGridColumn> genericGridColumns = [];
  List<SavedChartConfig> savedChartConfigs = [];
  int selectedFeedbackId = 0;
  
  int totalRows = 0;

  int get getTotalRows => tableData.where(
      (item) {
        if(showSamplesOnly){
          return item['is_selected'] == true;
        } else {
          return true;
        }
      }
    ).toList().length;

  bool isPageLoading = false;
  bool get getIsPageLoading => isPageLoading;
  set setIsPageLoading(bool value) {
    isPageLoading = value;  
    notifyListeners();
  }

  bool showSamplesOnly = false;
  bool get getShowSamplesOnly => showSamplesOnly;
  set setShowSamplesOnly(bool value) {
    showSamplesOnly = value;
    notifyListeners();
  }

  int selectedTestId = 0;
  int get getSelectedTestId => selectedTestId;
  set setSelectedTestId(int value) {
    selectedTestId = value;
    notifyListeners();
  }

  int frozenColumnsCount = 0;
  int get getFrozenColumnsCount => frozenColumnsCount;
  void updateFrozenColumnsCount(int value, int maxColumns) {
    if (value >= 0 && value <= 10 && value <= maxColumns) {
      frozenColumnsCount = value;
      notifyListeners();
    }
  }

  bool isStoryPointSaving = false;
  bool get getIsStoryPointSaving => isStoryPointSaving;
  set setIsStoryPointSaving(bool value) {
    isStoryPointSaving = value;
    notifyListeners();
  }

  Future<bool> saveStoryPointConfig(BuildContext context,String metaStructure, {String name = 'Story Point', String recordStatus = 'A'}) async {
    if (getSelectedTestId == 0 || metaStructure.isEmpty) {
      return false;
    }

    setIsStoryPointSaving = true;

    try {
      var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

      final params = {
        'name': name,
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': getSelectedTestId,
        'meta_structure': metaStructure,
        'record_status': recordStatus,
        'last_updated_by': userDetailsModel.getUserMachineId,
      };

      final insertedId = await _crudService.addRecord(
        context,
        'dbo.sproc_insert_update_test_chart',
        params,
      );

      if(insertedId > 0){
        fetchSavedChartConfigs(context, getSelectedTestId);
      }

      return insertedId > 0;
    } finally {
      setIsStoryPointSaving = false;
    }
  }

  // Analysis selection state
  String? _selectedDimension;
  String? _selectedFact;
  String? _selectedGraph;
  String? _selectedAggregation = "Sum";
  String? _selectedSavedConfigName;
  bool _isSortedAscending = true;

  String? get selectedDimension => _selectedDimension;
  String? get selectedFact => _selectedFact;
  String? get selectedGraph => _selectedGraph;
  String? get selectedAggregation => _selectedAggregation;
  String? get selectedSavedConfigName => _selectedSavedConfigName;
  bool get isSortedAscending => _isSortedAscending;


  Future<void> fetchResultMetadata(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
    };

    tableColumnsList = await _crudService.getRecords<TableColumn>(
      context,
      'dbo.sproc_get_result_metadata',
      params,
      (json) => TableColumn.fromJson(json),
    );

    // Clear existing columns before adding new ones
    genericGridColumns.clear();
    
    for (var element in tableColumnsList) {
      bool allowSorting = true;
      bool allowFiltering = true;

      if(element.cellType == 'dropdown' || element.cellType == 'checkbox'){
        allowSorting = false;
        allowFiltering = false;
      }

      genericGridColumns.add(CustomGridColumn(
        columnName: element.columnName,
        label: (element.columnName == 'is_selected') ? '' : element.columnLabel,
        width: (element.columnName == 'is_selected') ? 40 : null,
        cellType: CustomCellType.values.byName(element.cellType),
        visible: element.isVisible ,
        allowSorting: allowSorting,
        allowFiltering: allowFiltering,
        allowedValues: element.allowedValues,
        isFeedbackColumn: element.isFeedbackColumn,
        checkboxUpdateCallback: {
          'is_final': (hashKey, selectedValue) => updateIsFinal(context, hashKey, selectedValue),
          'is_selected': (hashKey, selectedValue) => insertFlaggedTransaction(context, hashKey, selectedValue),
        },
        dropdownUpdateCallback: {
          'feedback_status': (hashKey, selectedValue) => updateFeedbackStatus(context, hashKey, selectedValue),
          'feedback_category': (hashKey, selectedValue) => updateFeedbackCategory(context, hashKey, selectedValue),
          'severity_rating': (hashKey, selectedValue) => updateSeverityRating(context, hashKey, selectedValue),
        },
      ));
    }
  }

  Future<void> fetchResultData(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': test.testId,
    };

    tableData = await _crudService.getRecords<Map<String, dynamic>>(
      context,
      'dbo.sproc_get_result_data',
      params,
      (json) => json,
    );
  }

  Future<void> fetchSavedChartConfigs(BuildContext context, int testId) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testId,
    };

    savedChartConfigs = await _crudService.getRecords<SavedChartConfig>(
      context,
      'dbo.sproc_get_test_chart',
      params,
      (json) => SavedChartConfig.fromJson(json),
    );

    notifyListeners();
  }

  Future<int> insertFlaggedTransaction(BuildContext context, String hashKey, bool selectedValue) async {

    //update the is_selected column in the table data
    for(var transaction in tableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['is_selected'] = selectedValue;
      }
    }

    //update the is_selected column in the filtered table data
    for(var transaction in filteredTableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['is_selected'] = selectedValue;
      }
    }

    notifyListeners();

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testModel.getSelectedTestId,
      'table_reference': testModel.getSelectedTest.analysisTableName,
      'hash_key': hashKey,
      'last_updated_by': userDetailsModel.getUserMachineId,
      'is_selected': selectedValue,
    };

    await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_feedback',
      params,
    );

    return 1;
  }

  Future<int> updateFeedbackStatus(BuildContext context, String hashKey, String selectedValue) async {
    //update the feedback_status column in the table data
    for(var transaction in tableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['feedback_status'] = selectedValue;
      }
    }

    //update the feedback_status column in the filtered table data
    for(var transaction in filteredTableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['feedback_status'] = selectedValue;
      }
    }

    notifyListeners();

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);
     
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testModel.getSelectedTestId,
      'table_reference': testModel.getSelectedTest.analysisTableName,
      'hash_key': hashKey,
      'feedback_status': selectedValue,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

   await _crudService.updateRecord(
      context,
      'dbo.sproc_update_feedback_status',
      params,
    );
    
    return 1;
  }

  Future<int> updateFeedbackCategory(BuildContext context, String hashKey, String selectedValue) async {
    //update the feedback_category column in the table data
    for(var transaction in tableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['feedback_category'] = selectedValue;
      }
    }

    //update the feedback_category column in the filtered table data
    for(var transaction in filteredTableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['feedback_category'] = selectedValue;
      }
    }

    notifyListeners();

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testModel.getSelectedTestId,
      'table_reference': testModel.getSelectedTest.analysisTableName,
      'hash_key': hashKey,
      'feedback_category': selectedValue,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    await _crudService.updateRecord(
      context,
      'dbo.sproc_update_feedback_category',
      params,
    );

    return 1;
  }

  Future<int> updateSeverityRating(BuildContext context, String hashKey, String selectedValue) async {
    //update the severity_rating column in the table data
    for(var transaction in tableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['severity_rating'] = selectedValue;
      }
    }

    //update the severity_rating column in the filtered table data
    for(var transaction in filteredTableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['severity_rating'] = selectedValue;
      }
    }

    notifyListeners();

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);
    
    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testModel.getSelectedTestId, 
      'table_reference': testModel.getSelectedTest.analysisTableName,
      'hash_key': hashKey,
      'severity_rating': selectedValue,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    await _crudService.updateRecord(
      context,
      'dbo.sproc_update_feedback_severity_rating',
      params,
    );

    return 1;
  }

  Future<int> updateIsFinal(BuildContext context, String hashKey, bool selectedValue) async {
    //update the is_final column in the table data
    for(var transaction in tableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['is_final'] = selectedValue;
      }
    }

    //update the is_selected column in the table data
    for(var transaction in filteredTableData){
      if(transaction['hash_key'].toString() == hashKey){
        transaction['is_final'] = selectedValue;
      }
    }

    notifyListeners();

    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var testModel = Provider.of<TestsModel>(context, listen: false);
    

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'test_id': testModel.getSelectedTestId,
      'table_reference': testModel.getSelectedTest.analysisTableName,
      'hash_key': hashKey,
      'is_final': selectedValue,
      'last_updated_by': userDetailsModel.getUserMachineId,
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_feedback_is_final',
      params,
    );

    return updatedId;
  }

  Future<void> fetchFeedbackData(BuildContext context, Test test) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    final params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': test.testId,
        'table_reference': test.analysisTableName,
    };

    feedbackData = await _crudService.getRecords<FeedbackData>(
      context,
      'dbo.sproc_get_active_feedback',
      params,
      (json) => FeedbackData.fromJson(json),
    );
    
  }

  void mergeFeedbackData() {
    // Create a map for fast lookup: hashKey -> Feedback
    final feedbackMap = {
      for (var feedback in feedbackData) feedback.hashKey: feedback
    };

    for (var transaction in tableData) {
      var hashKey = transaction['hash_key'].toString();
      var feedback = feedbackMap[hashKey];

      if (feedback != null) {
        transaction['is_selected'] = feedback.isSelected;
        transaction['feedback_id'] = feedback.feedbackId;
        transaction['table_reference'] = feedback.tableReference;
        transaction['feedback_status'] = feedback.feedbackStatus;
        transaction['feedback_category'] = feedback.feedbackCategory;
        transaction['severity_rating'] = feedback.severityRating;
        transaction['is_final'] = feedback.isFinal;
        transaction['last_updated_by'] = feedback.lastUpdatedBy;
        transaction['last_updated_on'] = feedback.lastUpdatedOn;
      }
    }

    filteredTableData = tableData;
  }


  Future<void> updateDataGrid(BuildContext context, Test test) async{
    //can happen in parallel
    await Future.wait([
      fetchResultMetadata(context, test),
      fetchResultData(context, test),
      fetchFeedbackData(context, test),
    ]);

    mergeFeedbackData();
    notifyListeners();
  }

  void updateSelectedTransactions(bool showFlaggedTransactions){
    showSamplesOnly = showFlaggedTransactions;

    if(showFlaggedTransactions){
      filteredTableData = tableData.where((item) => item['is_selected'] == true).toList();
    } else {
      filteredTableData = tableData;
    }

    notifyListeners();
  }

  void updateSelectedFeedback(int feedbackId){
    selectedFeedbackId = feedbackId;
    notifyListeners();
  }

  // Analysis selection methods
  void selectDimension(String dimension) {
    if (_selectedDimension == dimension) {
      _selectedDimension = null; // Unselect if already selected
    } else {
      _selectedDimension = dimension;
    }
    notifyListeners();
  }

  void selectFact(String fact) {
    if (_selectedFact == fact) {
      _selectedFact = null; // Unselect if already selected
    } else {
      _selectedFact = fact;
    }
    notifyListeners();
  }

  void selectGraph(String graph) {
    if (_selectedGraph == graph) {
      _selectedGraph = null; // Unselect if already selected
    } else {
      _selectedGraph = graph;
    }
    notifyListeners();
  }

  void selectAggregation(String aggregation) {
    _selectedAggregation = aggregation;
    notifyListeners();
  }

  void selectSavedConfig(String? configName) {
    if (_selectedSavedConfigName == configName) {
      _selectedSavedConfigName = null; // Unselect if already selected
    } else {
      _selectedSavedConfigName = configName;
    }
    notifyListeners();
  }

  void toggleSort() {
    _isSortedAscending = !_isSortedAscending;
    notifyListeners();
  }

  void clearAnalysisSelections() {
    _selectedDimension = null;
    _selectedFact = null;
    _selectedGraph = null;
    _selectedAggregation = "Sum"; // Keep default aggregation
    _selectedSavedConfigName = null;
    notifyListeners();
  }

  @override
  int getActiveProjectId(BuildContext context) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return projectDetailsModel.getActiveProjectId;
  }

  @override
  int get selectedId => selectedFeedbackId;

  @override
  int getSelectedId(BuildContext context) => selectedFeedbackId;

  @override
  Future<int> insertResponse(BuildContext context, String responseText) async {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    return inquiryResponseModel.insertResponseByReference(
      context,
      selectedFeedbackId,
      getDrivingModelName(context),
      responseText,
      feedbackData.first.testId,
    );
  }

  @override
  Future<void> fetchResponses(BuildContext context) async {
    var inquiryResponseModel = Provider.of<InquiryResponseModel>(context, listen: false);
    await inquiryResponseModel.fetchResponsesByReference(
      context,
      selectedFeedbackId,
      getDrivingModelName(context),
    );
  }

  @override
  String getStoragePath(BuildContext context, int responseId) {
    final projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    return buildStoragePath(projectId: projectDetailsModel.getActiveProjectId.toString(), responseId: responseId.toString());
  }

  @override
  String buildStoragePath({required String projectId, required String responseId}) {
    return '${S3Config.baseResponseFeedbackAttachmentPath}$projectId/$selectedId/$responseId';
  }

  @override
  String getDrivingModelName(BuildContext context) => 'feedback';

  String _mode = 'chat';

  @override
  String get mode => _mode;

  @override
  set mode(String value) {
    _mode = value;
    notifyListeners();
  }

  @override
  bool get isAgentMode => _mode == 'agent';

  @override
  bool get enableAgentMode => false;
}
