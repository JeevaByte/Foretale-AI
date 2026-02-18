import 'package:flutter/material.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/models/report_model.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/message_helper.dart';
import 'package:foretale_application/ui/screens/report/report_matrix_service.dart';
import 'package:provider/provider.dart';

class ReportBusinessRisksTab extends StatefulWidget {
  const ReportBusinessRisksTab({super.key});

  @override
  State<ReportBusinessRisksTab> createState() => _ReportBusinessRisksTabState();
}

class _ReportBusinessRisksTabState extends State<ReportBusinessRisksTab> {
  late ExecutionStatsModel _executionStatsModel;
  String _selectedBroadCategory = 'All';
  String _selectedCategory = 'All';
  String _selectedRiskTopic = 'All';
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
              _buildStickyHeader(model.riskTopicList),
              Expanded(
                child: _buildScrollableContent(model.riskTopicList),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(List<RiskTopic> riskTopicList) {
    if (riskTopicList.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFourColumnFilters(riskTopicList),
          const SizedBox(height: 12),
          ReportService.buildTableHeader(context, "Risk"),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(List<RiskTopic> riskTopicList) {
    if (riskTopicList.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'No Risk Topics',
          subtitle: 'No risk topics found for this project.',
          icon: Icons.warning_amber_outlined,
        ),
      );
    }

    final filteredRiskTopics = _getFilteredRiskTopics(riskTopicList);
    final groupedRisks = _groupRisksByTopic(filteredRiskTopics);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ...groupedRisks.entries.map((entry) => 
            _buildRiskRow(context, entry.key, entry.value, riskTopicList)
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<RiskTopic> _getFilteredRiskTopics(List<RiskTopic> riskTopicList) {
    return riskTopicList.where((riskTopic) {
      bool matchesBroadCategory = _selectedBroadCategory == 'All' || riskTopic.broadCategory == _selectedBroadCategory;
      bool matchesCategory = _selectedCategory == 'All' || riskTopic.category == _selectedCategory;
      bool matchesRiskTopic = _selectedRiskTopic == 'All' || riskTopic.riskTopic == _selectedRiskTopic;
      bool matchesTest = _selectedTest == 'All' || riskTopic.testName == _selectedTest;
      
      return matchesBroadCategory && matchesCategory && matchesRiskTopic && matchesTest;
    }).toList();
  }

  Map<String, List<RiskTopic>> _groupRisksByTopic(List<RiskTopic> riskTopics) {
    final Map<String, List<RiskTopic>> grouped = {};
    for (final riskTopic in riskTopics) {
      grouped.putIfAbsent(riskTopic.riskTopic, () => []).add(riskTopic);
    }
    return grouped;
  }


  Widget _buildRiskCellContent(BuildContext context, RiskTopic firstRiskTopic, String riskName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleFontSize = context.responsiveFontSize(12);
    final categoryFontSize = context.responsiveFontSize(9);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          riskName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              firstRiskTopic.broadCategory,
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
              firstRiskTopic.category,
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

  Widget _buildRiskRow(
    BuildContext context,
    String riskName,
    List<RiskTopic> riskTopics,
    List<RiskTopic> allRiskTopics,
  ) {
    final criticalityCounts = _getCriticalityCounts(riskTopics);
    final firstRiskTopic = riskTopics.first;
    
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
                    _buildRiskCellContent(context, firstRiskTopic, riskName),
                  ],
                ),
              ),
              Expanded(
                child: ReportService.buildCriticalityCell(
                  context, 
                  riskName, 
                  "Critical", 
                  criticalityCounts["Critical"] ?? 0, 
                  _expandedCells,
                  () {
                    if (criticalityCounts["Critical"]! > 0) {
                      setState(() {
                        final cellKey = '${riskName}_Critical';
                        _expandedCells[cellKey] = !(_expandedCells[cellKey] ?? false);
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ReportService.buildCriticalityCell(
                  context, 
                  riskName, 
                  "High", 
                  criticalityCounts["High"] ?? 0, 
                  _expandedCells,
                  () {
                    if (criticalityCounts["High"]! > 0) {
                      setState(() {
                        final cellKey = '${riskName}_High';
                        _expandedCells[cellKey] = !(_expandedCells[cellKey] ?? false);
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ReportService.buildCriticalityCell(
                  context, 
                  riskName, 
                  "Medium", 
                  criticalityCounts["Medium"] ?? 0, 
                  _expandedCells,
                  () {
                    if (criticalityCounts["Medium"]! > 0) {
                      setState(() {
                        final cellKey = '${riskName}_Medium';
                        _expandedCells[cellKey] = !(_expandedCells[cellKey] ?? false);
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ReportService.buildCriticalityCell(
                  context, 
                  riskName, 
                  "Low", 
                  criticalityCounts["Low"] ?? 0, 
                  _expandedCells,
                  () {
                    if (criticalityCounts["Low"]! > 0) {
                      setState(() {
                        final cellKey = '${riskName}_Low';
                        _expandedCells[cellKey] = !(_expandedCells[cellKey] ?? false);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          ReportService.buildExpandedDetails(
            context, 
            riskName, 
            _expandedCells,
            (criticality) => _buildCriticalityDetailsForService(context, criticality, riskTopics),
          ),
        ],
      ),
    );
  }


  Widget _buildCriticalityDetailsForService(BuildContext context, String criticality, List<RiskTopic> riskTopics) {
    final testReasons = _getTestReasonsForCriticality(riskTopics, criticality);
    final detailsWidgets = _buildGroupedTestReasons(context, testReasons);
    return ReportService.buildCriticalityDetails(context, criticality, detailsWidgets);
  }


  List<Widget> _buildGroupedTestReasons(BuildContext context, List<Map<String, String>> testReasons) {
    final Map<String, List<String>> groupedReasons = {};
    
    for (final testReason in testReasons) {
      final testName = testReason['testName'] ?? '';
      final reason = testReason['reason'] ?? '';
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


  Map<String, int> _getCriticalityCounts(List<RiskTopic> riskTopics) {
    final counts = <String, int>{
      'Critical': 0,
      'High': 0,
      'Medium': 0,
      'Low': 0,
    };

    for (final riskTopic in riskTopics) {
      final criticality = riskTopic.testCriticality;
      if (counts.containsKey(criticality)) {
        counts[criticality] = counts[criticality]! + 1;
      }
    }

    return counts;
  }

  List<Map<String, String>> _getTestReasonsForCriticality(List<RiskTopic> riskTopics, String criticality) {
    return riskTopics
        .where((riskTopic) => 
            riskTopic.testCriticality == criticality && 
            riskTopic.reason.isNotEmpty)
        .map((riskTopic) => {
          'testName': riskTopic.testName,
          'reason': riskTopic.reason,
        })
        .toList();
  }

  Widget _buildFourColumnFilters(List<RiskTopic> riskTopicList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Broad Category (vertical)
        Expanded(
          child: ReportService.buildFilterColumnWithCounts(
            context: context,
            title: 'Broad Category',
            itemsWithCounts: _getBroadCategoryOptionsWithCounts(riskTopicList),
            selectedItem: _selectedBroadCategory,
            onItemSelected: (item) {
              setState(() {
                _selectedBroadCategory = item;
                _selectedCategory = 'All';
                _selectedRiskTopic = 'All';
                _selectedTest = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        // Column 2: Category
        Expanded(
          child: ReportService.buildFilterColumnWithCounts(
            context: context,
            title: 'Category',
            itemsWithCounts: _getCategoryOptionsWithCounts(riskTopicList),
            selectedItem: _selectedCategory,
            onItemSelected: (item) {
              setState(() {
                _selectedCategory = item;
                _selectedRiskTopic = 'All';
                _selectedTest = 'All';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        // Column 3: Risk Topics
        Expanded(
          child: ReportService.buildFilterColumnWithCounts(
            context: context,
            title: 'Risk Topics',
            itemsWithCounts: _getRiskTopicOptionsWithCounts(riskTopicList),
            selectedItem: _selectedRiskTopic,
            onItemSelected: (item) {
              setState(() {
                _selectedRiskTopic = item;
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
            items: _getTestOptions(riskTopicList),
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


  List<Map<String, dynamic>> _getBroadCategoryOptionsWithCounts(List<RiskTopic> riskTopicList) {
    final Map<String, Set<String>> categoryTests = {};
    
    for (final rt in riskTopicList) {
      if (rt.broadCategory.isNotEmpty && rt.testName.isNotEmpty) {
        categoryTests.putIfAbsent(rt.broadCategory, () => <String>{}).add(rt.testName);
      }
    }
    
    final List<Map<String, dynamic>> result = [
      {'name': 'All', 'count': riskTopicList.where((rt) => rt.testName.isNotEmpty).length}
    ];
    
    final sortedCategories = categoryTests.keys.toList()..sort();
    for (final category in sortedCategories) {
      result.add({
        'name': category,
        'count': categoryTests[category]!.length,
      });
    }
    
    return result;
  }

  List<Map<String, dynamic>> _getCategoryOptionsWithCounts(List<RiskTopic> riskTopicList) {
    List<RiskTopic> filteredList = riskTopicList;
    if (_selectedBroadCategory != 'All') {
      filteredList = riskTopicList.where((rt) => rt.broadCategory == _selectedBroadCategory).toList();
    }
    
    final Map<String, Set<String>> categoryTests = {};
    
    for (final rt in filteredList) {
      if (rt.category.isNotEmpty && rt.testName.isNotEmpty) {
        categoryTests.putIfAbsent(rt.category, () => <String>{}).add(rt.testName);
      }
    }
    
    final List<Map<String, dynamic>> result = [
      {'name': 'All', 'count': filteredList.where((rt) => rt.testName.isNotEmpty).length}
    ];
    
    final sortedCategories = categoryTests.keys.toList()..sort();
    for (final category in sortedCategories) {
      result.add({
        'name': category,
        'count': categoryTests[category]!.length,
      });
    }
    
    return result;
  }

  List<Map<String, dynamic>> _getRiskTopicOptionsWithCounts(List<RiskTopic> riskTopicList) {
    List<RiskTopic> filteredList = riskTopicList;
    if (_selectedBroadCategory != 'All') {
      filteredList = filteredList.where((rt) => rt.broadCategory == _selectedBroadCategory).toList();
    }
    if (_selectedCategory != 'All') {
      filteredList = filteredList.where((rt) => rt.category == _selectedCategory).toList();
    }
    
    final Map<String, Set<String>> topicTests = {};
    
    for (final rt in filteredList) {
      if (rt.riskTopic.isNotEmpty && rt.testName.isNotEmpty) {
        topicTests.putIfAbsent(rt.riskTopic, () => <String>{}).add(rt.testName);
      }
    }
    
    final List<Map<String, dynamic>> result = [
      {'name': 'All', 'count': filteredList.where((rt) => rt.testName.isNotEmpty).length}
    ];
    
    final sortedTopics = topicTests.keys.toList()..sort();
    for (final topic in sortedTopics) {
      result.add({
        'name': topic,
        'count': topicTests[topic]!.length,
      });
    }
    
    return result;
  }

  List<String> _getTestOptions(List<RiskTopic> riskTopicList) {
    List<RiskTopic> filteredList = riskTopicList;
    if (_selectedBroadCategory != 'All') {
      filteredList = filteredList.where((rt) => rt.broadCategory == _selectedBroadCategory).toList();
    }
    if (_selectedCategory != 'All') {
      filteredList = filteredList.where((rt) => rt.category == _selectedCategory).toList();
    }
    if (_selectedRiskTopic != 'All') {
      filteredList = filteredList.where((rt) => rt.riskTopic == _selectedRiskTopic).toList();
    }
    
    final tests = filteredList
        .where((rt) => rt.testName.isNotEmpty)
        .map((rt) => rt.testName)
        .toSet()
        .toList();
    tests.sort();
    return ['All', ...tests];
  }


  Future<void> _loadPage() async {
    try {
      _executionStatsModel.setIsPageLoading = true;
      _executionStatsModel.getRiskTopic(context);
    } catch (e) {
      if (mounted) {
        SnackbarMessage.showErrorMessage(
          context, 
          e.toString(),
          logError: true,
          errorMessage: e.toString(),
          errorStackTrace: StackTrace.current.toString(),
          errorSource: "ReportBusinessRisksTab",
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

