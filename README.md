# Terraform AWS WAF

Configuration in this directory creates AWS WAF resources and supports the following
- AWS Managed Rule Sets
- Blocking IP Sets
- Global IP Rate limiting
- Custom IP rate limiting for different URLs
- Custom Response Bodies
- Optional custom headers in responses
- Optional header-based filtering rules
- Optional rule group references
- Optional log configuration and association
- Support for CloudWatch visibility per rule
- (Optional) rate limiting using FORWARDED_IP aggregation
- Customizable content types and custom response bodies

## Usage

To use this module, you need to include it in your Terraform configuration. You can do this by adding the following to your `main.tf` file:

```hcl
module "[module_name]" {
  source = [module_version]

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
      name       = var.name
      priority   = 5
      action     = "count"
      ip_set_arn = aws_wafv2_ip_set.basic.arn
    },
    {
      name                              = "block-all-ips"
      priority                          = 6
      action                            = "count"
      ip_set_arn                        = aws_wafv2_ip_set.block_all_ips.arn
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

  tags = var.tags
}
```

To run this example execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

To destroy this example execute:

```bash
$ terraform destroy
```

## Examples

- [Complete](https://github.com/anatomiq/terraform-aws-waf/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_resource_arn"></a> [associate\_resource\_arn](#input\_associate\_resource\_arn) | (Optional) ARN of the resource to be associated with the WAF ACL | `string` | `""` | no |
| <a name="input_custom_block_response_content"></a> [custom\_block\_response\_content](#input\_custom\_block\_response\_content) | (Optional) Map of custom block response bodies (key = response body name, value = body content) | `map(string)` | `{}` | no |
| <a name="input_custom_block_response_content_type"></a> [custom\_block\_response\_content\_type](#input\_custom\_block\_response\_content\_type) | (Required) Type of content in the payload that you are defining in the content argument. Valid values are TEXT\_PLAIN, TEXT\_HTML, or APPLICATION\_JSON | `string` | `"TEXT_PLAIN"` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | (Required) Action to perform if none of the rules contained in the WebACL match | `string` | `"allow"` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Friendly description of the WebACL | `string` | n/a | yes |
| <a name="input_enable_custom_block_response"></a> [enable\_custom\_block\_response](#input\_enable\_custom\_block\_response) | (Optional) This enables custom responses for the block requests | `bool` | `false` | no |
| <a name="input_enable_logging_configuration"></a> [enable\_logging\_configuration](#input\_enable\_logging\_configuration) | (Optional) Whether to enable logging configuration for the WAF | `bool` | `false` | no |
| <a name="input_enable_waf_association"></a> [enable\_waf\_association](#input\_enable\_waf\_association) | (Optional) Whether to enable WAF association | `bool` | `false` | no |
| <a name="input_filtered_header_rule"></a> [filtered\_header\_rule](#input\_filtered\_header\_rule) | (Optional) HTTP header to filter  Currently supports a single header type and multiple header values | <pre>object({<br/>    header_types  = list(string)<br/>    priority      = number<br/>    header_value  = string<br/>    action        = string<br/>    search_string = string<br/>  })</pre> | `null` | no |
| <a name="input_ip_rate_based_rule"></a> [ip\_rate\_based\_rule](#input\_ip\_rate\_based\_rule) | (Optional) A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>object({<br/>    name                              = string<br/>    priority                          = number<br/>    limit                             = number<br/>    action                            = string<br/>    response_code                     = optional(number, 403)<br/>    enable_block_custom_response      = optional(bool, false)<br/>    enable_block_custom_headers       = optional(bool, false)<br/>    block_custom_response_content_key = optional(string)<br/>    aggregate_key_type                = optional(string, "IP")<br/>    forwarded_ip_header_name          = optional(string, "X-Forwarded-For")<br/>    fallback_behavior                 = optional(string, "MATCH")<br/>  })</pre> | `null` | no |
| <a name="input_ip_rate_url_based_rules"></a> [ip\_rate\_url\_based\_rules](#input\_ip\_rate\_url\_based\_rules) | (Optional) A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>list(object({<br/>    name                              = string<br/>    priority                          = number<br/>    limit                             = number<br/>    action                            = string<br/>    response_code                     = optional(number, 403)<br/>    search_string                     = string<br/>    positional_constraint             = string<br/>    enable_block_custom_response      = optional(bool, false)<br/>    enable_block_custom_headers       = optional(bool, false)<br/>    block_custom_response_content_key = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_sets_rule"></a> [ip\_sets\_rule](#input\_ip\_sets\_rule) | (Optional) A rule to detect web requests coming from particular IP addresses or address ranges | <pre>list(object({<br/>    name                              = string<br/>    priority                          = number<br/>    ip_set_arn                        = string<br/>    action                            = string<br/>    response_code                     = optional(number, 403)<br/>    enable_block_custom_response      = optional(bool, false)<br/>    enable_block_custom_headers       = optional(bool, false)<br/>    block_custom_response_content_key = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_log_destination_arns"></a> [log\_destination\_arns](#input\_log\_destination\_arns) | (Required) Configuration block that allows you to associate Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) with the web ACL | `list(string)` | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | (Optional) Configuration block that specifies which web requests are kept in the logs and which are dropped. It allows filtering based on the rule action and the web request labels applied by matching rules during web ACL evaluation | `any` | `{}` | no |
| <a name="input_logging_redacted_fields"></a> [logging\_redacted\_fields](#input\_logging\_redacted\_fields) | (Optional) Configuration for parts of the request that you want to keep out of the logs. Up to 100 redacted\_fields blocks are supported | `any` | `[]` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | (Optional) List of Managed WAF rules | <pre>list(object({<br/>    name            = string<br/>    priority        = number<br/>    override_action = string<br/>    vendor_name     = string<br/>    version         = optional(string)<br/>    rule_action_override = list(object({<br/>      name          = string<br/>      action_to_use = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, Forces new resource) Friendly name of the WebACL. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. Conflicts with name | `string` | `null` | no |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | (Optional) List of WAF Rule Groups | <pre>list(object({<br/>    name            = string<br/>    arn             = string<br/>    priority        = number<br/>    override_action = string<br/>  }))</pre> | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required, Forces new resource) Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value pairs to associate with the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_integration_url"></a> [application\_integration\_url](#output\_application\_integration\_url) | The URL to use in SDK integrations with managed rule groups |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the WAF WebACL |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_id"></a> [id](#output\_id) | The ID of the WAF WebACL |
<!-- END_TF_DOCS -->

## License
Apache 2 Licensed. See [LICENSE](https://github.com/anatomiq/terraform-postgres-setup/blob/main/LICENSE) for full details.
