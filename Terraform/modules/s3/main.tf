locals {
  prefix           = "${var.project_name}_${var.project_env}"
  sns_trigger_name = "${local.prefix}_s3-event-notification-topic"
}

# Create S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_origin_id
  # A boolean that indicates all objects (including any locked objects) 
  # should be deleted from the bucket so that the bucket can be destroyed without error. 
  # These objects are not recoverable
  force_destroy = false

  tags = merge({
    Name = replace(var.s3_origin_id, "-", "_")
  }, var.tags)
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  count = length(var.object_ownership) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

# SNS trigger
data "aws_iam_policy_document" "sns_topic" {
  count = var.enable_trigger ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${local.sns_trigger_name}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}

resource "aws_sns_topic" "sns_topic" {
  count = var.enable_trigger ? 1 : 0

  name   = local.sns_trigger_name
  policy = data.aws_iam_policy_document.sns_topic.0.json

  tags = merge({
    Name = replace(local.sns_trigger_name, "-", "_")
  }, var.tags)
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.enable_trigger ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.sns_topic.0.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
