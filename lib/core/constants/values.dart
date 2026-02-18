const List<String> systemNames = [
  'SAP',
  'Oracle',
  'Salesforce',
  'NetSuite',
  'QuickBooks',
];

const List<String> runTypesList = [
  'Rule-Based',
  'Statistics-Based',
  'ML',
  'AI'
];

const List<String> criticalityLevelsList = [
    'Low', 
    'Medium', 
    'High', 
    'Critical'
];

const Map<String, List<String>> runProgramsList = {
      'Rule-Based':['SQL'],
      'Statistics-Based':['SQL'],
      'ML':['Semantic-Search', 'Anamoly-Detection']
    };