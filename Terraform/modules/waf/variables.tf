variable "project_name" {}

variable "project_env" {}

variable "tags" {}

variable "scope" {
  type        = string
  description = "The scope of this Web ACL. Valid options: CLOUDFRONT, REGIONAL."
}

variable "default_action" {
  type        = string
  description = "The action to perform if none of the rules contained in the WebACL match."
  default     = "allow"
}

variable "managed_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    vendor_name     = string
    version         = optional(string)
    rule_action_override = list(object({
      name          = string
      action_to_use = string
    }))
  }))
  description = "List of Managed WAF rules."
  default = [
    {
      name                 = "AWSManagedRulesAmazonIpReputationList",
      priority             = 10
      override_action      = "none"
      vendor_name          = "AWS"
      rule_action_override = []
    },
    {
      name                 = "AWSManagedRulesCommonRuleSet",
      priority             = 20
      override_action      = "none"
      vendor_name          = "AWS"
      rule_action_override = []
    },
    {
      name                 = "AWSManagedRulesKnownBadInputsRuleSet",
      priority             = 30
      override_action      = "none"
      vendor_name          = "AWS"
      rule_action_override = []
    },
    {
      name                 = "AWSManagedRulesSQLiRuleSet",
      priority             = 40
      override_action      = "none"
      vendor_name          = "AWS"
      rule_action_override = []
    }
  ]
}

variable "associate_alb" {
  type        = list(string)
  description = "Whether to associate an ALB with the WAFv2 ACL."
}

variable "log_arn" {
  type        = string
  description = "The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
  default     = ""
}
