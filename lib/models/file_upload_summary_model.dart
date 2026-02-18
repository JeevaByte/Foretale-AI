//models
import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database/handling_crud.dart';
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/enums/upload_status_enum.dart';
import 'package:provider/provider.dart';

class FileUpload {
  int fileUploadId;
  String fileName;
  String filePath;
  int fileSizeInBytes;
  String fileType;
  int rowCount;
  int columnCount;
  UploadStatus uploadStatus;
  String message;
  String csvDetails;
  String columnMappings;
  String chunkName;

  FileUpload({
    this.fileUploadId = 0,
    this.fileName = '',
    this.filePath = '',
    this.fileSizeInBytes = 0,
    this.fileType = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.uploadStatus = UploadStatus.pending,
    this.message = '',
    this.csvDetails = '',
    this.columnMappings = '',
    this.chunkName = '',
  });

  factory FileUpload.fromJson(Map<String, dynamic> map) {

    return FileUpload(
      fileUploadId: map['file_upload_id'] ?? 0,
      fileName: map['file_name'] ?? '',
      filePath: map['file_path'] ?? '',
      fileSizeInBytes: map['file_size_in_bytes'] ?? 0,
      fileType: map['file_type'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
        uploadStatus: UploadStatus.values.firstWhere(
          (e) => e.name == map['upload_status'],
          orElse: () => UploadStatus.pending,
        ),
      message: map['message'] ?? '',
      csvDetails: map['csv_details'] ?? '',
      columnMappings: map['column_mapping'] ?? '',
      chunkName: map['chunk_name'] ?? '',
    );
  }
}

class UploadSummary {
  int tableId;
  String componentName;
  String tableName;
  String simpleText;
  String description;
  int rowCount;
  int columnCount;
  UploadStatus overallUploadStatus;
  List<FileUpload> uploads;

  UploadSummary({
    this.tableId = 0,
    this.componentName = '',
    this.tableName = '',
    this.simpleText = '',
    this.description = '',
    this.rowCount = 0,
    this.columnCount = 0,
    this.overallUploadStatus = UploadStatus.pending,
    this.uploads = const [],
  });

  factory UploadSummary.fromJson(Map<String, dynamic> map) {

    return UploadSummary(
      tableId: map['table_id'] ?? 0,
      componentName: map['component_name'] ?? '',
      tableName: map['table_name'] ?? '',
      simpleText: map['simple_text'] ?? '',
      description: map['description'] ?? '',
      rowCount: map['row_count'] ?? 0,
      columnCount: map['column_count'] ?? 0,
      overallUploadStatus: UploadStatus.values.firstWhere(
        (e) => e.name == map['overall_upload_status'],
        orElse: () => UploadStatus.pending,
      ),
      uploads: map.containsKey('uploads')
          ? List<FileUpload>.from(
              (map['uploads'] as List).map((x) => FileUpload.fromJson(x)))
          : [],
    );
  }

  @override
  String toString() {
    return 'UploadSummary('
           'tableId: $tableId, '
           'componentName: "$componentName", '
           'tableName: "$tableName", '
           'simpleText: "$simpleText", '
           'description: "$description", '
           'rowCount: $rowCount, '
           'columnCount: $columnCount, '
           'overallUploadStatus: "$overallUploadStatus", '
           'uploads: ${uploads.map((u) => u.toString()).toList()})';
  }
}

class UploadSummaryModel with ChangeNotifier{
  final CRUD _crudService = CRUD();
  List<UploadSummary> uploadSummaryList = [];
  List<UploadSummary> get getUploadSummaryList => uploadSummaryList;

  List<UploadSummary> filteredUploadSummaryList = [];
  List<UploadSummary> get getFilteredUploadSummaryList => filteredUploadSummaryList;

  int activeTableSelectionId = 0;
  int get getActiveTableSelectionId => activeTableSelectionId;

  int activeFileUploadId = 0;
  int get getActiveFileUploadId => activeFileUploadId;

  String activeTableSelectionName = '';
  String get getActiveTableSelectionName => activeTableSelectionName;

  String activeFileUploadSelectionName = '';
  String get getActiveFileUploadSelectionName => activeFileUploadSelectionName;

  String searchQuery = '';
  String get getSearchQuery => searchQuery;

  String selectedCategory = 'All';
  String get getSelectedCategory => selectedCategory;
  set setSelectedCategory(String value) {
    selectedCategory = value;
    filterData();
    notifyListeners();
  }

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;
  set setIsPageLoading(bool value) {
    _isPageLoading = value;
    notifyListeners();
  }

  bool _pickfileLoading = false;
  bool get getPickfileLoading => _pickfileLoading;
  set setPickfileLoading(bool value) {
    _pickfileLoading = value;
    notifyListeners();
  }

  bool _deleteFileLoading = false;
  bool get getDeleteFileLoading => _deleteFileLoading;
  set setDeleteFileLoading(bool value) {
    _deleteFileLoading = value;
    notifyListeners();
  }

  final List<int> _selectedTableIdsForPickFile = [];
  List<int> get getSelectedTableIdsForPickFile => _selectedTableIdsForPickFile;
  
  void addSelectedTableIdsForPickFile(int value) {
    _selectedTableIdsForPickFile.add(value);
    notifyListeners();
  }

  void removeSelectedTableIdsForPickFile(int value) {
    _selectedTableIdsForPickFile.remove(value);
    notifyListeners();
  }

  final List<int> _selectedFileUploadIdsForDeleteFile = [];
  List<int> get getSelectedFileUploadIdsForDeleteFile => _selectedFileUploadIdsForDeleteFile;

  void addSelectedFileUploadIdsForDeleteFile(int value) {
    _selectedFileUploadIdsForDeleteFile.add(value);
    notifyListeners();
  }

  void removeSelectedFileUploadIdsForDeleteFile(int value) {
    _selectedFileUploadIdsForDeleteFile.remove(value);
    notifyListeners();
  }

  Future<void> fetchFileUploadsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
    };

    uploadSummaryList = await _crudService.getJsonRecords<UploadSummary>(
      context,
      'dbo.sproc_get_project_upload_details',
      params,
      (json) => UploadSummary.fromJson(json),
    );

    filterData();

    notifyListeners();
  }

  Future<bool> fetchFileUploadTableExists(BuildContext context, String fileName, int tableId) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'file_name': fileName,
      'project_id': projectDetailsModel.getActiveProjectId,
      'table_id': tableId,
    };

    final tableExists = await _crudService.getRecords<bool>(
      context,
      'dbo.sproc_check_file_exists',
      params,
      (json) => json['is_exists'] ?? false,
    );

    return tableExists.first;
  }

  Future<int> insertFileUpload(
      BuildContext context,
      String? s3FilePath,
      String fileName,
      String fileType,
      int fileSize,
      int rowCount,
      int columnCount,
      int tableId,
      String csvDetails,
      String chunkName,
      ) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'file_name': fileName,
      'file_path': s3FilePath,
      'file_type': fileType,
      'file_size_in_bytes': fileSize,
      'row_count': rowCount,
      'column_count': columnCount,
      'upload_status': UploadStatus.pending.name.toString(),
      'message': 'Assessing file structure. This may take a few minutes. Check back later.',
      'created_by': userDetailsModel.getUserMachineId,
      'table_id': tableId,
      'csv_details': csvDetails,
      'chunk_name': chunkName
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_file_upload',
      params,
    );

    return insertedId;
  }

  Future<int> deleteFileUpload(BuildContext context, int fileUploadId) async {
    UserDetailsModel userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    var params = {
      'file_upload_id': fileUploadId,
      'deleted_by': userDetailsModel.getUserMachineId,
    };

    int deletedId = await _crudService.deleteRecord(
      context,
      'dbo.sproc_delete_file_upload',
      params,
    );

    // Remove the file from the list and update UI
    if (deletedId > 0) {
      // Remove the file upload from the uploads list
      for (var summary in uploadSummaryList) {
        summary.uploads.removeWhere((upload) => upload.fileUploadId == fileUploadId);
      }
      
      // Update filtered list and notify listeners
      filterData();
    }

    return deletedId;
  }

  void filterData() {
    String lowerCaseQuery = getSearchQuery.toLowerCase();
    List<UploadSummary> filtered = List.from(uploadSummaryList);

    // Filter by search query
    if (lowerCaseQuery.isNotEmpty) {
      filtered = filtered.where((table) {
        return table.tableName.toLowerCase().contains(lowerCaseQuery) ||
               table.simpleText.toLowerCase().contains(lowerCaseQuery) ||
               table.componentName.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    // Filter by selected category
    if (selectedCategory != 'All') {
      filtered = filtered.where((table) => table.componentName == selectedCategory).toList();
    }

    filteredUploadSummaryList = filtered;
    notifyListeners();
  }

  /// Check if there are any file uploads with pending status
  bool hasPendingUploads() {
    return uploadSummaryList.any((summary) => 
      summary.uploads.any((upload) => upload.uploadStatus == UploadStatus.pending)
    );
  }

  /// Update file upload status using sproc_update_file_upload_status stored procedure
  Future<int> updateFileUploadStatus(
    BuildContext context,
    int fileUploadId,
    String tableName,
    UploadStatus uploadStatus,
    String message,
    String otherUpdatesFlag
  ) async {
    UserDetailsModel userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);

    var params = {
      'file_upload_id': fileUploadId,
      'table_name': tableName,
      'upload_status': uploadStatus.name,
      'message': message,
      'last_updated_by': userDetailsModel.getUserMachineId,
      'update_row_count': otherUpdatesFlag,
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_update_file_upload_status',
      params,
    );

    // Update the local data if the update was successful
    if (updatedId > 0) {
      // Find and update the file upload in the local list
      for (var summary in uploadSummaryList) {
        var uploadIndex = summary.uploads.indexWhere((upload) => upload.fileUploadId == fileUploadId);
        if (uploadIndex != -1) {
          summary.uploads[uploadIndex].uploadStatus = uploadStatus;
          summary.uploads[uploadIndex].message = message;
          break;
        }
      }
      
      // Update filtered list and notify listeners
      filterData();
    }

    return updatedId;
  }
}

