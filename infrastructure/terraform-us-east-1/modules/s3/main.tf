################################################################################
# S3 Buckets for ForeTale Application
# NOTE: All S3 buckets have been deleted and commented out
################################################################################

locals {
  bucket_prefix = "foretale-app-s3"
}

################################################################################
# Application Storage Bucket - DISABLED (vector bucket only)
################################################################################

# resource "aws_s3_bucket" "app_storage" {
#   bucket = "${local.bucket_prefix}-app-storage"
#
#   tags = merge(
#     var.tags,
#     {
#       Name        = "${local.bucket_prefix}-app-storage"
#       Purpose     = "Application file storage"
#       Environment = var.environment
#     }
#   )
# }
#
# resource "aws_s3_bucket_versioning" "app_storage" {
#   bucket = aws_s3_bucket.app_storage.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
#   bucket = aws_s3_bucket.app_storage.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "app_storage" {
#   bucket = aws_s3_bucket.app_storage.id
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "app_storage" {
#   bucket = aws_s3_bucket.app_storage.id
#
#   rule {
#     id     = "transition-to-ia"
#     status = "Enabled"
#
#     filter {}
#
#     transition {
#       days          = 90
#       storage_class = "STANDARD_IA"
#     }
#   }
#
#   rule {
#     id     = "cleanup-old-versions"
#     status = "Enabled"
#
#     filter {}
#
#     noncurrent_version_expiration {
#       noncurrent_days = 30
#     }
#   }
# }

################################################################################
# User Uploads Bucket - DISABLED (vector bucket only)
################################################################################

# resource "aws_s3_bucket" "user_uploads" {
#   bucket = "${local.bucket_prefix}-user-uploads"
#
#   tags = merge(
#     var.tags,
#     {
#       Name        = "${local.bucket_prefix}-user-uploads"
#       Purpose     = "User file uploads"
#       Environment = var.environment
#     }
#   )
# }
#
# resource "aws_s3_bucket_versioning" "user_uploads" {
#   bucket = aws_s3_bucket.user_uploads.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "user_uploads" {
#   bucket = aws_s3_bucket.user_uploads.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "user_uploads" {
#   bucket = aws_s3_bucket.user_uploads.id
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
#
# resource "aws_s3_bucket_cors_configuration" "user_uploads" {
#   bucket = aws_s3_bucket.user_uploads.id
#
#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
#     allowed_origins = var.cors_allowed_origins
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "user_uploads" {
#   bucket = aws_s3_bucket.user_uploads.id
#
#   rule {
#     id     = "transition-to-ia"
#     status = "Enabled"
#
#     filter {}
#
#     transition {
#       days          = 60
#       storage_class = "STANDARD_IA"
#     }
#
#     transition {
#       days          = 180
#       storage_class = "GLACIER_IR"
#     }
#   }
#
#   rule {
#     id     = "cleanup-incomplete-uploads"
#     status = "Enabled"
#
#     filter {}
#
#     abort_incomplete_multipart_upload {
#       days_after_initiation = 7
#     }
#   }
# }

################################################################################
# Analytics/Reports Bucket - DISABLED
################################################################################

# resource "aws_s3_bucket" "analytics" {
#   bucket = "${local.bucket_prefix}-analytics"
# 
#   tags = merge(
#     var.tags,
#     {
#       Name        = "${local.bucket_prefix}-analytics"
#       Purpose     = "Analytics and reports storage"
#       Environment = var.environment
#     }
#   )
# }
# 
# resource "aws_s3_bucket_versioning" "analytics" {
#   bucket = aws_s3_bucket.analytics.id
# 
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# 
# resource "aws_s3_bucket_server_side_encryption_configuration" "analytics" {
#   bucket = aws_s3_bucket.analytics.id
# 
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# 
# resource "aws_s3_bucket_public_access_block" "analytics" {
#   bucket = aws_s3_bucket.analytics.id
# 
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
# 
# resource "aws_s3_bucket_lifecycle_configuration" "analytics" {
#   bucket = aws_s3_bucket.analytics.id
# 
#   rule {
#     id     = "archive-old-reports"
#     status = "Enabled"
# 
#     filter {}
# 
#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
# 
#     transition {
#       days          = 90
#       storage_class = "GLACIER_IR"
#     }
# 
#     expiration {
#       days = 365
#     }
#   }
# }

################################################################################
# Backups Bucket - DISABLED (vector bucket only)
################################################################################

# resource "aws_s3_bucket" "backups" {
#   bucket = "${local.bucket_prefix}-backups"
#
#   tags = merge(
#     var.tags,
#     {
#       Name        = "${local.bucket_prefix}-backups"
#       Purpose     = "Database and application backups"
#       Environment = var.environment
#     }
#   )
# }
#
# resource "aws_s3_bucket_versioning" "backups" {
#   bucket = aws_s3_bucket.backups.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
#   bucket = aws_s3_bucket.backups.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "backups" {
#   bucket = aws_s3_bucket.backups.id
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "backups" {
#   bucket = aws_s3_bucket.backups.id
#
#   rule {
#     id = "archive-backups"
#     filter {}
#
#     status = "Enabled"
#
#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
#
#     transition {
#       days          = 90
#       storage_class = "GLACIER_IR"
#     }
#
#     transition {
#       days          = 180
#       storage_class = "DEEP_ARCHIVE"
#     }
#
#     expiration {
#       days = 730 # 2 years retention
#     }
#   }
# }

################################################################################
# S3 Vector Bucket - us-east-2 - ENABLED
################################################################################

resource "aws_s3_bucket" "vector_bucket_us_east_2" {
  bucket = "${local.bucket_prefix}-vector-db-us-east-2"
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name        = "${local.bucket_prefix}-vector-db-us-east-2"
      Environment = var.environment
      Purpose     = "Vector Database Storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "vector_bucket_us_east_2" {
  bucket = aws_s3_bucket.vector_bucket_us_east_2.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vector_bucket_us_east_2" {
  bucket = aws_s3_bucket.vector_bucket_us_east_2.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
