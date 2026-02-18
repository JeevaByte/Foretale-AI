import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExcelExportUtil {
  static Future<void> exportGridToExcel(
    BuildContext? context, {
    required List<Map<String, dynamic>> columns,
    required List<Map<String, dynamic>> data,
    required String fileName,
    String sheetName = 'Sheet1',
    bool includeFormatting = true,
  }) async {
    try {
      if (data.isEmpty) {
        throw Exception('No data to export');
      }

      var excel = Excel.createExcel();
      Sheet sheetObject = excel[sheetName];
      
      // Create formatting styles if formatting is enabled
      CellStyle? headerStyle;
      CellStyle? dataStyle;
      
      if (includeFormatting) {
        // Header style - bold, background color, centered
        headerStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue50,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
        
        // Data style - basic formatting
        dataStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Left,
          verticalAlign: VerticalAlign.Center,
        );
      }
      
      // Add headers with formatting
      for (int i = 0; i < columns.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(columns[i]['label'] ?? columns[i]['columnName'] ?? '');
        if (includeFormatting && headerStyle != null) {
          cell.cellStyle = headerStyle;
        }
      }
      
      // Add data rows with formatting
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        for (int colIndex = 0; colIndex < columns.length; colIndex++) {
          final columnName = columns[colIndex]['columnName'] ?? '';
          final value = data[rowIndex][columnName]?.toString() ?? '';
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1));
          cell.value = TextCellValue(value);
          if (includeFormatting && dataStyle != null) {
            cell.cellStyle = dataStyle;
          }
        }
      }
      
      // Auto-fit column widths if formatting is enabled
      if (includeFormatting) {
        for (int i = 0; i < columns.length; i++) {
          sheetObject.setColumnWidth(i, 15); // Set reasonable default width
        }
      }
      
      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        await FilePicker.platform.saveFile(
          fileName: '$fileName.xlsx',
          bytes: Uint8List.fromList(fileBytes),
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }

}
