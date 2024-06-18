locals {
  prefix = "${var.project_name}_${var.project_env}"
}

resource "aws_wafv2_web_acl" "this" {
  name        = "${local.prefix}_web_acl"
  description = "WAFv2 ACL for ${local.prefix}"

  scope = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = local.prefix
  }

  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
          version     = rule.value.version
          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_override
            content {
              name = rule_action_override.value["name"]
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value["action_to_use"] == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value["action_to_use"] == "block" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value["action_to_use"] == "count" ? [1] : []
                  content {}
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = merge({
    Name = "${local.prefix}_web_acl"
  }, var.tags)
}

resource "aws_wafv2_web_acl_association" "main" {
  count = length(var.associate_alb)

  resource_arn = var.associate_alb[count.index]
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = length(var.log_arn) > 0 ? 1 : 0

  log_destination_configs = [var.log_arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}
