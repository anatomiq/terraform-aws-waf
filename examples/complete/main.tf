module "waf" {
  source = "../../"

  name                   = var.name
  scope                  = "REGIONAL"
  enable_waf_association = true
  associate_resource_arn = "arn:aws:elasticloadbalancing:us-east-1:111122223333:loadbalancer/app/lb"
  managed_rules = [
    { "name" : "AWSManagedRulesAmazonIpReputationList", "override_action" : "none", "priority" : 1, "vendor_name" : "AWS", "rule_action_override" : [] },
    { "name" : "AWSManagedRulesCommonRuleSet", "override_action" : "none", "priority" : 2, "vendor_name" : "AWS", "rule_action_override" : [{ "name" = "SizeRestrictions_BODY", "action_to_use" = "allow" }] },
    { "name" : "AWSManagedRulesSQLiRuleSet", "override_action" : "none", "priority" : 3, "vendor_name" : "AWS", "rule_action_override" : [] }
  ]
  enable_custom_block_response = true
  custom_block_response_content = {
    "403" = "Your request has been blocked. Please contact the system administrators"
  }
  filtered_header_rule = {
    priority     = 1
    action       = "allow"
    header_value = "host"
    header_types = [
      "test1",
      "test2"
    ]
  }
  ip_sets_rule = [
    {
      name                              = "block-ips"
      priority                          = 6
      action                            = "block"
      ip_set_arn                        = aws_wafv2_ip_set.ips.arn
      enable_block_custom_response      = true
      response_code                     = 403
      block_custom_response_content_key = "403"
      enable_block_custom_headers       = false
    }
  ]
  ip_rate_based_rule = {
    name : "ip-rate-limit",
    priority : 7,
    action : "count",
    limit : 100
  }
  ip_rate_url_based_rules = [
    {
      name : "ip-rate-limit",
      priority : 8,
      action : "block",
      limit : 100,
      search_string : "/foo/",
      positional_constraint : "STARTS_WITH"
    }
  ]
  rule_groups = [
    {
      name : aws_wafv2_rule_group.block_countries.name,
      arn : aws_wafv2_rule_group.block_countries.arn,
      override_action : "none",
      priority : 11
    }
  ]

  logging_redacted_fields = [
    { type = "single_header", name = "Authorization" },
    { type = "single_header", name = "Cookie" }
  ]

  logging_filter = {
    default_behavior = "DROP"
    filters = [
      {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        conditions = [
          { action = "BLOCK" }
        ]
      }
    ]
  }

  tags = var.tags
}

resource "aws_wafv2_ip_set" "ips" {
  name               = "${var.name}-ip-set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = [
    "192.0.0.1/32"
  ]
}

resource "aws_wafv2_rule_group" "block_countries" {
  name     = "${var.name}-rule-group"
  scope    = "REGIONAL"
  capacity = 1
  rule {
    name     = "block-rule-1"
    priority = 1
    action {
      block {}
    }
    statement {
      geo_match_statement {
        country_codes = ["RU"]
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rule-metric-name"
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "metric-name"
    sampled_requests_enabled   = false
  }
}
