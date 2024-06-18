locals {
  prefix = "${var.project_name}_${var.project_env}"

  use_default_acm_certificate = var.acm_certificate_arn == ""
  minimum_protocol_version    = local.use_default_acm_certificate ? "TLSv1" : "TLSv1.2_2021"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = var.s3_bucket_dns_name
    origin_id   = var.s3_bucket_dns_name
    s3_origin_config {
      origin_access_identity = var.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.alb_dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Frontend CDN"
  default_root_object = "index.html"

  # Alter domain name
  aliases = var.acm_certificate_arn != "" ? [var.alter_domain_name] : []

  # CloudFront distributions take about 15 minutes to reach a deployed state after creation or modification. 
  # During this time, deletes to resources will be blocked. 
  # If you need to delete a distribution that is enabled and you do not want to wait, 
  # you need to use the retain_on_delete flag
  retain_on_delete = true

  default_cache_behavior {
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = var.s3_bucket_dns_name
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = var.alb_dns_name

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "cable"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = var.alb_dns_name

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "sidekiq/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = var.alb_dns_name

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = 200
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = 200
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = local.use_default_acm_certificate ? null : "sni-only"
    minimum_protocol_version       = local.minimum_protocol_version
    cloudfront_default_certificate = local.use_default_acm_certificate
  }

  tags = merge({
    Name = "${local.prefix}_frontend"
  }, var.tags)
}
