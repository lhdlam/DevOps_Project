data "aws_caller_identity" "current" {}

locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}
resource "aws_iam_role" "iam_role" {
  name = "${title(var.project)}S3BackendRole"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ${jsonencode(local.principal_arns)}
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF

  tags = local.tags
}

data "aws_iam_policy_document" "policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.s3_bucket.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${title(var.project)}S3BackendPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.policy.arn
}
