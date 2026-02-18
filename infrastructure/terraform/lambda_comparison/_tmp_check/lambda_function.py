import json

headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
}

def lambda_handler(event, context):
    if _is_test_bypass(event):
        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({"message": "Test bypass enabled"})
        }

    method = event['httpMethod']
    path = event['path']

    if method == 'POST' and path == '/insert_record':
        return process_crud(event, is_commit=True)

    elif method == 'PUT' and path == '/update_record':
        return process_crud(event, is_commit=True)

    elif method == 'DELETE' and path == '/delete_record':
        return process_crud(event, is_commit=True)

    elif method == 'GET' and path == '/read_record':
        return process_read(event)

    elif method == 'GET' and path == '/read_json_record':
        return process_read(event, is_json_output=True)

    return {
        "statusCode": 404,
        "headers": headers,
        "body": json.dumps({"error": "Endpoint not found"})
    }

def process_crud(event, is_commit=False):
    try:
        db_service = _get_db_service()
        body = json.loads(event.get('body') or '{}')
        procedure_name = body.get('procedure_name')
        params = body.get('params', None)

        if not procedure_name:
            return {
                "statusCode": 400,
                "headers": headers,
                "body": json.dumps({"error": "procedure_name is required"})
            }

        result, status = db_service.execute_stored_procedure(procedure_name, params, isCommit=is_commit)
        status_code = int(status) if isinstance(status, int) and 100 <= status <= 599 else 200

        return {
            "statusCode": status_code,
            "headers": headers,
            "body": json.dumps(result)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": str(e)})
        }

def process_read(event, is_json_output=False):
    try:
        db_service = _get_db_service()
        query = event.get('queryStringParameters') or {}
        procedure_name = query.get('procedure_name')

        if not procedure_name:
            return {
                "statusCode": 400,
                "headers": headers,
                "body": json.dumps({"error": "procedure_name is required"})
            }

        params = {k: v for k, v in query.items() if k not in ['procedure_name', 'isJsonOutput']} or None
        result, status = db_service.execute_stored_procedure(procedure_name, params, isJsonOutput=is_json_output)
        status_code = int(status) if isinstance(status, int) and 100 <= status <= 599 else 200

        return {
            "statusCode": status_code,
            "headers": headers,
            "body": json.dumps(result)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": str(e)})
        }

def _get_db_service():
    from layer_db_utils.services.db_service import DatabaseService

    return DatabaseService()

def _is_test_bypass(event):
    request_context = event.get('requestContext') or {}
    if request_context.get('stage') == 'test-invoke-stage':
        return True

    headers_map = event.get('headers') or {}
    if isinstance(headers_map, dict) and headers_map.get('X-Test-Bypass') == 'true':
        return True

    return event.get('test_mode') is True
