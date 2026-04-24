import json
import os
import boto3

def lambda_handler(event, context):
    """Test lambda to verify Secrets Manager access"""
    
    try:
        # Get environment variables
        secret_name = os.environ.get('SECRETS_MANAGER_SECRET', 'Not set')
        rds_endpoint = os.environ.get('RDS_ENDPOINT', 'Not set')
        
        # Test Secrets Manager access
        secrets_client = boto3.client('secretsmanager')
        
        try:
            response = secrets_client.get_secret_value(SecretId=secret_name)
            secret_data = json.loads(response['SecretString'])
            
            # Mask sensitive data
            masked_secret = {
                'username': secret_data.get('username', 'N/A'),
                'engine': secret_data.get('engine', 'N/A'),
                'host': secret_data.get('host', 'N/A'),
                'port': secret_data.get('port', 'N/A'),
                'dbname': secret_data.get('dbname', 'N/A'),
                'password': '***MASKED***' if 'password' in secret_data else 'N/A'
            }
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Successfully accessed Secrets Manager in us-east-2',
                    'secret_name': secret_name,
                    'secret_arn': response.get('ARN'),
                    'secret_region': response.get('ARN').split(':')[3] if response.get('ARN') else 'unknown',
                    'rds_endpoint': rds_endpoint,
                    'secret_data': masked_secret,
                    'test_status': 'PASS - IAM permissions working correctly'
                }, indent=2)
            }
            
        except secrets_client.exceptions.ResourceNotFoundException:
            return {
                'statusCode': 404,
                'body': json.dumps({
                    'error': f'Secret not found: {secret_name}',
                    'test_status': 'FAIL - Secret does not exist'
                })
            }
        except Exception as e:
            error_name = type(e).__name__
            return {
                'statusCode': 403 if 'AccessDenied' in str(e) else 500,
                'body': json.dumps({
                    'error': f'{error_name}: {str(e)}',
                    'secret_name': secret_name,
                    'test_status': 'FAIL - Permission or configuration error'
                })
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Lambda error: {str(e)}',
                'error_type': type(e).__name__
            })
        }
