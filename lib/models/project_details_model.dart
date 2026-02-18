//core
import 'package:flutter/material.dart';
import 'package:foretale_application/models/project_type_list_model.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/user_details_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';

class ProjectDetails {
  String name;
  String description;
  int organizationId;
  String organization;
  String recordStatus;
  String createdBy;
  int activeProjectId;
  String projectType;
  int projectTypeId;
  String createdDate;
  String createdByName;
  String createdByEmail;
  String industry;
  int industryId;
  String systemName;
  String projectScopeStartDate;
  String projectScopeEndDate;
  int daysIntoProject;

  // Constructor with default values
  ProjectDetails(
      {this.name = '',
      this.description = '',
      this.organizationId = 0,
      this.organization = '',
      this.recordStatus = 'A',
      this.createdBy = '',
      this.activeProjectId = 0,
      this.projectType = '',
      this.projectTypeId = 0,
      this.createdDate = '',
      this.createdByName = '',
      this.createdByEmail = '',
      this.industry = '',
      this.industryId = 0,
      this.systemName = '',
      this.projectScopeStartDate = '',
      this.projectScopeEndDate = '',
      this.daysIntoProject = 0
      });

  // Factory method to create an instance from a JSON map
  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        organizationId: json['organization_id'] ?? 0,
        organization: json['organization_name'] ?? '',
        recordStatus: json['record_status'] ?? 'A',
        createdBy: json['created_by'] ?? '',
        activeProjectId: json['project_id'] ?? 0,
        projectType: json['project_type'] ?? '',
        projectTypeId: json['project_type_id'] ?? 0,
        createdDate: json['created_date'] ?? '',
        createdByName: json['user_name'] ?? '',
        createdByEmail: json['user_email'] ?? '',
        industry: json['industry'] ?? '',
        industryId: json['industry_id'] ?? 0,
        systemName: json['system_name'] ?? '',
        projectScopeStartDate: json['project_scope_start_date'] ?? '',
        projectScopeEndDate: json['project_scope_end_date'] ?? '',
        daysIntoProject: json['days_elapsed'] ?? 0,
      );
  }

  @override
  String toString() {
    return 'ProjectDetails(name: $name, description: $description, organization: $organization, recordStatus: $recordStatus, createdBy: $createdBy, activeProjectId: $activeProjectId, projectType: $projectType, projectTypeId: $projectTypeId, createdDate: $createdDate, createdByName: $createdByName, createdByEmail: $createdByEmail, industry: $industry, industryId: $industryId, systemName: $systemName, projectScopeStartDate: $projectScopeStartDate, projectScopeEndDate: $projectScopeEndDate, daysIntoProject: $daysIntoProject)';
  }
}

class ProjectDetailsModel with ChangeNotifier {
  final CRUD _crudService = CRUD();

  ProjectDetails _projectDetails = ProjectDetails();
  ProjectDetails get projectDetails => _projectDetails;
  void setProjectDetails(ProjectDetails value) {
    _projectDetails = value;
    notifyListeners();
  }

  List<ProjectDetails> projectListByUser = [];

  bool get getHasProject => (_projectDetails.activeProjectId > 0) ? true : false;
  String get getName => _projectDetails.name;
  String get getDescription => _projectDetails.description;
  String get getOrganization => _projectDetails.organization;
  String get getRecordStatus => _projectDetails.recordStatus;
  String get getCreatedBy => _projectDetails.createdBy;
  int get getActiveProjectId => _projectDetails.activeProjectId;
  String get getProjectType => _projectDetails.projectType;
  int get getProjectTypeId => _projectDetails.projectTypeId;
  String get getCreatedByName => _projectDetails.createdByName;
  String get getCreatedByEmail => _projectDetails.createdByEmail;
  String get getIndustry => _projectDetails.industry;
  int get getIndustryId => _projectDetails.industryId;
  String get getSystemName => _projectDetails.systemName;
  String get getProjectScopeStartDate => _projectDetails.projectScopeStartDate;
  String get getProjectScopeEndDate => _projectDetails.projectScopeEndDate;
  String get getProjectStartDate => _projectDetails.createdDate;
  int get getDaysIntoProject => _projectDetails.daysIntoProject;

  List<ProjectDetails> filteredProjectsList = [];
  List<ProjectDetails> get getFilteredProjectsList => filteredProjectsList;

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;
  set setIsPageLoading(bool value) {
    _isPageLoading = value;
    notifyListeners();
  }

  bool _isLoadingProjectTypes = false;
  bool get getIsLoadingProjectTypes => _isLoadingProjectTypes;
  set setIsLoadingProjectTypes(bool value) {
    _isLoadingProjectTypes = value;
    notifyListeners();
  }

  bool _isSaveHappening = false;
  bool get getIsSaveHappening => _isSaveHappening;
  set setIsSaveHappening(bool value) {
    _isSaveHappening = value;
    notifyListeners();
  }

  List<String> _organizationsList = [];
  List<String> get getOrganizationsList => _organizationsList;
  void setOrganizationsList(List<String> value) {
    _organizationsList = value;
    notifyListeners();
  }

  List<String> _industriesList = [];
  List<String> get getIndustriesList => _industriesList;
  void setIndustriesList(List<String> value) {
    _industriesList = value;
    notifyListeners();
  }

  List<ProjectType> _projectTypesList = [];
  List<ProjectType> get getProjectTypesList => _projectTypesList;
  void setProjectTypesList(List<ProjectType> value) {
    _projectTypesList = value;
    notifyListeners();
  }

  String? get getSelectedProjectType => _projectDetails.projectType;
  void setSelectedProjectType(String? value) {
    _projectDetails.projectType = value ?? '';
    notifyListeners();
  }

  String? get getSelectedOrganization => _projectDetails.organization;
  void setSelectedOrganization(String? value) {
    _projectDetails.organization = value ?? '';
    notifyListeners();
  }

  String? get getSelectedIndustry => _projectDetails.industry;
  void setSelectedIndustry(String? value) {
    _projectDetails.industry = value ?? '';
    notifyListeners();
  }

  String? get getSelectedSystemName => _projectDetails.systemName;
  void setSelectedSystemName(String? value) {
    _projectDetails.systemName = value ?? '';
    notifyListeners();
  }

  void clearProjectTypesList() {
    _projectTypesList = [];
    _projectDetails.projectType = '';
    notifyListeners();
  }

  Future<void> updateProjectDetails(BuildContext context, ProjectDetails projDetails) async {
    _projectDetails = projDetails;
    notifyListeners();
  }

  Future<int> saveProjectDetails(BuildContext context, ProjectDetails projectDetails) async {
    var params = {
      'name': projectDetails.name,
      'description': projectDetails.description,
      'organization_name': projectDetails.organization,
      'record_status': projectDetails.recordStatus,
      'created_by': projectDetails.createdBy,
      'selected_project_id': projectDetails.activeProjectId,
      'project_type': projectDetails.projectType,
      'user_name': projectDetails.createdByName,
      'user_email': projectDetails.createdByEmail,
      'industry': projectDetails.industry,
      'system_name': projectDetails.systemName,
      'project_scope_start_date': projectDetails.projectScopeStartDate,
      'project_scope_end_date': projectDetails.projectScopeEndDate
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_update_project',
      params,
    );

    return insertedId;
  }

  Future<void> fetchProjectDetailsById(BuildContext context, int projectId) async {
    final params = {'project_id': projectId};
    var projectsList = await _crudService.getRecords<ProjectDetails>(
      context,
      'dbo.sproc_get_project_by_id',
      params,
      (json) => ProjectDetails.fromJson(json),
    );

    setProjectDetails(projectsList.firstOrNull ?? ProjectDetails()); //has notifylistener
  }

  Future<void> fetchProjectsByUserMachineId(BuildContext context) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    final params = {'user_machine_id': userDetailsModel.getUserMachineId};

    projectListByUser = await _crudService.getRecords<ProjectDetails>(
      context,
      'dbo.sproc_get_projects_by_user_machine_id',
      params,
      (json) => ProjectDetails.fromJson(json),
    );

    filteredProjectsList = projectListByUser;

    notifyListeners();
  }

  void filterData(String query) {
    String lowerCaseQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredProjectsList = List.from(projectListByUser);
    } else {
      filteredProjectsList = filteredProjectsList.where((project) {
        return project.name.toLowerCase().contains(lowerCaseQuery) ||
            project.description.toLowerCase().contains(lowerCaseQuery) ||
            project.projectType.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    notifyListeners();
  }

  void clearAllState(){
    _projectDetails = ProjectDetails();
    _isPageLoading = false;
    _isLoadingProjectTypes = false;
    _organizationsList = [];
    _industriesList = [];
    _projectTypesList = [];
  }
}
