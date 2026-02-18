import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/screens/report/report_matrix_service.dart';
import 'package:provider/provider.dart';

class ReportRecommendationsTab extends StatefulWidget {
  const ReportRecommendationsTab({super.key});

  @override
  State<ReportRecommendationsTab> createState() => _ReportRecommendationsTabState();
}

class _ReportRecommendationsTabState extends State<ReportRecommendationsTab> {
  late ExecutionStatsModel _executionStatsModel;
  String _selectedBroadCategory = 'All';
  String _selectedCategory = 'All';
  String _selectedRecommendation = 'All';
  String _selectedTest = 'All';
  final Map<String, bool> _expandedCells = {};

  @override
  void initState() {
    super.initState();
    _executionStatsModel = Provider.of<ExecutionStatsModel>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExecutionStatsModel>(
      builder: (context, model, child) {
        if (model.getIsPageLoading) {
          return buildLoadingState(context);
        }
        
        return Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildStickyHeader(model.riskRecommendationList),
              Expanded(
                child: _buildScrollableContent(model.riskRecommendationList),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(List<RiskRecommendation> riskRecommendationList) {
    if (riskRecommendationList.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFourColumnFilters(riskRecommendationList),
          const SizedBox(height: 12),
          ReportService.buildTableHeader(context, "Recommendation"),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(List<RiskRecommendation> riskRecommendationList) {
    if (riskRecommendationList.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'No Recommendations',
          subtitle: 'No recommendations found for this project.',
          icon: Icons.lightbulb_outline,
        ),
      );
    }

    final filteredRecommendations = _getFilteredRecommendations(riskRecommendationList);
    final groupedRecommendations = _groupRecommendationsByCategory(filteredRecommendations);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ...groupedRecommendations.entries.map((entry) => 
            _buildRecommendationRow(context, entry.key, entry.value, riskRecommendationList)
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<RiskRecommendation> _getFilteredRecommendations(List<RiskRecommendation> riskRecommendationList) {
    return riskRecommendationList.where((recommendation) {
      bool matchesBroadCategory = _selectedBroadCategory == 'All' || recommendation.broadCategory == _selectedBroadCategory;
      bool matchesCategory = _selectedCategory == 'All' || recommendation.category == _selectedCategory;
      bool matchesRecommendation = _selectedRecommendation == 'All' || recommendation.recommendation == _selectedRecommendation;
      bool matchesTest = _selectedTest == 'All' || recommendation.testName == _selectedTest;
      
      return matchesBroadCategory && matchesCategory && matchesRecommendation && matchesTest;
    }).toList();
  }

  Map<String, List<RiskRecommendation>> _groupRecommendationsByCategory(List<RiskRecommendation> recommendations) {
    final Map<String, List<RiskRecommendation>> grouped = {};
    for (final recommendation in recommendations) {
      grouped.putIfAbsent(recommendation.recommendation, () => []).add(recommendation);
    }
    return grouped;
  }


  Widget _buildRecommendationCellContent(BuildContext context, RiskRecommendation firstRecommendation, String recommendationName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(12);
    final categoryFontSize = context.responsiveFontSize(9);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recommendationName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              firstRecommendation.broadCategory,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: categoryFontSize,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              " | ",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: categoryFontSize,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              firstRecommendation.category,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: categoryFontSize,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationRow(
    BuildContext context,
    String recommendationName,
    List<RiskRecommendation> recommendations,
    List<RiskRecommendation> allRecommendations,
  ) {
    final criticalityCounts = _getCriticalityCounts(recommendations);
    final firstRecommendation = recommendations.first;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecommendationCellContent(context, firstRecommendation, recommendationName),
                  ],
                ),
              ),
              Expanded(
                child: _buildCriticalityCell(context, recommendationName, "Critical", criticalityCounts["Critical"] ?? 0, recommendations),
              ),
              Expanded(
                child: _buildCriticalityCell(context, recommendationName, "High", criticalityCounts["High"] ?? 0, recommendations),
              ),
              Expanded(
                child: _buildCriticalityCell(context, recommendationName, "Medium", criticalityCounts["Medium"] ?? 0, recommendations),
              ),
              Expanded(
                child: _buildCriticalityCell(context, recommendationName, "Low", criticalityCounts["Low"] ?? 0, recommendations),
              ),
            ],
          ),
          _buildExpandedDetails(context, recommendationName, recommendations),
        ],
      ),
    );
  }

  Widget _buildCriticalityCell(BuildContext context, String recommendationName, String columnCriticality, int recommendationCount, List<RiskRecommendation> recommendations) {
    final cellKey = '${recommendationName}_$columnCriticality';
    
    return ReportService.buildCriticalityCell(
      context,
      recommendationName,
      columnCriticality,
      recommendationCount,
      _expandedCells,
      () {
        if (recommendationCount > 0) {
          setState(() {
            _expandedCells[cellKey] = !(_expandedCells[cellKey] ?? false);
          });
        }
      },
    );
  }

  Widget _buildExpandedDetails(BuildContext context, String recommendationName, List<RiskRecommendation> recommendations) {
    return ReportService.buildExpandedDetails(
      context,
      recommendationName,
      _expandedCells,
      (criticality) {
        final criticalityRecommendations = _getRecommendationsForCriticality(recommendations, criticality);
        return _buildCriticalityDetails(context, criticality, criticalityRecommendations);
      },
    );
  }

  Widget _buildCriticalityDetails(BuildContext context, String criticality, List<RiskRecommendation> recommendations) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return ReportService.buildCriticalityDetails(
      context,
      criticality,
      _buildGroupedRecommendations(context, recommendations),
    );
  }

  List<Widget> _buildGroupedRecommendations(BuildContext context, List<RiskRecommendation> recommendations) {
    final Map<String, List<String>> groupedReasons = {};
    
    for (final rec in recommendations) {
      final testName = rec.testName;
      final reason = rec.reason;
      if (testName.isNotEmpty && reason.isNotEmpty) {
        groupedReasons.putIfAbsent(testName, () => []).add(reason);
      }
    }

    return groupedReasons.entries.map((entry) {
      final testName = entry.key;
      final reasons = entry.value.toSet().toList();
      
      return ReportService.buildSimpleItemCard(context, testName, reasons);
    }).toList();
  }


  Map<String, int> _getCriticalityCounts(List<RiskRecommendation> recommendations) {
    final counts = <String, int>{
      'Critical': 0,
      'High': 0,
      'Medium': 0,
      'Low': 0,
    };

    for (final recommendation in recommendations) {
      final criticality = recommendation.testCriticality;
      if (counts.containsKey(criticality)) {
        counts[criticality] = counts[criticality]! + 1;
      }
    }

    return counts;
  }


  List<RiskRecommendation> _getRecommendationsForCriticality(List<RiskRecommendation> recommendations, String criticality) {
    return recommendations
        .where((recommendation) => recommendation.testCriticality == criticality)
        .toList();
  }

  Widget _buildFourColumnFilters(List<RiskRecommendation> riskRecommendationList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Broad Category
        Expanded(
          child: ReportService.buildFilterColumn(
            context: context,
            title: 'Broad Category',
            items: _getBroadCategoryOptions(riskRecommendationList),
            selectedItem: _selectedBroadCategory,
            onItemSelected: (item) {
              setState(() {
                _selectedBroadCategory = item;
                _selectedCategory = 'All';
                _selectedRecommendation = 'All';
                _selectedTest = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        // Column 2: Category
        Expanded(
          child: ReportService.buildFilterColumn(
            context: context,
            title: 'Category',
            items: _getCategoryOptions(riskRecommendationList),
            selectedItem: _selectedCategory,
            onItemSelected: (item) {
              setState(() {
                _selectedCategory = item;
                _selectedRecommendation = 'All';
                _selectedTest = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        // Column 3: Recommendations
        Expanded(
          child: ReportService.buildFilterColumn(
            context: context,
            title: 'Recommendations',
            items: _getRecommendationOptions(riskRecommendationList),
            selectedItem: _selectedRecommendation,
            onItemSelected: (item) {
              setState(() {
                _selectedRecommendation = item;
                _selectedTest = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        // Column 4: Tests
        Expanded(
          child: ReportService.buildFilterColumn(
            context: context,
            title: 'Tests',
            items: _getTestOptions(riskRecommendationList),
            selectedItem: _selectedTest,
            onItemSelected: (item) {
              setState(() {
                _selectedTest = item;
              });
            },
          ),
        ),
      ],
    );
  }

  List<String> _getBroadCategoryOptions(List<RiskRecommendation> riskRecommendationList) {
    final broadCategories = riskRecommendationList
        .map((rr) => rr.broadCategory)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    broadCategories.sort();
    return ['All', ...broadCategories];
  }

  List<String> _getCategoryOptions(List<RiskRecommendation> riskRecommendationList) {
    List<RiskRecommendation> filteredList = riskRecommendationList;
    if (_selectedBroadCategory != 'All') {
      filteredList = riskRecommendationList.where((rr) => rr.broadCategory == _selectedBroadCategory).toList();
    }
    
    final categories = filteredList
        .map((rr) => rr.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<String> _getRecommendationOptions(List<RiskRecommendation> riskRecommendationList) {
    List<RiskRecommendation> filteredList = riskRecommendationList;
    if (_selectedBroadCategory != 'All') {
      filteredList = filteredList.where((rr) => rr.broadCategory == _selectedBroadCategory).toList();
    }
    if (_selectedCategory != 'All') {
      filteredList = filteredList.where((rr) => rr.category == _selectedCategory).toList();
    }
    
    final recommendations = filteredList
        .map((rr) => rr.recommendation)
        .where((recommendation) => recommendation.isNotEmpty)
        .toSet()
        .toList();
    recommendations.sort();
    return ['All', ...recommendations];
  }

  List<String> _getTestOptions(List<RiskRecommendation> riskRecommendationList) {
    List<RiskRecommendation> filteredList = riskRecommendationList;
    if (_selectedBroadCategory != 'All') {
      filteredList = filteredList.where((rr) => rr.broadCategory == _selectedBroadCategory).toList();
    }
    if (_selectedCategory != 'All') {
      filteredList = filteredList.where((rr) => rr.category == _selectedCategory).toList();
    }
    if (_selectedRecommendation != 'All') {
      filteredList = filteredList.where((rr) => rr.recommendation == _selectedRecommendation).toList();
    }
    
    final tests = filteredList
        .where((rr) => rr.testName.isNotEmpty)
        .map((rr) => rr.testName)
        .toSet()
        .toList();
    tests.sort();
    return ['All', ...tests];
  }


  Future<void> _loadPage() async {
    try {
      _executionStatsModel.setIsPageLoading = true;
      _executionStatsModel.getRiskRecommendation(context);
    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: StackTrace.current.toString(),
          errorSource: "ReportRecommendationsTab",
          severityLevel: 'Critical',
          requestPath: "_loadPage"
        );
      }
    } finally {
      if (mounted) {
        _executionStatsModel.setIsPageLoading = false;
      }
    }
  }
}
