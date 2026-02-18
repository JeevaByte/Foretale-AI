output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.app.arn
}

output "codecommit_repository_url" {
  description = "CodeCommit repository clone URL (HTTPS)"
  value       = aws_codecommit_repository.app_repo.clone_url_http
}

output "codecommit_repository_ssh_url" {
  description = "CodeCommit repository clone URL (SSH)"
  value       = aws_codecommit_repository.app_repo.clone_url_ssh
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.main.name
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.main.arn
}

output "codebuild_build_project_name" {
  description = "CodeBuild build project name"
  value       = aws_codebuild_project.build.name
}

output "codebuild_scan_project_name" {
  description = "CodeBuild security scan project name"
  value       = aws_codebuild_project.security_scan.name
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "pipeline_notification_topic_arn" {
  description = "SNS topic ARN for pipeline notifications"
  value       = aws_sns_topic.pipeline_notifications.arn
}
