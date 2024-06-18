locals {
  prefix = "${var.project_name}_${var.project_env}"
}

module "s3_base" {
  source = "../"
  project_name = var.project_name
  project_env = var.project_env
  s3_origin_id = var.s3_origin_id
  tags = var.tags
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "enabled_versioning" {
  bucket = module.s3_base.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = module.s3_base.bucket.id

  block_public_policy     = false // This is default, so you can probably remove this line
  restrict_public_buckets = false // same as above
  block_public_acls       = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_website_configuration" "bucket_website_config" {
  bucket = module.s3_base.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
