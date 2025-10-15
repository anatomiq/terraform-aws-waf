#===============================================================
# AWS WAFv2 Web ACL
resource "aws_wafv2_web_acl" "default" {
  name        = var.name_prefix != null ? null : var.name
  name_prefix = var.name_prefix
  description = "WAF ACL for ${var.name}"
  scope       = var.scope

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
    metric_name                = var.name
  }

  #===============================================================
  # Managed Rule Groups
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
          version     = try(rule.value.version, null)

          dynamic "rule_action_override" {
            for_each = try(rule.value.rule_action_override, [])
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

  #===============================================================
  # IP Set Rules
  dynamic "rule" {
    for_each = var.ip_sets_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            dynamic "custom_response" {
              for_each = rule.value.enable_block_custom_response == true ? [1] : []
              content {
                custom_response_body_key = rule.value.block_custom_response_content_key
                response_code            = rule.value.response_code
                dynamic "response_header" {
                  for_each = rule.value.enable_block_custom_headers == true ? [1] : []
                  content {
                    name  = rule.value.response_header_name
                    value = rule.value.response_header_value
                  }
                }
              }
            }
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = rule.value.ip_set_arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  #===============================================================
  # Custom Block Response
  dynamic "custom_response_body" {
    for_each = var.enable_custom_block_response == true ? [1] : []
    content {
      content      = values(var.custom_block_response_content)[0]
      content_type = var.custom_block_response_content_type
      key          = keys(var.custom_block_response_content)[0]
    }
  }

  #===============================================================
  # Rate-Based Rule
  dynamic "rule" {
    for_each = var.ip_rate_based_rule != null ? [var.ip_rate_based_rule] : []
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            dynamic "custom_response" {
              for_each = rule.value.enable_block_custom_response == true ? [1] : []
              content {
                custom_response_body_key = rule.value.block_custom_response_content_key
                response_code            = rule.value.response_code
                dynamic "response_header" {
                  for_each = rule.value.enable_block_custom_headers == true ? [1] : []
                  content {
                    name  = rule.value.response_header_name
                    value = rule.value.response_header_value
                  }
                }
              }
            }
          }
        }
      }

      statement {
        rate_based_statement {
          limit              = rule.value.limit
          aggregate_key_type = try(rule.value.aggregate_key_type, "IP")

          dynamic "forwarded_ip_config" {
            for_each = rule.value.aggregate_key_type == "FORWARDED_IP" ? [1] : []
            content {
              header_name       = try(rule.value.forwarded_ip_header_name, "X-Forwarded-For")
              fallback_behavior = try(rule.value.fallback_behavior, "MATCH")
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

  #===============================================================
  # Rate + URL Based Rules
  dynamic "rule" {
    for_each = var.ip_rate_url_based_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            dynamic "custom_response" {
              for_each = rule.value.enable_block_custom_response == true ? [1] : []
              content {
                custom_response_body_key = rule.value.block_custom_response_content_key
                response_code            = rule.value.response_code
                dynamic "response_header" {
                  for_each = rule.value.enable_block_custom_headers == true ? [1] : []
                  content {
                    name  = rule.value.response_header_name
                    value = rule.value.response_header_value
                  }
                }
              }
            }
          }
        }
      }

      statement {
        rate_based_statement {
          limit              = rule.value.limit
          aggregate_key_type = try(rule.value.aggregate_key_type, "IP")

          scope_down_statement {
            byte_match_statement {
              positional_constraint = rule.value.positional_constraint
              search_string         = rule.value.search_string
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "URL_DECODE"
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

  #===============================================================
  # Filtered Header Rules
  dynamic "rule" {
    for_each = var.filtered_header_rule != null ? [
      for header_name in var.filtered_header_rule.header_types : {
        priority      = var.filtered_header_rule.priority + index(var.filtered_header_rule.header_types, header_name) + 1
        name          = header_name
        header_value  = var.filtered_header_rule.header_value
        action        = var.filtered_header_rule.action
        search_string = var.filtered_header_rule.search_string
      }
    ] : []
    content {
      name     = replace(rule.value.name, ".", "-")
      priority = rule.value.priority
      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }
      statement {
        byte_match_statement {
          field_to_match {
            single_header {
              name = rule.value.name
            }
          }
          positional_constraint = "EXACTLY"
          search_string         = rule.value.search_string != "" ? rule.value.search_string : rule.value.name
          text_transformation {
            priority = rule.value.priority
            type     = "COMPRESS_WHITE_SPACE"
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = replace(rule.value.name, ".", "-")
        sampled_requests_enabled   = true
      }
    }
  }

  #===============================================================
  # Rule Groups
  dynamic "rule" {
    for_each = var.rule_groups
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
        rule_group_reference_statement {
          arn = rule.value.arn
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = var.tags
}

#===============================================================
# WAF Association
resource "aws_wafv2_web_acl_association" "default" {
  count = var.enable_waf_association ? 1 : 0

  resource_arn = var.associate_resource_arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn

  depends_on = [aws_wafv2_web_acl.default]
}

#===============================================================
# Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "default" {
  count = var.enable_logging_configuration ? 1 : 0

  log_destination_configs = var.log_destination_arns
  resource_arn            = aws_wafv2_web_acl.default.arn

  dynamic "redacted_fields" {
    for_each = var.logging_redacted_fields
    content {
      dynamic "single_header" {
        for_each = length(lookup(redacted_fields.value, "single_header", {})) == 0 ? [] : [lookup(redacted_fields.value, "single_header", {})]
        content {
          name = lookup(single_header.value, "name", null)
        }
      }
    }
  }

  dynamic "logging_filter" {
    for_each = length(var.logging_filter) == 0 ? [] : [var.logging_filter]
    content {
      default_behavior = lookup(logging_filter.value, "default_behavior", "KEEP")

      dynamic "filter" {
        for_each = length(lookup(logging_filter.value, "filter", {})) == 0 ? [] : toset(lookup(logging_filter.value, "filter"))
        content {
          behavior    = lookup(filter.value, "behavior")
          requirement = lookup(filter.value, "requirement", "MEETS_ANY")

          dynamic "condition" {
            for_each = length(lookup(filter.value, "condition", {})) == 0 ? [] : toset(lookup(filter.value, "condition"))
            content {
              dynamic "action_condition" {
                for_each = length(lookup(condition.value, "action_condition", {})) == 0 ? [] : [lookup(condition.value, "action_condition", {})]
                content {
                  action = lookup(action_condition.value, "action")
                }
              }

              dynamic "label_name_condition" {
                for_each = length(lookup(condition.value, "label_name_condition", {})) == 0 ? [] : [lookup(condition.value, "label_name_condition", {})]
                content {
                  label_name = lookup(label_name_condition.value, "label_name")
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_wafv2_web_acl.default]
}
