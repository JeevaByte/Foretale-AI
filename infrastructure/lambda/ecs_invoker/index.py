"""
Lambda Function: ECS Task Invoker
Triggers ECS Fargate tasks for long-running operations (CSV processing, test execution)
"""

import json
import os
import boto3
from botocore.exceptions import ClientError

# Environment variables
ECS_CLUSTER_UPLOADS = os.environ['ECS_CLUSTER_UPLOADS']
ECS_CLUSTER_EXECUTE = os.environ['ECS_CLUSTER_EXECUTE']
ECS_TASK_DEFINITION_CSV = os.environ['ECS_TASK_DEFINITION_CSV']
ECS_TASK_DEFINITION_EXECUTE = os.environ['ECS_TASK_DEFINITION_EXECUTE']
AWS_REGION = os.environ['AWS_REGION']

# Initialize AWS clients
ecs_client = boto3.client('ecs', region_name=AWS_REGION)


def lambda_handler(event, context):
    """
    Main Lambda handler for ECS task invocation
    
    Expected event format:
    {
        "task_type": "csv_upload" | "test_execution",
        "parameters": {
            "s3_bucket": "bucket-name",
            "s3_key": "path/to/file.csv",
            "user_id": 123,
            "project_id": 456
        },
        "subnet_ids": ["subnet-xxx", "subnet-yyy"],
        "security_groups": ["sg-xxx"]
    }
    """
    
    try:
        # Parse request body
        if isinstance(event, str):
            body = json.loads(event)
        elif 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event
        
        task_type = body.get('task_type')
        parameters = body.get('parameters', {})
        subnet_ids = body.get('subnet_ids', [])
        security_groups = body.get('security_groups', [])
        
        if not task_type:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required field: task_type'
                })
            }
        
        # Determine cluster and task definition based on task type
        if task_type == 'csv_upload':
            cluster = ECS_CLUSTER_UPLOADS
            task_definition = ECS_TASK_DEFINITION_CSV
        elif task_type == 'test_execution':
            cluster = ECS_CLUSTER_EXECUTE
            task_definition = ECS_TASK_DEFINITION_EXECUTE
        else:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': f'Invalid task_type: {task_type}. Must be "csv_upload" or "test_execution"'
                })
            }
        
        # Build environment variables for ECS task
        environment = []
        for key, value in parameters.items():
            environment.append({
                'name': key.upper(),
                'value': str(value)
            })
        
        # Prepare network configuration
        network_config = {
            'awsvpcConfiguration': {
                'subnets': subnet_ids,
                'securityGroups': security_groups,
                'assignPublicIp': 'DISABLED'  # Tasks in private subnets
            }
        }
        
        # Run ECS task
        response = ecs_client.run_task(
            cluster=cluster,
            taskDefinition=task_definition,
            launchType='FARGATE',
            networkConfiguration=network_config,
            overrides={
                'containerOverrides': [
                    {
                        'name': f'con-{task_type.replace("_", "-")}',
                        'environment': environment
                    }
                ]
            },
            count=1
        )
        
        # Check for failures
        if response.get('failures'):
            failure = response['failures'][0]
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Failed to start ECS task',
                    'reason': failure.get('reason'),
                    'detail': failure.get('detail')
                })
            }
        
        # Extract task information
        tasks = response.get('tasks', [])
        if not tasks:
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'No task was started'
                })
            }
        
        task = tasks[0]
        task_arn = task['taskArn']
        task_id = task_arn.split('/')[-1]
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': True,
                'message': f'ECS task started successfully',
                'task_id': task_id,
                'task_arn': task_arn,
                'cluster': cluster,
                'task_type': task_type
            })
        }
        
    except ClientError as aws_error:
        print(f"AWS error: {str(aws_error)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'AWS service error',
                'message': str(aws_error)
            })
        }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
