variable "name" {
  description = "(Optional, Forces new resource) Friendly name of the WebACL. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional) Friendly description of the WebACL"
  type        = string
}

variable "scope" {
  description = "(Required, Forces new resource) Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider"
  type        = string
}

variable "managed_rules" {
  description = "(Optional) List of Managed WAF rules"
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
  default = []
}

variable "ip_sets_rule" {
  description = "(Optional) A rule to detect web requests coming from particular IP addresses or address ranges"
  type = list(object({
    name                              = string
    priority                          = number
    ip_set_arn                        = string
    action                            = string
    response_code                     = optional(number, 403)
    enable_block_custom_response      = optional(bool, false)
    enable_block_custom_headers       = optional(bool, false)
    block_custom_response_content_key = optional(string)
  }))
  default = []
}

variable "ip_rate_based_rule" {
  description = "(Optional) A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span"
  type = object({
    name                              = string
    priority                          = number
    limit                             = number
    action                            = string
    response_code                     = optional(number, 403)
    enable_block_custom_response      = optional(bool, false)
    enable_block_custom_headers       = optional(bool, false)
    block_custom_response_content_key = optional(string)
    aggregate_key_type                = optional(string, "IP")
    forwarded_ip_header_name          = optional(string, "X-Forwarded-For")
    fallback_behavior                 = optional(string, "MATCH")
  })
  default = null
}

variable "ip_rate_url_based_rules" {
  description = "(Optional) A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span"
  type = list(object({
    name                              = string
    priority                          = number
    limit                             = number
    action                            = string
    response_code                     = optional(number, 403)
    search_string                     = string
    positional_constraint             = string
    enable_block_custom_response      = optional(bool, false)
    enable_block_custom_headers       = optional(bool, false)
    block_custom_response_content_key = optional(string)
  }))
  default = []
}

variable "filtered_header_rule" {
  description = "(Optional) HTTP header to filter  Currently supports a single header type and multiple header values"
  type = object({
    header_types  = list(string)
    priority      = number
    header_value  = string
    action        = string
    search_string = string
  })
  default = null
}

variable "enable_waf_association" {
  description = "(Optional) Whether to enable WAF association"
  type        = bool
  default     = false
}

variable "associate_resource_arn" {
  description = "(Optional) ARN of the resource to be associated with the WAF ACL"
  type        = string
  default     = ""
}

variable "rule_groups" {
  description = "(Optional) List of WAF Rule Groups"
  type = list(object({
    name            = string
    arn             = string
    priority        = number
    override_action = string
  }))
  default = []
}

variable "default_action" {
  description = "(Required) Action to perform if none of the rules contained in the WebACL match"
  type        = string
  default     = "allow"
}

variable "enable_custom_block_response" {
  description = "(Optional) This enables custom responses for the block requests"
  type        = bool
  default     = false
}

variable "custom_block_response_content" {
  description = "(Optional) Map of custom block response bodies (key = response body name, value = body content)"
  type        = map(string)
  default     = {}
}

variable "custom_block_response_content_type" {
  description = "(Required) Type of content in the payload that you are defining in the content argument. Valid values are TEXT_PLAIN, TEXT_HTML, or APPLICATION_JSON"
  type        = string
  default     = "TEXT_PLAIN"
}

variable "enable_logging_configuration" {
  description = "(Optional) Whether to enable logging configuration for the WAF"
  type        = bool
  default     = false
}

variable "log_destination_arns" {
  description = "(Required) Configuration block that allows you to associate Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) with the web ACL"
  type        = list(string)
  default     = []
}

variable "logging_redacted_fields" {
  description = "(Optional) Configuration for parts of the request that you want to keep out of the logs. Up to 100 redacted_fields blocks are supported"
  type        = any
  default     = []
}

variable "logging_filter" {
  type        = any
  description = "(Optional) Configuration block that specifies which web requests are kept in the logs and which are dropped. It allows filtering based on the rule action and the web request labels applied by matching rules during web ACL evaluation"
  default     = {}
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource"
  type        = map(string)
  default     = {}
}
