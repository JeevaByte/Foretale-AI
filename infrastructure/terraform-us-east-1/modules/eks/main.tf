################################################################################
# EKS Module - Kubernetes Cluster for Container Workloads
# Provides managed Kubernetes control plane and worker node groups
################################################################################

locals {
  name_prefix = "foretale-app-eks"
}

################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "main" {
  name     = "foretale-app-eks-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  # Enable control plane logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-cluster"
    }
  )
}

################################################################################
# EKS Cluster IAM Role
################################################################################

resource "aws_iam_role" "cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

################################################################################
# EKS Node Group IAM Role
################################################################################

resource "aws_iam_role" "node_group" {
  name = "${local.name_prefix}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-node-group-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# CloudWatch Logs access for monitoring
resource "aws_iam_role_policy_attachment" "node_CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node_group.name
}

################################################################################
# EKS Security Group
################################################################################

resource "aws_security_group" "cluster" {
  name_prefix = "${local.name_prefix}-eks-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-cluster-sg"
    }
  )
}

# Allow worker nodes to communicate with cluster
resource "aws_security_group_rule" "cluster_ingress_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node_group.id
}

# Allow egress to worker nodes
resource "aws_security_group_rule" "cluster_egress_nodes" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node_group.id
}

################################################################################
# EKS Node Group Security Group
################################################################################

resource "aws_security_group" "node_group" {
  name_prefix = "${local.name_prefix}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-nodes-sg"
    }
  )
}

# Allow worker nodes to communicate with cluster
resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_group.id
  source_security_group_id = aws_security_group.cluster.id
}

# Allow worker nodes to communicate with each other
resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.node_group.id
  self              = true
}

# Allow RDS access for database operations
resource "aws_security_group_rule" "node_ingress_rds" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_security_group.node_group.id
}

# Allow egress for all traffic
resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# EKS Node Group
################################################################################

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
}

################################################################################
# OIDC Provider for IAM Roles for Service Accounts (IRSA)
################################################################################

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-oidc-provider"
    }
  )
}

################################################################################
# CloudWatch Log Group for EKS Cluster Logs
################################################################################

# Get or create CloudWatch log group for EKS
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${aws_eks_cluster.main.name}/cluster"
  retention_in_days = 30
  skip_destroy      = false

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-eks-logs"
    }
  )
}

################################################################################
# IAM Role for EKS Service Accounts (Example: Pod execution)
################################################################################

resource "aws_iam_role" "pod_execution" {
  name = "${local.name_prefix}-eks-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" = [
              "system:serviceaccount:default:default",
              "system:serviceaccount:kube-system:aws-node",
              "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            ]
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-pod-execution-role"
    }
  )
}

# Attach policies for pod to access RDS and Secrets Manager
resource "aws_iam_role_policy" "pod_rds_access" {
  name = "${local.name_prefix}-pod-rds-access"
  role = aws_iam_role.pod_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
