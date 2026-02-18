#!/usr/bin/env python3
"""Migrate DynamoDB params table from ap-south-1 to us-east-2"""

import boto3
import json
import time
from datetime import datetime

# Initialize DynamoDB clients
dynamodb_source = boto3.resource('dynamodb', region_name='ap-south-1')
dynamodb_target = boto3.resource('dynamodb', region_name='us-east-2')

source_table = dynamodb_source.Table('params')
target_table = dynamodb_target.Table('foretale-app-dynamodb-params')

timestamp = int(time.time())

print("\n" + "="*50)
print("DynamoDB Params Table Migration")
print("Source: params (ap-south-1)")
print("Target: foretale-app-dynamodb-params (us-east-2)")
print("="*50 + "\n")

# Scan source table
print("[1/4] Scanning source table...")
response = source_table.scan()
items = response['Items']

print(f"✓ Found {len(items)} items to migrate\n")

# Prepare migration
print("[2/4] Preparing migration...")
success = 0
failed = 0
failed_items = []

# Migrate each item
print("[3/4] Migrating items...\n")

for item in items:
    pk = item['PK']
    group = item['GROUP']
    value = item['VALUE']
    
    try:
        # Prepare new item with transformation
        new_item = {
            'PK': pk,
            'SK': 'v1.0',
            'paramType': group.lower(),
            'createdAt': timestamp,
            'value': value,
            'migrated': True,
            'migratedFrom': 'ap-south-1',
            'originalGroup': group
        }
        
        # Put item to target table
        target_table.put_item(Item=new_item)
        success += 1
        
        if success % 10 == 0:
            print(f"  ✓ Migrated {success} / {len(items)} items...")
    
    except Exception as e:
        failed += 1
        failed_items.append(pk)
        print(f"  ✗ Failed: {pk} - {str(e)}")

# Summary
print(f"\n[4/4] Migration Summary:")
print(f"  Total items: {len(items)}")
print(f"  Successful: {success}")
print(f"  Failed: {failed}")

if failed > 0:
    print("\nFailed items:")
    for item in failed_items:
        print(f"  - {item}")

# Verify migration
print("\nVerifying migration...")
response = target_table.scan(Select='COUNT')
target_count = response['Count']

print(f"  Source: {len(items)} items")
print(f"  Target: {target_count} items")

if target_count == len(items):
    print("\n✅ Migration completed successfully!")
    exit(0)
else:
    print("\n⚠️ Migration incomplete. Please review failed items.")
    exit(1)
