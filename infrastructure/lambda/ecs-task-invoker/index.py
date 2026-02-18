import json
import os
from aws_lambda_powertools import Logger
import boto3

logger = Logger()
ecs_client = boto3.client('ecs')


def lambda_handler(event, context):
    """
    Invoke ECS tasks for long-running operations
    
    Expected event:
    {
        "task_type": "csv_processor|test_executor",
        "cluster": "uploads|execute",
        "container_overrides": {
            "env": [
                {"name": "VAR_NAME", "value": "value"}
            ]
        }
    }
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        task_type = event.get('task_type', 'csv_processor').lower()
        cluster_type = event.get('cluster', 'uploads').lower()
        container_overrides = event.get('container_overrides', {})
        
        # Map task type to task definition
        task_definitions = {
            'csv_processor': os.environ.get('ECS_TASK_DEFINITION_CSV'),
            'test_executor': os.environ.get('ECS_TASK_DEFINITION_EXECUTE')
        }
        
        # Map cluster type to cluster ARN
        clusters = {
            'uploads': os.environ.get('ECS_CLUSTER_UPLOADS'),
            'execute': os.environ.get('ECS_CLUSTER_EXECUTE')
        }
        
        task_definition = task_definitions.get(task_type)
        cluster = clusters.get(cluster_type)
        
        if not task_definition or not cluster:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': f'Invalid task_type ({task_type}) or cluster ({cluster_type})'
                })
            }
        
        logger.info(f"Running task {task_definition} on cluster {cluster}")
        
        # Prepare run_task parameters
        run_task_params = {
            'cluster': cluster,
            'taskDefinition': task_definition,
            'launchType': 'EC2',
            'count': 1
        }
        
        # Add container overrides if provided
        if container_overrides:
            run_task_params['overrides'] = {
                'containerOverrides': [
                    {
                        'name': os.environ.get('ECS_CONTAINER_NAME', 'app'),
                        **container_overrides
                    }
                ]
            }
        
        # Run the task
        response = ecs_client.run_task(**run_task_params)
        
        task_arn = response['tasks'][0]['taskArn'] if response.get('tasks') else None
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Task {task_type} started successfully',
                'task_arn': task_arn,
                'cluster': cluster,
                'task_definition': task_definition
            })
        }
        
    except Exception as e:
        logger.exception(f"Error invoking ECS task: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Failed to invoke task: {str(e)}'})
        }
