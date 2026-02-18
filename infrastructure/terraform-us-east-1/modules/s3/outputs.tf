# Only vector bucket outputs enabled (us-east-2)

output "vector_bucket_us_east_2_id" {
  description = "Vector bucket ID in us-east-2"
  value       = aws_s3_bucket.vector_bucket_us_east_2.id
}

output "vector_bucket_us_east_2_arn" {
  description = "Vector bucket ARN in us-east-2"
  value       = aws_s3_bucket.vector_bucket_us_east_2.arn
}

