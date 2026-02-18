################################################################################
# Kubernetes Deployment Guide for ForeTale Application
################################################################################

## Overview
This directory contains Kubernetes manifests for deploying ForeTale application components to AWS EKS.

## Prerequisites

1. **EKS Cluster**: Provisioned via Terraform (terraform/modules/eks/)
2. **kubectl**: Installed and configured
3. **AWS CLI**: For ECR access and credential management
4. **Container Images**: Built and pushed to Amazon ECR

```bash
# Configure kubectl to connect to EKS cluster
aws eks update-kubeconfig --region us-east-2 --name foretale-dev-eks-cluster

# Verify connection
kubectl cluster-info
kubectl get nodes
```

## Manifest Files

| File | Purpose |
|------|---------|
| `01-configmap.yaml` | Application configuration (RDS, S3, DynamoDB endpoints) |
| `02-secret-and-serviceaccount.yaml` | Database credentials and IRSA service account |
| `03-csv-processor-deployment.yaml` | CSV data upload processor with 2 replicas |
| `04-test-executor-deployment.yaml` | Test execution service with 2 replicas |
| `05-ingress-and-network-policy.yaml` | Ingress routing and network policies |

## Deployment Steps

### Step 1: Update Configuration
Before deploying, update the following:

**ConfigMap** (`01-configmap.yaml`):
```bash
# Get RDS endpoint from terraform output
RDS_ENDPOINT: "$(terraform output rds_endpoint)"

# Get S3 bucket names
S3_BUCKET_BACKUPS: "foretale-dev-backups"
S3_BUCKET_USER_UPLOADS: "foretale-dev-user-uploads"
```

**Secret** (`02-secret-and-serviceaccount.yaml`):
```bash
# Get database password from Secrets Manager
aws secretsmanager get-secret-value --secret-id foretale-dev-db-credentials --query SecretString
```

**ServiceAccount** (`02-secret-and-serviceaccount.yaml`):
```bash
# Replace ACCOUNT_ID with your AWS account ID
eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT_ID:role/foretale-dev-eks-pod-execution-role"

# Get actual role ARN from terraform output
terraform output pod_execution_role_arn
```

**Deployments** (`03-csv-processor-deployment.yaml`, `04-test-executor-deployment.yaml`):
```bash
# Update container image URIs
image: ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/foretale-csv-processor:latest
image: ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/foretale-test-executor:latest
```

### Step 2: Apply Manifests

```bash
# Create namespace (if needed)
kubectl create namespace default

# Apply all manifests in order
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-secret-and-serviceaccount.yaml
kubectl apply -f 03-csv-processor-deployment.yaml
kubectl apply -f 04-test-executor-deployment.yaml
kubectl apply -f 05-ingress-and-network-policy.yaml

# Or apply all at once
kubectl apply -f .
```

### Step 3: Verify Deployment

```bash
# Check deployments
kubectl get deployments
kubectl describe deployment foretale-csv-processor
kubectl describe deployment foretale-test-executor

# Check pods
kubectl get pods
kubectl describe pod <pod-name>

# Check services
kubectl get services
kubectl describe service foretale-csv-processor-svc

# View logs
kubectl logs -f deployment/foretale-csv-processor
kubectl logs -f deployment/foretale-test-executor
```

## Accessing Services

### Internal Access (from within cluster)
```bash
# CSV Processor
curl http://foretale-csv-processor-svc:80/health

# Test Executor
curl http://foretale-test-executor-svc:80/health
```

### External Access
Use API Gateway endpoints from Phase 3 deployment (managed via Terraform).

## Configuration Management

### Update ConfigMap
```bash
# Edit ConfigMap
kubectl edit configmap foretale-app-config

# Or apply updated YAML
kubectl apply -f 01-configmap.yaml

# Restart pods to pick up changes
kubectl rollout restart deployment/foretale-csv-processor
kubectl rollout restart deployment/foretale-test-executor
```

### Update Secret
```bash
# Delete old secret
kubectl delete secret foretale-db-secret

# Create new secret from file
kubectl create secret generic foretale-db-secret \
  --from-literal=DB_USER=foretaleadmin \
  --from-literal=DB_PASSWORD=<password> \
  --from-literal=DB_CONNECTION_STRING='postgresql://foretaleadmin:<password>@<rds-endpoint>:5432/foretaledb'

# Restart pods
kubectl rollout restart deployment/foretale-csv-processor
kubectl rollout restart deployment/foretale-test-executor
```

## Database Connectivity

### RDS Access
Pods authenticate to RDS using:
1. Endpoint: Injected via ConfigMap (RDS_ENDPOINT)
2. Credentials: From Secret (DB_PASSWORD)
3. VPC: EKS nodes in same VPC as RDS
4. Security Groups: RDS security group allows traffic from EKS node security group (configured in Terraform)

### Verify RDS Connectivity
```bash
# Access pod shell
kubectl exec -it <pod-name> -- /bin/bash

# Test PostgreSQL connection
psql -h foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com \
     -U foretaleadmin \
     -d foretaledb

# Query database
SELECT version();
```

## Scaling

### Manual Scaling
```bash
# Scale CSV processor
kubectl scale deployment foretale-csv-processor --replicas=3

# Scale test executor
kubectl scale deployment foretale-test-executor --replicas=4
```

### Auto-Scaling with HPA
Create `hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: foretale-csv-processor-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: foretale-csv-processor
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply HPA:
```bash
kubectl apply -f hpa.yaml
```

## Monitoring

### Pod Status
```bash
# Get pod events
kubectl describe pod <pod-name>

# Check resource usage
kubectl top nodes
kubectl top pods
```

### Logs
```bash
# Stream logs from pod
kubectl logs -f <pod-name>

# Get logs from deployment
kubectl logs -f deployment/foretale-csv-processor

# Get previous pod logs (if crashed)
kubectl logs <pod-name> --previous
```

### CloudWatch Integration
EKS cluster logs are automatically sent to CloudWatch log group: `/aws/eks/foretale-dev-eks-cluster/cluster`

View logs:
```bash
aws logs tail /aws/eks/foretale-dev-eks-cluster/cluster --follow
```

## Cleanup

### Delete Deployment
```bash
# Delete specific deployment
kubectl delete deployment foretale-csv-processor
kubectl delete deployment foretale-test-executor

# Delete all resources
kubectl delete -f .

# Delete ConfigMap and Secrets
kubectl delete configmap foretale-app-config
kubectl delete secret foretale-db-secret
```

### Scale Down Node Group
```bash
# Edit node group in AWS Console or via AWS CLI
aws eks update-nodegroup-config \
  --cluster-name foretale-dev-eks-cluster \
  --nodegroup-name foretale-dev-node-group \
  --scaling-config minSize=0,desiredSize=0,maxSize=0
```

## Troubleshooting

### Pod Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check node capacity
kubectl describe node <node-name>
```

### Database Connection Issues
```bash
# Verify RDS security group allows EKS node traffic
aws ec2 describe-security-groups --group-ids <rds-sg-id>

# Check pod can reach RDS
kubectl exec -it <pod-name> -- nc -zv foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com 5432
```

### Image Pull Errors
```bash
# Verify ECR credentials configured in EKS cluster
kubectl get secret -n default

# Create ECR pull secret if needed
kubectl create secret docker-registry ecr-registry \
  --docker-server=ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-2)

# Reference in pod spec:
# imagePullSecrets:
# - name: ecr-registry
```

## Best Practices

1. **Resource Limits**: Always set resource requests and limits
2. **Health Checks**: Implement liveness and readiness probes
3. **Secrets Management**: Use AWS Secrets Manager for sensitive data
4. **Network Policies**: Restrict inter-pod traffic
5. **Logging**: Ship logs to CloudWatch or centralized logging
6. **Monitoring**: Use CloudWatch Container Insights or Prometheus
7. **Security**: Use Pod Security Policies and RBAC
8. **Updates**: Use rolling deployments for zero-downtime updates

## References

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
