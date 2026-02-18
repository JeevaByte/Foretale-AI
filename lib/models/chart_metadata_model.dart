import 'package:foretale_application/models/enums/chart_enums.dart';


class ChartMetadata {
  final DataType dataType;
  final int maxLength; // Maximum number of characters in dimension strings
  final int dataPoints; // Number of data points
  final double? minValue;
  final double? maxValue;
  final int uniqueValues;
  final bool hasNullValues;
  final bool isTimeSeries;
  final String? unit;

  const ChartMetadata({
    required this.dataType,
    required this.maxLength,
    required this.dataPoints,
    this.minValue,
    this.maxValue,
    required this.uniqueValues,
    this.hasNullValues = false,
    this.isTimeSeries = false,
    this.unit,
  });

  // Helper methods for chart selection
  bool get isPercentageData {
    if (minValue == null || maxValue == null) return false;
    return minValue! >= 0 && maxValue! <= 100;
  }

  bool get hasNegativeValues {
    if (minValue == null) return false;
    return minValue! < 0;
  }

  bool get isSmallDataset => dataPoints <= 5;
  bool get isMediumDataset => dataPoints > 5 && dataPoints <= 10;
  bool get isLargeDataset => dataPoints > 10;

  bool get isHighCardinality => uniqueValues > dataPoints * 0.8;
  bool get isLowCardinality => uniqueValues <= 3;
  
  // Helper methods for label length considerations
  bool get hasLongLabels => maxLength > 15;
  bool get hasShortLabels => maxLength <= 8;

  double get valueRange {
    if (minValue == null || maxValue == null) return 0;
    return maxValue! - minValue!;
  }

  bool get isNarrowRange {
    return valueRange < 10;
  }

  bool get isWideRange {
    return valueRange > 1000;
  }
}
