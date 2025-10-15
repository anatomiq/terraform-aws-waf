output "id" {
  description = "The ID of the WAF WebACL"
  value       = aws_wafv2_web_acl.default.id
}

output "arn" {
  description = "The ARN of the WAF WebACL"
  value       = aws_wafv2_web_acl.default.arn
}

output "capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = aws_wafv2_web_acl.default.capacity
}

output "application_integration_url" {
  description = "The URL to use in SDK integrations with managed rule groups"
  value       = aws_wafv2_web_acl.default.application_integration_url
}
