output "bucket" {
  value       = aws_s3_bucket.bucket
  description = "S3 bucket"
}

output "sns_trigger" {
  value = aws_sns_topic.sns_topic
}
