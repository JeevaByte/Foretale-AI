//core
import 'package:flutter/material.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';

class ProjectType {
  final int id;
  final String name;
  final String abbreviation;
  final String longName;

  ProjectType({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.longName,
  });

  factory ProjectType.fromJson(Map<String, dynamic> json) {
    return ProjectType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      longName: json['long_name'] ?? '',
    );
  }
}

class ProjectTypeList {
  final CRUD _crudService = CRUD();
  List<ProjectType> projectTypeList = [];
  
  Future<List<ProjectType>> fetchAllActiveProjectTypes(BuildContext context, String selectedIndustry) async {

    if(selectedIndustry.isNotEmpty){
      var params = {
        'industry': selectedIndustry
      };

      projectTypeList = await _crudService.getRecords<ProjectType>(
        context,
        'dbo.sproc_get_topics',
        params,
        (json) => ProjectType.fromJson(json),
      );
    }

    return projectTypeList;
  }
}

