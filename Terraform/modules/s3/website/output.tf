output "bucket" {
  value       = module.s3_base.bucket
  description = "S3 bucket"
}

output "bucket_access_block" {
  value       = aws_s3_bucket_public_access_block.access_block
  description = "Bucket access_block"
}
