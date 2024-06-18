# Create policy that allow access from cloudfront
data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    principals {
      type        = "AWS"
      identifiers = var.identifiers
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      var.s3_bucket.arn,
      "${var.s3_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = var.s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json

  depends_on = [ var.bucket_access_block ]
}
