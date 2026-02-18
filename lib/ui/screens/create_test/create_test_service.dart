import 'package:flutter/material.dart';
import 'package:foretale_application/models/create_test_model.dart';

class CreateTestService {
  /// Validates required form fields
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static Future<int> handleSaveTest(BuildContext context, CreateTestModel createTestModel) async {
    int testId = await createTestModel.saveTest(context);
    return testId;
  }
}
