resource "aws_wafv2_web_acl" "example_waf" {
  name        = "example-waf-acl"
  scope       = "REGIONAL"
  description = "An example AWS WAF Web ACL."

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        # Example of an excluded rule; uncomment and adjust as needed.
        # excluded_rule {
        #   name = "SizeRestrictions_BODY"
        # }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "exampleWebAclVisibilityConfig"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "example_association" {
  resource_arn = "arn:aws:eks:us-west-2:835708988591:cluster/EKS_cluster_capautomation"
  web_acl_arn  = aws_wafv2_web_acl.example_waf.arn
}

