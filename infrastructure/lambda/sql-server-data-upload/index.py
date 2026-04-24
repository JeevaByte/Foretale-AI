import json
import pyodbc
import os
import csv
import io
from aws_lambda_powertools import Logger
import boto3

logger = Logger()
secrets_client = boto3.client('secretsmanager')
s3_client = boto3.client('s3')


def get_db_connection():
    """Get database connection from Secrets Manager"""
    try:
        secret_name = os.environ.get('SECRETS_MANAGER_SECRET')
        response = secrets_client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        
        connection_string = (
            f"Driver={{ODBC Driver 17 for SQL Server}};"
            f"Server={os.environ.get('RDS_ENDPOINT')};"
            f"Port={os.environ.get('RDS_PORT')};"
            f"Database={os.environ.get('RDS_DATABASE')};"
            f"UID={secret.get('username')};"
            f"PWD={secret.get('password')};"
        )
        
        conn = pyodbc.connect(connection_string)
        return conn
    except Exception as e:
        logger.exception(f"Failed to get database connection: {str(e)}")
        raise


def lambda_handler(event, context):
    """
    Upload CSV data from S3 to SQL Server
    
    Expected event:
    {
        "bucket": "bucket-name",
        "key": "path/to/file.csv",
        "table_name": "TableName",
        "columns": ["col1", "col2", "col3"]
    }
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        bucket = event.get('bucket')
        key = event.get('key')
        table_name = event.get('table_name')
        columns = event.get('columns', [])
        
        if not all([bucket, key, table_name]):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'bucket, key, and table_name are required'})
            }
        
        # Download CSV from S3
        logger.info(f"Downloading {key} from {bucket}")
        response = s3_client.get_object(Bucket=bucket, Key=key)
        csv_content = response['Body'].read().decode('utf-8')
        
        # Parse CSV
        csv_reader = csv.DictReader(io.StringIO(csv_content))
        rows = list(csv_reader)
        
        if not rows:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'CSV file is empty'})
            }
        
        # Get database connection
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Use provided columns or infer from CSV header
        if not columns:
            columns = list(rows[0].keys())
        
        logger.info(f"Uploading {len(rows)} rows to {table_name}")
        
        # Insert rows into database
        inserted_count = 0
        for row in rows:
            placeholders = ','.join(['?' for _ in columns])
            insert_sql = f"INSERT INTO {table_name} ({','.join(columns)}) VALUES ({placeholders})"
            values = [row.get(col) for col in columns]
            
            try:
                cursor.execute(insert_sql, values)
                inserted_count += 1
            except Exception as e:
                logger.error(f"Error inserting row: {e}, row: {row}")
                continue
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully uploaded {inserted_count} rows to {table_name}',
                'rows_processed': len(rows),
                'rows_inserted': inserted_count
            })
        }
        
    except Exception as e:
        logger.exception(f"Error uploading data: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Failed to upload data: {str(e)}'})
        }
