import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:foretale_application/ui/screens/report/report_matrix_service.dart';

class PdfExportUtil {
  // Modern color palette (HTML hex colors)
  static const String _primaryBlue = '#1E40AF';
  static const String _primaryBlueLight = '#3B82F6';
  static const String _darkGrey = '#1F2937';
  static const String _mediumGrey = '#6B7280';
  static const String _lightGrey = '#F3F4F6';
  static const String _borderGrey = '#E5E7EB';
  static const String _successGreen = '#10B981';
  static const String _warningAmber = '#F59E0B';
  static const String _errorRed = '#EF4444';
  static const String _infoBlue = '#3B82F6';

  /// Converts Flutter Color to HTML hex color
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Converts criticality string to HTML hex color
  static String _getCriticalityHexColor(String criticality) {
    final color = ReportService.getCriticalityColor(criticality);
    return _colorToHex(color);
  }

  /// Escapes HTML special characters
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Converts markdown to HTML
  static String _markdownToHtml(String markdown) {
    if (markdown.isEmpty || markdown.trim().isEmpty) {
      return '<p>N/A</p>';
    }
    
    final html = md.markdownToHtml(
      markdown,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    
    // Style the markdown HTML output
    return '''
      <div class="markdown-content">
        $html
      </div>
    ''';
  }

  /// Converts semicolon-separated list to HTML list
  static String _semicolonListToHtml(String semicolonList) {
    if (semicolonList.isEmpty || semicolonList.trim().isEmpty || semicolonList.trim() == 'N/A') {
      return '<p>N/A</p>';
    }
    
    // Split by semicolon and clean up
    final items = semicolonList
        .split(';')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    
    if (items.isEmpty) {
      return '<p>N/A</p>';
    }
    
    // Create HTML list
    final listItems = items.map((item) => '<li>${_escapeHtml(item)}</li>').join('\n');
    
    return '''
      <ul class="semicolon-list">
        $listItems
      </ul>
    ''';
  }

  /// Generates a PDF report from report data using HTML
  static Future<void> exportAnalysisReportToPdf({
    required BuildContext? context,
    required Map<String, dynamic> reportData,
    required String fileName,
  }) async {
    try {
      final slides = reportData['slides'] as List<dynamic>?;
      if (slides == null || slides.isEmpty) {
        throw Exception('No report data to export');
      }

      // Generate HTML content
      final htmlContent = _generateHtmlReport(slides);

      if (kIsWeb) {
        // For web platform, use printing package which supports web
        await _exportPdfForWeb(htmlContent, fileName);
      } else {
        // For mobile platforms, use flutter_html_to_pdf
        await _exportPdfForMobile(htmlContent, fileName);
      }
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Exports PDF for web platform
  static Future<void> _exportPdfForWeb(String htmlContent, String fileName) async {
    // For web, save HTML file and let user open in browser to print to PDF
    // This is the most reliable cross-platform solution for web
    final htmlBytes = Uint8List.fromList(htmlContent.codeUnits);
    
    await FilePicker.platform.saveFile(
      fileName: '$fileName.html',
      bytes: htmlBytes,
    );
    
    // Note: User can open the HTML file in browser and use "Print to PDF" (Ctrl+P / Cmd+P)
    // For automatic PDF generation on web, you would need a backend service
    // or use a JavaScript library like jsPDF or html2pdf.js via platform channels
  }

  /// Exports PDF for mobile platforms using flutter_html_to_pdf
  static Future<void> _exportPdfForMobile(String htmlContent, String fileName) async {
    // Convert HTML to PDF using flutter_html_to_pdf
    final tempDir = await getTemporaryDirectory();
    final targetPath = tempDir.path;
    
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath,
      fileName,
    );

    // Read the generated PDF file (convertFromHtmlContent returns a File)
    final pdfBytes = await generatedPdfFile.readAsBytes();

    // Save the PDF using file picker
    await FilePicker.platform.saveFile(
      fileName: '$fileName.pdf',
      bytes: pdfBytes,
    );
    
    // Clean up temporary PDF file
    try {
      await generatedPdfFile.delete();
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Generates complete HTML report from slides
  static String _generateHtmlReport(List<dynamic> slides) {
    final buffer = StringBuffer();
    
    buffer.write(_getHtmlHeader());
    
      for (int i = 0; i < slides.length; i++) {
        final slide = slides[i];
        final slideType = slide['slide_type'] as String?;
        final title = slide['title'] as String? ?? '';
        final content = slide['content'] as Map<String, dynamic>?;

        if (content == null) continue;

      buffer.write('<div class="page-break">');

        switch (slideType) {
          case 'project_details':
          buffer.write(_buildProjectDetailsHtml(title, content, i + 1, slides.length));
            break;
          case 'test_overview':
          buffer.write(_buildTestOverviewHtml(title, content, i + 1, slides.length));
            break;
          case 'test_results':
          buffer.write(_buildTestResultsHtml(title, content, i + 1, slides.length));
            break;
          case 'risks_and_recommendations':
          buffer.write(_buildRisksAndRecommendationsHtml(title, content, i + 1, slides.length));
            break;
          default:
          buffer.write(_buildGenericHtml(title, content, i + 1, slides.length));
      }
      
      buffer.write('</div>');
    }
    
    buffer.write(_getHtmlFooter());
    
    return buffer.toString();
  }

  /// Builds HTML header with styles
  static String _getHtmlHeader() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    @page {
      size: A4;
      margin: 40px 50px;
    }
    * {
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
      font-size: 12px;
      color: $_darkGrey;
      line-height: 1.6;
      margin: 0;
      padding: 0;
      background: #f5f5f5;
    }
    /* Base font consistency - all text inherits from body */
    * {
      font-family: inherit;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
      background: white;
      padding: 0;
      box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
    }
    .page-break {
      page-break-after: always;
      padding-bottom: 40px;
    }
    .page-break:last-child {
      page-break-after: auto;
    }
    .header {
      background: linear-gradient(135deg, $_primaryBlue 0%, $_primaryBlueLight 100%);
      color: white;
      padding: 20px;
      border-radius: 8px 8px 0 0;
      margin-bottom: 20px;
    }
    .header-content {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .header-title {
      font-size: 18px;
      font-weight: 600;
      margin: 0;
      text-transform: uppercase;
      line-height: 1.4;
    }
    .header-brand {
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 2px;
      margin-bottom: 4px;
      line-height: 1.4;
    }
    .page-number {
      background: rgba(255, 255, 255, 0.2);
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 600;
      line-height: 1.4;
    }
    .footer {
      background: $_lightGrey;
      border-top: 1px solid $_borderGrey;
      padding: 10px 20px;
      margin-top: 20px;
      display: flex;
      justify-content: space-between;
      font-size: 10px;
      color: $_mediumGrey;
    }
    .info-card {
      background: white;
      border-radius: 12px;
      border: 1px solid $_borderGrey;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      margin-bottom: 16px;
      overflow: hidden;
    }
    .info-card-header {
      padding: 16px;
      color: white;
      font-size: 14px;
      font-weight: 600;
      line-height: 1.4;
    }
    .info-card-body {
      padding: 20px;
    }
    .info-row {
      display: flex;
      margin-bottom: 16px;
      align-items: flex-start;
    }
    .info-label {
      width: 140px;
      font-size: 12px;
      font-weight: 600;
      color: $_mediumGrey;
      flex-shrink: 0;
    }
    .info-value {
      flex: 1;
      font-size: 12px;
      color: $_darkGrey;
      line-height: 1.6;
    }
    .section-card {
      background: white;
      border-radius: 12px;
      border: 1px solid $_borderGrey;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      padding: 20px;
      margin-bottom: 16px;
    }
    .section-card.highlight {
      background: rgba(59, 130, 246, 0.05);
      border: 2px solid $_infoBlue;
    }
    .section-title {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 12px;
      display: flex;
      align-items: center;
      gap: 12px;
      line-height: 1.4;
    }
    .section-content {
      font-size: 12px;
      color: $_darkGrey;
      line-height: 1.6;
      margin-top: 12px;
      padding-top: 12px;
      border-top: 1px solid $_borderGrey;
    }
    .section-content-text {
      font-size: 12px;
      color: $_darkGrey;
      line-height: 1.6;
      white-space: pre-wrap;
    }
    .section-title-icon {
      font-size: 20px;
    }
    .risk-card {
      background: white;
      border-radius: 12px;
      border: 2px solid;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      padding: 20px;
      margin-bottom: 12px;
    }
    .risk-header {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-bottom: 16px;
      align-items: center;
    }
    .chip {
      padding: 6px 10px;
      border-radius: 20px;
      font-size: 10px;
      font-weight: 600;
      letter-spacing: 0.5px;
      border: 1.5px solid;
    }
    .criticality-badge {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      margin-left: auto;
    }
    .risk-title-box {
      background: rgba(0, 0, 0, 0.05);
      padding: 16px;
      border-radius: 8px;
      margin-bottom: 12px;
    }
    .risk-title {
      font-size: 13px;
      font-weight: 600;
      color: $_darkGrey;
      margin: 0;
      line-height: 1.6;
    }
    .risk-reason {
      font-size: 12px;
      color: $_mediumGrey;
      line-height: 1.6;
      margin-top: 12px;
    }
    .section-title-header {
      padding: 12px 16px;
      border-radius: 8px;
      border: 2px solid;
      margin-bottom: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .section-title-text {
      font-size: 16px;
      font-weight: 600;
    }
    .section-count {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      color: white;
    }
    .divider {
      height: 1px;
      background: $_borderGrey;
      margin: 12px 0;
    }
    .markdown-content {
      font-size: 12px;
      color: $_darkGrey;
      line-height: 1.6;
    }
    .markdown-content h1,
    .markdown-content h2,
    .markdown-content h3,
    .markdown-content h4,
    .markdown-content h5,
    .markdown-content h6 {
      margin-top: 16px;
      margin-bottom: 8px;
      font-weight: 600;
      color: $_darkGrey;
      line-height: 1.4;
    }
    .markdown-content h1 { font-size: 18px; }
    .markdown-content h2 { font-size: 16px; }
    .markdown-content h3 { font-size: 14px; }
    .markdown-content h4 { font-size: 13px; }
    .markdown-content p {
      margin: 8px 0;
      font-size: 12px;
      line-height: 1.6;
    }
    .markdown-content ul,
    .markdown-content ol {
      margin: 8px 0;
      padding-left: 24px;
      font-size: 12px;
    }
    .markdown-content li {
      margin: 4px 0;
      font-size: 12px;
      line-height: 1.6;
    }
    .markdown-content code {
      background: #f4f4f4;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', 'Consolas', 'Monaco', monospace;
      font-size: 11px;
      line-height: 1.6;
    }
    .markdown-content pre {
      background: #f4f4f4;
      padding: 12px;
      border-radius: 4px;
      overflow-x: auto;
      margin: 12px 0;
    }
    .markdown-content pre code {
      background: none;
      padding: 0;
    }
    .markdown-content strong {
      font-weight: 600;
      color: $_darkGrey;
    }
    .markdown-content em {
      font-style: italic;
    }
    .markdown-content blockquote {
      border-left: 3px solid $_primaryBlue;
      padding-left: 16px;
      margin: 12px 0;
      color: $_mediumGrey;
      font-style: italic;
    }
    .markdown-content table {
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
    }
    .markdown-content table th,
    .markdown-content table td {
      border: 1px solid $_borderGrey;
      padding: 8px;
      text-align: left;
    }
    .markdown-content table th {
      background: $_lightGrey;
      font-weight: 600;
    }
    .semicolon-list {
      margin: 8px 0;
      padding-left: 24px;
      list-style-type: disc;
      font-size: 12px;
    }
    .semicolon-list li {
      margin: 6px 0;
      padding-left: 4px;
      line-height: 1.6;
      font-size: 12px;
    }
    .icon {
      display: inline-block;
      width: 18px;
      text-align: center;
      margin-right: 8px;
    }
  </style>
</head>
<body>
<div class="container">
''';
  }

  /// Builds HTML footer
  static String _getHtmlFooter() {
    final date = DateTime.now().toString().split(' ')[0];
    return '''
  <div class="footer">
    <span>Generated by Foretale.ai</span>
    <span>$date</span>
  </div>
</div>
</body>
</html>
''';
  }

  /// Builds the project details HTML
  static String _buildProjectDetailsHtml(String title, Map<String, dynamic> content, int pageNum, int totalPages) {
    return '''
${_buildModernHeader(title, pageNum, totalPages)}
<div class="info-card">
  <div class="info-card-header" style="background: $_primaryBlue;">
    <div style="display: flex; align-items: center; gap: 12px;">
      <div style="width: 4px; height: 24px; background: white; border-radius: 2px;"></div>
      <span>Project Information</span>
    </div>
  </div>
  <div class="info-card-body">
    ${_buildInfoRow('Project Name', content['project_name']?.toString() ?? 'N/A', icon: '📋')}
    ${_buildInfoRow('Project Description', content['project_description']?.toString() ?? 'N/A', icon: '📝')}
    ${_buildInfoRow('Date of Creation', content['date_of_creation']?.toString() ?? 'N/A', icon: '📅')}
    ${_buildInfoRow('Scope', content['scope']?.toString() ?? 'N/A', icon: '📊')}
  </div>
</div>
<div class="info-card">
  <div class="info-card-header" style="background: $_primaryBlueLight;">
    <div style="display: flex; align-items: center; gap: 12px;">
      <div style="width: 4px; height: 24px; background: white; border-radius: 2px;"></div>
      <span>Organization Details</span>
    </div>
  </div>
  <div class="info-card-body">
    ${_buildInfoRow('Industry', content['industry']?.toString() ?? 'N/A', icon: '🏭')}
    ${_buildInfoRow('Company', content['company']?.toString() ?? 'N/A', icon: '🏢')}
    ${_buildInfoRow('System', content['system']?.toString() ?? 'N/A', icon: '⚙️')}
  </div>
</div>
''';
  }

  /// Builds the test overview HTML
  static String _buildTestOverviewHtml(String title, Map<String, dynamic> content, int pageNum, int totalPages) {
        final criticality = content['criticality']?.toString() ?? '';
    final criticalityColor = _getCriticalityHexColor(criticality);
    
    return '''
${_buildModernHeader(title, pageNum, totalPages)}
<div class="info-card">
  <div class="info-card-header" style="background: $criticalityColor;">
    <div style="display: flex; align-items: center; gap: 12px;">
      <div style="width: 4px; height: 24px; background: white; border-radius: 2px;"></div>
      <span>Test Details</span>
    </div>
  </div>
  <div class="info-card-body">
    ${_buildInfoRow('Test Name', content['test_name']?.toString() ?? 'N/A', icon: '🧪')}
    ${_buildInfoRow('Test Code', content['test_code']?.toString() ?? 'N/A', icon: '🔖')}
    ${_buildInfoRow('Criticality', criticality.toUpperCase(), icon: '⚠️', valueColor: criticalityColor)}
    ${_buildInfoRow('Category', content['category']?.toString() ?? 'N/A', icon: '📂')}
    ${_buildInfoRow('Module', content['module']?.toString() ?? 'N/A', icon: '📦')}
  </div>
</div>
${_buildModernSectionCard('Description', content['description']?.toString() ?? 'N/A', '📄', _infoBlue)}
${_buildModernSectionCard('Potential Risks', content['potential_risks']?.toString() ?? 'N/A', '⚠️', _errorRed, parseSemicolonList: true)}
${_buildModernSectionCard('Recommendations', content['recommendations']?.toString() ?? 'N/A', '💡', _successGreen, parseSemicolonList: true)}
''';
  }

  /// Builds the test results HTML
  static String _buildTestResultsHtml(String title, Map<String, dynamic> content, int pageNum, int totalPages) {
    final potentialImpact = content['potential_impact']?.toString() ?? 'N/A';
    final feedbackSummary = content['feedback_summary']?.toString() ?? 'N/A';
    
    return '''
${_buildModernHeader(title, pageNum, totalPages)}
${_buildModernSectionCard('Test Result', content['test_result']?.toString() ?? 'N/A', '✅', _successGreen, highlight: true)}
${_buildModernSectionCard('Potential Impact', potentialImpact, '📊', _warningAmber, parseMarkdown: true)}
${_buildModernSectionCard('Feedback Summary', feedbackSummary, '💬', _infoBlue, parseMarkdown: true)}
''';
  }

  /// Builds the risks and recommendations HTML
  static String _buildRisksAndRecommendationsHtml(String title, Map<String, dynamic> content, int pageNum, int totalPages) {
        final risks = content['identified_risks'] as List<dynamic>? ?? [];
        final recommendations = content['risk_recommendations'] as List<dynamic>? ?? [];
        
    final buffer = StringBuffer();
    buffer.write(_buildModernHeader(title, pageNum, totalPages));

        if (risks.isNotEmpty) {
      buffer.write(_buildSectionTitle('Identified Risks', risks.length, _errorRed));
          
          for (var risk in risks) {
            final riskMap = risk as Map<String, dynamic>;
        buffer.write(_buildModernRiskCard(riskMap, isRisk: true));
          }
        }

        if (recommendations.isNotEmpty) {
      buffer.write('<div style="margin-top: 20px;"></div>');
      buffer.write(_buildSectionTitle('Risk Recommendations', recommendations.length, _successGreen));
          
          for (var rec in recommendations) {
            final recMap = rec as Map<String, dynamic>;
        buffer.write(_buildModernRiskCard(recMap, isRisk: false));
      }
    }
    
    return buffer.toString();
  }

  /// Builds a generic HTML page for unknown slide types
  static String _buildGenericHtml(String title, Map<String, dynamic> content, int pageNum, int totalPages) {
    final buffer = StringBuffer();
    buffer.write(_buildModernHeader(title, pageNum, totalPages));

        content.forEach((key, value) {
      buffer.write(_buildInfoRow(key, value?.toString() ?? 'N/A'));
    });
    
    return buffer.toString();
  }

  /// Builds modern header with gradient (HTML)
  static String _buildModernHeader(String title, int pageNum, int totalPages) {
    return '''
<div class="header">
  <div class="header-content">
    <div>
      <div class="header-brand">FORETALE.AI</div>
      <div class="header-title">${_escapeHtml(title.toUpperCase())}</div>
    </div>
    <div class="page-number">$pageNum / $totalPages</div>
  </div>
</div>
''';
  }

  /// Builds modern section card (HTML)
  static String _buildModernSectionCard(
    String title,
    String content,
    String icon,
    String color, {
    bool highlight = false,
    bool parseMarkdown = false,
    bool parseSemicolonList = false,
  }) {
    final bgColor = highlight ? 'rgba(59, 130, 246, 0.05)' : 'white';
    final borderColor = highlight ? color : _borderGrey;
    final borderWidth = highlight ? '2px' : '1px';
    
    String contentHtml;
    if (parseMarkdown) {
      contentHtml = _markdownToHtml(content);
    } else if (parseSemicolonList) {
      contentHtml = _semicolonListToHtml(content);
    } else {
      contentHtml = '<div class="section-content-text">${_escapeHtml(content)}</div>';
    }
    
    return '''
<div class="section-card" style="background: $bgColor; border-color: $borderColor; border-width: $borderWidth;">
  <div class="section-title">
    <span class="section-title-icon">${_getIconHtml(icon)}</span>
    <span style="color: $color;">${_escapeHtml(title)}</span>
  </div>
  <div class="divider"></div>
  $contentHtml
</div>
''';
  }

  /// Gets icon HTML for Font Awesome icons
  static String _getIconHtml(String iconName) {
    final iconMap = {
      '📋': '<i class="fas fa-clipboard-list"></i>',
      '📝': '<i class="fas fa-file-alt"></i>',
      '📅': '<i class="fas fa-calendar"></i>',
      '📊': '<i class="fas fa-chart-bar"></i>',
      '🏭': '<i class="fas fa-industry"></i>',
      '🏢': '<i class="fas fa-building"></i>',
      '⚙️': '<i class="fas fa-cog"></i>',
      '🧪': '<i class="fas fa-flask"></i>',
      '🔖': '<i class="fas fa-tag"></i>',
      '⚠️': '<i class="fas fa-exclamation-triangle"></i>',
      '📂': '<i class="fas fa-folder"></i>',
      '📦': '<i class="fas fa-box"></i>',
      '📄': '<i class="fas fa-file"></i>',
      '💡': '<i class="fas fa-lightbulb"></i>',
      '✅': '<i class="fas fa-check-circle"></i>',
      '💬': '<i class="fas fa-comments"></i>',
    };
    
    return iconMap[iconName] ?? '<i class="fas fa-circle"></i>';
  }

  /// Builds info row (HTML)
  static String _buildInfoRow(String label, String value, {String? icon, String? valueColor}) {
    final iconHtml = icon != null ? '<span class="icon">${_getIconHtml(icon)}</span>' : '<span class="icon"></span>';
    final valueStyle = valueColor != null 
        ? 'color: $valueColor; font-weight: bold;' 
        : 'color: $_darkGrey;';
    
    return '''
<div class="info-row">
  $iconHtml
  <div class="info-label">${_escapeHtml(label)}</div>
  <div class="info-value" style="$valueStyle">${_escapeHtml(value)}</div>
</div>
''';
  }

  /// Builds section title with count (HTML)
  static String _buildSectionTitle(String title, int count, String color) {
    return '''
<div class="section-title-header" style="background: rgba(59, 130, 246, 0.1); border-color: $color;">
  <div class="section-title-text" style="color: $color;">${_escapeHtml(title)}</div>
  <div class="section-count" style="background: $color;">$count</div>
</div>
''';
  }

  /// Builds modern risk/recommendation card (HTML)
  static String _buildModernRiskCard(Map<String, dynamic> data, {required bool isRisk}) {
    final title = isRisk 
        ? (data['risk_topic']?.toString() ?? 'N/A')
        : (data['recommendation']?.toString() ?? 'N/A');
    final reason = data['reason']?.toString() ?? '';
    final broadCategory = data['broad_category']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';
    final criticality = data['criticality']?.toString() ?? '';
    final color = isRisk 
        ? _getCriticalityHexColor(criticality)
        : _successGreen;

    final criticalityBadge = isRisk 
        ? '<div class="criticality-badge" style="background: rgba(59, 130, 246, 0.1); border: 1px solid $color; color: $color;">${_escapeHtml(criticality.toUpperCase())}</div>'
        : '';

    return '''
<div class="risk-card" style="border-color: $color;">
  <div class="risk-header">
    ${_buildModernChip(broadCategory, color)}
    ${_buildModernChip(category, color)}
    $criticalityBadge
  </div>
  <div class="risk-title-box">
    <div class="risk-title">${_escapeHtml(title)}</div>
  </div>
  ${reason.isNotEmpty ? '<div class="risk-reason">${_escapeHtml(reason)}</div>' : ''}
</div>
''';
  }

  /// Builds modern chip widget (HTML)
  static String _buildModernChip(String label, String color) {
    return '''
<div class="chip" style="background: rgba(59, 130, 246, 0.1); border-color: $color; color: $color;">${_escapeHtml(label)}</div>
''';
  }
}
