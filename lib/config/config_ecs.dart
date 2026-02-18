class CsvUploadECS {
    // Base URL for APIs
    static const String url = 'https://6pz582qld4.execute-api.us-east-2.amazonaws.com/dev/ecs_invoker_resource';
    static const String clusterName = 'cluster-uploads';
    static const String taskDefinition = 'td-csv-upload';
    static const String containerName = 'con-csv-upload';
    static const String appPath = '/opt/python/initiate-data-upload-process/app.py';
    static const String pythonPath = 'python3.12';
}


class TestExecutionECS {
    // Base URL for APIs
    static const String url = 'https://6pz582qld4.execute-api.us-east-2.amazonaws.com/dev/ecs_invoker_resource';
    static const String clusterName = 'cluster-execute';
    static const String taskDefinition = 'td-db-process';
    static const String containerName = 'con-db-process';
    static const String appPath = '/opt/python/invoke-db-process/app.py';
    static const String pythonPath = 'python3.12';
}
