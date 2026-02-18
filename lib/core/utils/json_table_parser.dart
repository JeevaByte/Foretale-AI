import 'dart:convert';

/// Generic utility for parsing JSON data into table format
class JsonTableParser {
  /// Parses JSON string into table data format
  static List<Map<String, dynamic>> parseJsonToTableData(String jsonString) {
    if (jsonString.isEmpty) {
      return [];
    }

    try {
      final dynamic jsonData = jsonDecode(jsonString);
      List<Map<String, dynamic>> tableData = [];
      
      if (jsonData is List) {
        // Array format
        tableData = jsonData.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            return {'value': item.toString()};
          }
        }).toList();
      } else if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          // Data wrapped in an object
          final dataList = jsonData['data'] as List;
          tableData = dataList.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              return {'value': item.toString()};
            }
          }).toList();
        } else if (jsonData.containsKey('data') && jsonData['data'] is Map) {
          // Single object wrapped in data
          tableData = [jsonData['data'] as Map<String, dynamic>];
        } else {
          // Root object is the data itself
          tableData = [jsonData];
        }
      }

      return tableData;
    } catch (e) {
      return [];
    }
  }
}
