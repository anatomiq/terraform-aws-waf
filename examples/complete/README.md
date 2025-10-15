# Complete AWS WAF resource

Configuration in this directory creates AWS WAF resources with different sets of arguments.

## Usage

To use this module, you need to include it in your Terraform configuration. You can do this by adding the following to your `main.tf` file:

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

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_waf"></a> [waf](#module\_waf) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_rule_group.block_countries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Optional, Forces new resource) Friendly name of the WebACL. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix | `string` | `"waf-apps"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value pairs to associate with the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_integration_url"></a> [application\_integration\_url](#output\_application\_integration\_url) | The URL to use in SDK integrations with managed rule groups |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the WAF WebACL |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_id"></a> [id](#output\_id) | The ID of the WAF WebACL |
<!-- END_TF_DOCS -->
