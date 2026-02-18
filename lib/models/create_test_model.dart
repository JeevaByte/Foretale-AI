//core
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foretale_application/models/topic_list_model.dart';
import 'package:foretale_application/models/category_list_model.dart';
import 'package:foretale_application/models/modules_list_model.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';


class BusinessRisk {
  int riskId;
  String riskCategory;
  String riskStatement;
  String description;

  BusinessRisk({
    this.riskId = 0,
    this.riskCategory = '',
    this.riskStatement = '',
    this.description = '',
  });

  factory BusinessRisk.fromJson(Map<String, dynamic> map) {
    return BusinessRisk(
      riskId: map['risk_id'] ?? 0,
      riskCategory: map['risk_category'] ?? '',
      riskStatement: map['risk_statement'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'risk_id': riskId,
      'risk_category': riskCategory,
      'risk_statement': riskStatement,
      'description': description,
    };
  }
}

class BusinessAction {
  int actionId;
  String actionCategory;
  String businessAction;
  String description;

  BusinessAction({
    this.actionId = 0,
    this.actionCategory = '',
    this.businessAction = '',
    this.description = '',
  });

  factory BusinessAction.fromJson(Map<String, dynamic> map) {
    return BusinessAction(
      actionId: map['action_id'] ?? 0,
      actionCategory: map['action_category'] ?? '',
      businessAction: map['business_action'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_id': actionId,
      'action_category': actionCategory,
      'business_action': businessAction,
      'description': description,
    };
  }
}

class CreateTest {
  int testId;
  String testName;
  String testDescription;
  String technicalDescription;
  String potentialImpact;
  String industry;
  String projectType;
  String topic;
  String? runType;
  String? criticality;
  String? category;
  String? module;
  String? runProgram;
  String chosenMetricType;
  String impactSummary;
  Map<String, dynamic> metricDetails;
  String createdBy;
  String createdDate;
  String lastUpdatedBy;
  String lastUpdatedDate;
  List<BusinessRisk> businessRisks;
  List<BusinessAction> businessActions;

  CreateTest({
    this.testId = 0,
    this.testName = '',
    this.testDescription = '',
    this.technicalDescription = '',
    this.potentialImpact = '',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.runType,
    this.criticality,
    this.category,
    this.module,
    this.runProgram,
    this.chosenMetricType = '',
    this.impactSummary = '',
    this.metricDetails = const {},
    this.createdBy = '',
    this.createdDate = '',
    this.lastUpdatedBy = '',
    this.lastUpdatedDate = '',
    this.businessRisks = const [],
    this.businessActions = const [],
  });

  factory CreateTest.fromJson(Map<String, dynamic> map) {
    return CreateTest(
      testId: map['test_id'] ?? 0,
      testName: map['test_name'] ?? '',
      testDescription: map['test_description'] ?? '',
      technicalDescription: map['technical_description'] ?? '',
      potentialImpact: map['potential_impact'] ?? '',
      industry: map['industry'] ?? '',
      projectType: map['project_type'] ?? '',
      topic: map['topic'] ?? '',
      runType: map['run_type'],
      criticality: map['criticality'],
      category: map['category'],
      module: map['module'],
      runProgram: map['run_program'],
      chosenMetricType: map['chosen_metric_type'] ?? '',
      impactSummary: map['impact_summary'] ?? '',
      metricDetails: map['metric_details'] ?? {},
      createdBy: map['created_by'] ?? '',
      createdDate: map['created_date'] ?? '',
      lastUpdatedBy: map['last_updated_by'] ?? '',
      lastUpdatedDate: map['last_updated_date'] ?? '',
      businessRisks: map.containsKey('business_risks')
          ? List<BusinessRisk>.from((map['business_risks'] as List)
              .map((x) => BusinessRisk.fromJson(x)))
          : [],
      businessActions: map.containsKey('business_actions')
          ? List<BusinessAction>.from((map['business_actions'] as List)
              .map((x) => BusinessAction.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'test_name': testName,
      'test_description': testDescription,
      'technical_description': technicalDescription,
      'potential_impact': potentialImpact,
      'industry': industry,
      'project_type': projectType,
      'topic': topic,
      'run_type': runType,
      'criticality': criticality,
      'category': category,
      'module': module,
      'run_program': runProgram,
      'chosen_metric_type': chosenMetricType,
      'impact_summary': impactSummary,
      'metric_details': metricDetails,
      'created_by': createdBy,
      'created_date': createdDate,
      'last_updated_by': lastUpdatedBy,
      'last_updated_date': lastUpdatedDate,
      'business_risks': businessRisks.map((risk) => risk.toJson()).toList(),
      'business_actions': businessActions.map((action) => action.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CreateTest(testId: $testId, testName: $testName, testDescription: $testDescription, technicalDescription: $technicalDescription, potentialImpact: $potentialImpact, industry: $industry, projectType: $projectType, topic: $topic, runType: $runType, criticality: $criticality, category: $category, module: $module, runProgram: $runProgram, chosenMetricType: $chosenMetricType, impactSummary: $impactSummary, createdBy: $createdBy, createdDate: $createdDate, lastUpdatedBy: $lastUpdatedBy, lastUpdatedDate: $lastUpdatedDate, businessRisks: $businessRisks, businessActions: $businessActions)';
  }
}

class CreateTestModel with ChangeNotifier {
  final CRUD _crudService = CRUD();

  CreateTest _currentTest = CreateTest();
  CreateTest get currentTest => _currentTest;
  void setCurrentTest(CreateTest value) {
    _currentTest = value;
    notifyListeners();
  }

  // Getters for current test
  int get getTestId => _currentTest.testId;
  String get getTestName => _currentTest.testName;
  String get getTestDescription => _currentTest.testDescription;
  String get getTechnicalDescription => _currentTest.technicalDescription;
  String get getPotentialImpact => _currentTest.potentialImpact;
  String get getIndustry => _currentTest.industry;
  String get getProjectType => _currentTest.projectType;
  String get getTopic => _currentTest.topic;
  String? get getRunType => _currentTest.runType;
  String? get getCriticality => _currentTest.criticality;
  String? get getCategory => _currentTest.category;
  String? get getModule => _currentTest.module;
  String? get getRunProgram => _currentTest.runProgram;
  String get getChosenMetricType => _currentTest.chosenMetricType;
  String get getImpactSummary => _currentTest.impactSummary;
  Map<String, dynamic> get getMetricDetails => _currentTest.metricDetails;
  String get getCreatedBy => _currentTest.createdBy;
  String get getCreatedDate => _currentTest.createdDate;
  String get getLastUpdatedBy => _currentTest.lastUpdatedBy;
  String get getLastUpdatedDate => _currentTest.lastUpdatedDate;
  List<BusinessRisk> get getBusinessRisks => _currentTest.businessRisks;
  List<BusinessAction> get getBusinessActions => _currentTest.businessActions;

  int _selectedTestId = 0;
  int get getSelectedTestId => _selectedTestId;
  int get getActiveTestId => _selectedTestId;

  // Loading States
  bool _isLoading = false;
  bool get getIsLoading => _isLoading;
  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isAiMagicProcessing = false;
  bool get getIsAiMagicProcessing => _isAiMagicProcessing;
  set setIsAiMagicProcessing(bool value) {
    _isAiMagicProcessing = value;
    notifyListeners();
  }

  List<Topic> _topicList = [];
  List<Topic> get getTopicList => _topicList;
  set setTopicList(List<Topic> value) {
    _topicList = value;
    notifyListeners();
  }

  List<String> _categoriesList = [];
  List<String> get getCategoriesList => _categoriesList;
  void setCategoriesList(List<String> value) {
    _categoriesList = value;
    notifyListeners();
  }

  List<String> _modulesList = [];
  List<String> get getModulesList => _modulesList;
  void setModulesList(List<String> value) {
    _modulesList = value;
    notifyListeners();
  }

  bool _isSaveHappening = false;
  bool get getIsSaveHappening => _isSaveHappening;
  set setIsSaveHappening(bool value) {
    _isSaveHappening = value;
    notifyListeners();
  }

  // Setters for current test
  void setTestName(String value, {bool notify = true}) {
    _currentTest.testName = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setTestDescription(String value, {bool notify = true}) {
    _currentTest.testDescription = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setTechnicalDescription(String value, {bool notify = true}) {
    _currentTest.technicalDescription = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setPotentialImpact(String value, {bool notify = true}) {
    _currentTest.potentialImpact = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setIndustry(String value) {
    _currentTest.industry = value;
    notifyListeners();
  }

  void setProjectType(String value) {
    _currentTest.projectType = value;
    notifyListeners();
  }

  void setTopic(String value) {
    _currentTest.topic = value;
    notifyListeners();
  }

  void setRunType(String? value) {
    _currentTest.runType = value;
    notifyListeners();
  }

  void setCriticality(String? value) {
    _currentTest.criticality = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _currentTest.category = value;
    notifyListeners();
  }

  void setModule(String? value) {
    _currentTest.module = value;
    notifyListeners();
  }

  void setRunProgram(String? value) {
    _currentTest.runProgram = value;
    notifyListeners();
  }

  void setChosenMetricType(String value) {
    _currentTest.chosenMetricType = value;
    notifyListeners();
  }

  void setImpactSummary(String value) {
    _currentTest.impactSummary = value;
    notifyListeners();
  }

  void setMetricDetails(Map<String, dynamic> value) {
    _currentTest.metricDetails = value;
    notifyListeners();
  }

  // Selection Management
  void updateSelectedTestId(int testId) {
    _selectedTestId = testId;
    notifyListeners();
  }

  void clearAllState() {
    _currentTest = CreateTest();
    _selectedTestId = 0;
    _isLoading = false;
    _isAiMagicProcessing = false;
    _categoriesList = [];
    _modulesList = [];
    _isSaveHappening = false;
  }

  /// **********Business Risks Management***********
  void addBusinessRisk(String description, {String category = '', String severityLevel = 'Medium'}) {
    Future.delayed(const Duration(milliseconds: 10), () {
      final newRisk = BusinessRisk(
        riskId: Random().nextInt(1000000) + Random().nextInt(1000000), //generate a random integer
        riskCategory: category,
        riskStatement: description.trim(),
        description: description.trim(),
      );
      _currentTest.businessRisks = List.from(_currentTest.businessRisks)..add(newRisk);
      notifyListeners();
    });
  }

  void removeBusinessRisk(int riskId) {
    _currentTest.businessRisks = _currentTest.businessRisks.where((risk) => risk.riskId != riskId).toList();
    notifyListeners();
  }

  void clearBusinessRisks() {
    _currentTest.businessRisks = [];
    notifyListeners();
  }

  /// **********Business Actions Management***********
  void addBusinessAction(String description, {String category = '', String priorityLevel = 'Medium'}) {
    Future.delayed(const Duration(milliseconds: 10), () {
      final newAction = BusinessAction(
        actionId: DateTime.now().millisecondsSinceEpoch,
        actionCategory: category,
        businessAction: description.trim(),
        description: description.trim(),
      );
      _currentTest.businessActions = List.from(_currentTest.businessActions)..add(newAction);
      notifyListeners();
    });
    
  }

  void removeBusinessAction(int actionId) {
    _currentTest.businessActions = _currentTest.businessActions.where((action) => action.actionId != actionId).toList();
    notifyListeners();
  }

  void clearBusinessActions() {
    _currentTest.businessActions = [];
    notifyListeners();
  }


  void clearModulesList() {
    _modulesList = [];
    _currentTest.module = '';
    notifyListeners();
  }

  // Data Fetching Methods
  Future<void> fetchCategories(BuildContext context) async {
    if (_categoriesList.isNotEmpty) return;
    final categoryList = CategoryList();
    await categoryList.fetchAllActiveCategories(context);
    setCategoriesList(categoryList.categoryList.map((category) => category.name).toList());
  }

  Future<void> fetchModules(BuildContext context, String selectedCategory) async {
    if (selectedCategory.isEmpty) {
      clearModulesList();
      return;
    }
    final moduleList = ModuleList();
    await moduleList.fetchAllActiveModules(context, selectedCategory);
    setModulesList(moduleList.moduleList.map((module) => module.name).toList());
  }

  // CRUD Operations
  Future<int> saveTest(BuildContext context) async {     
      var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
      var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
      
      // Convert business risks to JSON string for TVP
      String risksJson = jsonEncode(_currentTest.businessRisks.map((risk) => {
        'risk_category': risk.riskCategory,
        'risk_statement': risk.riskStatement,
        'description': risk.description,
      }).toList());
      
      // Convert business actions to JSON string for TVP
      String actionsJson = jsonEncode(_currentTest.businessActions.map((action) => {
        'action_category': action.actionCategory,
        'business_action': action.businessAction,
        'description': action.description,
      }).toList());

      Map<String, dynamic> params = {
        'project_id': projectDetailsModel.getActiveProjectId,
        'test_id': _currentTest.testId,
        'test_name': _currentTest.testName,
        'test_description': _currentTest.testDescription,
        'technical_description': _currentTest.technicalDescription,
        'potential_impact': _currentTest.potentialImpact,
        'industry': _currentTest.industry,
        'project_type': _currentTest.projectType,
        'topic': _currentTest.topic,
        'run_type': _currentTest.runType,
        'criticality': _currentTest.criticality,
        'category': _currentTest.category,
        'module': _currentTest.module,
        'run_program': _currentTest.runProgram,
        'chosen_metric_type': _currentTest.chosenMetricType,
        'created_by': userDetailsModel.getUserMachineId,
        'business_risks': risksJson,
        'business_actions': actionsJson,
      };

      int insertedId = await _crudService.addRecord(
        context,
        'dbo.sproc_insert_test',
        params,
      );

      if (insertedId > 0) {
        _currentTest.testId = insertedId;
        notifyListeners();
      }

      return insertedId;
  }
}