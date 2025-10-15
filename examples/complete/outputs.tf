output "id" {
  description = "The ID of the WAF WebACL"
  value       = module.waf.id
}

output "arn" {
  description = "The ARN of the WAF WebACL"
  value       = module.waf.arn
}

output "capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = module.waf.capacity
}

output "application_integration_url" {
  description = "The URL to use in SDK integrations with managed rule groups"
  value       = module.waf.application_integration_url
}
