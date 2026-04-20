# Prowler Security Scan Report

- Date (UTC): 2026-04-20
- Tool: Prowler 5.24.0
- AWS Account: 442426872653
- Principal: arn:aws:iam::442426872653:user/admin-jeeva
- Regions scanned: us-east-1, us-east-2

## Scan Command

```bash
prowler aws \
  --region us-east-1 us-east-2 \
  --output-formats csv html json-ocsf \
  --output-directory docs/reports/prowler-output \
  --output-filename prowler-aws-20260420-090604 \
  --ignore-exit-code-3 \
  --no-color
```

## Output Artifacts

- HTML report: docs/reports/prowler-output/prowler-aws-20260420-090604.html
- CSV findings: docs/reports/prowler-output/prowler-aws-20260420-090604.csv
- JSON OCSF findings: docs/reports/prowler-output/prowler-aws-20260420-090604.ocsf.json
- Compliance CSVs: docs/reports/prowler-output/compliance/

## Findings Summary

From the generated CSV:

- Total evaluated rows: 75,508
- PASS: 1,644
- FAIL: 701
- MANUAL: 4
- MUTED: 0

Failed findings by severity:

- Critical: 9
- High: 129
- Medium: 412
- Low: 148

Top services by failed findings:

1. cloudwatch: 129
2. s3: 128
3. awslambda: 58
4. iam: 49
5. ecr: 49
6. ecs: 40
7. dynamodb: 38
8. apigateway: 35
9. rds: 29
10. secretsmanager: 27
11. vpc: 19
12. ec2: 17

Most frequent failed checks:

1. cloudwatch_log_group_kms_encryption_enabled (60)
2. cloudwatch_log_group_retention_policy_specific_days_enabled (37)
3. ecr_repositories_tag_immutability (19)
4. ecr_repositories_lifecycle_policy_enabled (19)
5. cloudwatch_alarm_actions_alarm_state_configured (19)
6. awslambda_function_no_dead_letter_queue (18)
7. awslambda_function_invoke_api_operations_cloudtrail_logging_enabled (18)
8. iam_role_cross_service_confused_deputy_prevention (16)
9. ecs_task_definitions_containers_readonly_access (16)
10. s3_bucket_server_access_logging_enabled (15)
11. s3_bucket_object_lock (15)
12. s3_bucket_no_mfa_delete (15)

## Compliance Snapshot

Selected framework status from Prowler output:

- AWS Foundational Security Best Practices: 38.42% FAIL (297), 61.58% PASS (476)
- AWS Well-Architected Security Pillar: 28.97% FAIL (339), 71.03% PASS (831)
- CIS 5.0 AWS: 29.38% FAIL (62), 70.62% PASS (149)
- PCI 4.0 AWS: 47.70% FAIL (394), 52.30% PASS (432)

## Notes

- Path docs/reports/prowler exists as an empty file, so scan output was saved to docs/reports/prowler-output.
- Some findings are expected for intentionally disabled services or non-applicable controls; review HTML and compliance CSVs for resource-level context before remediation.
