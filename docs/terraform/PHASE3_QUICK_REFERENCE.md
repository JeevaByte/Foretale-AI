# Phase 3 Quick Reference Guide

## Command Cheat Sheet

### Terraform Commands
```bash
# Navigate to terraform directory
cd terraform/

# Initialize (already done)
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=phase3.tfplan

# Show plan
terraform show phase3.tfplan

# Apply changes
terraform apply phase3.tfplan

# Get outputs
terraform output -json > outputs.json
terraform output api_gateway_invoke_url

# Destroy Phase 3 only
terraform destroy -target=module.api_gateway -target=module.lambda -target=module.eks
```

### AWS CLI Commands
```bash
# Get Lambda function info
aws lambda get-function --function-name foretale-dev-read-record --region us-east-2

# Invoke Lambda test
aws lambda invoke \
  --function-name foretale-dev-read-record \
  --payload '{"test": true}' \
  response.json \
  --region us-east-2

# Get EKS cluster info
aws eks describe-cluster --name foretale-dev-eks-cluster --region us-east-2

# Get API Gateway info
aws apigateway get-rest-apis --region us-east-2 | grep -i foretale

# Check RDS connectivity
aws ec2 describe-security-groups --group-ids sg-xxx --region us-east-2
```

### Kubernetes Commands
```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --name foretale-dev-eks-cluster \
  --region us-east-2

# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# Apply manifests
kubectl apply -f kubernetes/

# Check deployment status
kubectl get deployments
kubectl describe deployment csv-processor-deployment
kubectl logs -f deployment/csv-processor-deployment

# Port forward to service
kubectl port-forward svc/csv-processor-svc 8000:8000

# Access pod shell
kubectl exec -it <pod-name> -- /bin/bash
```

---

## Key Endpoints

### API Gateway
- **Base URL**: `https://{api-id}.execute-api.us-east-2.amazonaws.com/dev`
- **Insert**: `POST /insert_record`
- **Update**: `PUT /update_record`
- **Delete**: `DELETE /delete_record`
- **Read**: `GET /read_record?id={id}`
- **Read JSON**: `GET /read_json_record?id={id}`
- **ECS Invoker**: `POST /ecs_invoker_resource`

### Lambda Functions
- `foretale-dev-insert-record`
- `foretale-dev-update-record`
- `foretale-dev-delete-record`
- `foretale-dev-read-record`
- `foretale-dev-read-json-record`
- `foretale-dev-ecs-invoker`

### EKS Resources
- **Cluster Name**: `foretale-dev-eks-cluster`
- **Node Group**: `foretale-dev-node-group`
- **Kubernetes Version**: 1.29
- **Nodes**: t3.medium (2 desired, 1-4 autoscaling)

### Kubernetes Services
- `csv-processor-svc` (Port 8000)
- `test-executor-svc` (Port 8001)

---

## Environment Variables

### Lambda Functions
```
RDS_ENDPOINT          = foretale-dev-postgres.xxx.us-east-2.rds.amazonaws.com
RDS_PORT              = 5432
RDS_DATABASE          = foretaledb
RDS_USER              = foretaleadmin
SECRETS_MANAGER_SECRET = foretale-dev-db-credentials
AWS_REGION            = us-east-2
```

### EKS Pods (from ConfigMap)
```
RDS_ENDPOINT = foretale-dev-postgres.xxx.us-east-2.rds.amazonaws.com
RDS_PORT = 5432
RDS_DATABASE = foretaledb
RDS_USER = foretaleadmin
AWS_REGION = us-east-2
ENVIRONMENT = dev
LOG_LEVEL = INFO
S3_UPLOADS_BUCKET = foretale-dev-user-uploads
S3_BACKUPS_BUCKET = foretale-dev-backups
S3_ANALYTICS_BUCKET = foretale-dev-analytics
S3_STORAGE_BUCKET = foretale-dev-app-storage
DYNAMODB_SESSIONS_TABLE = foretale-dev-sessions
DYNAMODB_CACHE_TABLE = foretale-dev-cache
DYNAMODB_AUDIT_LOGS_TABLE = foretale-dev-audit-logs
DYNAMODB_AI_STATE_TABLE = foretale-dev-ai-state
DYNAMODB_WEBSOCKET_TABLE = foretale-dev-websocket-connections
```

---

## Troubleshooting Quick Fixes

### Lambda Issues
```bash
# Check logs
aws logs tail /aws/lambda/foretale-dev --follow

# Test invocation
aws lambda invoke \
  --function-name foretale-dev-read-record \
  --payload '{"test":true}' \
  response.json

# Check VPC config
aws lambda get-function-configuration \
  --function-name foretale-dev-read-record | grep Vpc
```

### API Gateway Issues
```bash
# Test endpoint
curl -X GET https://API_ID.execute-api.us-east-2.amazonaws.com/dev/read_record

# Check authorizer
aws apigateway get-authorizers --rest-api-id API_ID

# View API logs
aws logs tail /aws/api-gateway/foretale-dev --follow
```

### EKS Issues
```bash
# Check node status
kubectl get nodes
kubectl describe nodes

# Check pod status
kubectl get pods -A
kubectl describe pod POD_NAME -n NAMESPACE

# Check logs
kubectl logs POD_NAME -n NAMESPACE
kubectl logs -f deployment/csv-processor-deployment

# Scale deployment
kubectl scale deployment csv-processor-deployment --replicas=3

# Restart deployment
kubectl rollout restart deployment/csv-processor-deployment
```

---

## Cost Optimization Tips

1. **Scale Down EKS Nodes**: Reduce `eks_desired_size` from 2 to 1 for non-production
   ```bash
   terraform apply -var="eks_desired_size=1"
   ```

2. **Lambda Memory Optimization**: Reduce memory if CPU usage is low
   ```bash
   # Monitor Lambda duration and adjust accordingly
   aws cloudwatch get-metric-statistics \
     --namespace AWS/Lambda \
     --metric-name Duration
   ```

3. **API Gateway Caching**: Enable caching for frequently accessed endpoints
   ```bash
   # Add cache settings in API Gateway stage
   aws apigateway update-stage --rest-api-id API_ID --stage-name dev \
     --patch-operations op=replace,path=/*/*/caching/enabled,value=true
   ```

4. **RDS Connection Pooling**: Use RDS Proxy to reduce connection overhead
   - Planned for Phase 3.1

5. **Scheduled Scaling**: Scale down nodes during non-business hours
   - Requires KEDA or Kubernetes Scheduler setup

---

## Security Checklist

- [ ] Cognito User Pool ARN updated in terraform.tfvars
- [ ] RDS security group allows Lambda SG ingress
- [ ] RDS security group allows EKS node SG ingress
- [ ] Lambda execution role has Secrets Manager permissions
- [ ] EKS OIDC provider configured for IRSA
- [ ] NetworkPolicy restricts pod-to-pod communication
- [ ] CloudWatch logging enabled for API Gateway, Lambda, EKS
- [ ] API Gateway has Cognito authorizer
- [ ] Database credentials stored in Secrets Manager (not in ConfigMap)
- [ ] VPC endpoints configured for AWS services (optional, cost savings)

---

## File Locations

| Component | Location | Purpose |
|-----------|----------|---------|
| API Gateway Module | `terraform/modules/api-gateway/` | REST API configuration |
| Lambda Module | `terraform/modules/lambda/` | Serverless functions |
| EKS Module | `terraform/modules/eks/` | Kubernetes cluster |
| Kubernetes ConfigMap | `kubernetes/01-configmap.yaml` | App configuration |
| Kubernetes Secrets | `kubernetes/02-secret-and-serviceaccount.yaml` | DB credentials & IRSA |
| CSV Processor | `kubernetes/03-csv-processor-deployment.yaml` | CSV processing workload |
| Test Executor | `kubernetes/04-test-executor-deployment.yaml` | Test execution workload |
| Ingress & Policy | `kubernetes/05-ingress-and-network-policy.yaml` | Routing & security |
| Main Terraform | `terraform/main.tf` | Module instantiation |
| Variables | `terraform/variables.tf` | Input variables |
| Outputs | `terraform/outputs.tf` | Output values |
| Terraform Values | `terraform/terraform.tfvars` | Variable values |

---

## Useful Links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [API Gateway Console](https://console.aws.amazon.com/apigateway/)
- [EKS Console](https://console.aws.amazon.com/eks/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)

---

## Support

For issues or questions:
1. Check CloudWatch logs for error details
2. Review Kubernetes pod logs with `kubectl logs`
3. Validate Terraform configuration with `terraform validate`
4. Check AWS service quotas and limits
5. Review PHASE3_DEPLOYMENT_SUMMARY.md for detailed troubleshooting

---

**Last Updated**: 2025-01-20
**Phase 3 Version**: 3.0
