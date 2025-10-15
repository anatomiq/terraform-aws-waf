variable "name" {
  description = "(Optional, Forces new resource) Friendly name of the WebACL. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  type        = string
  default     = "waf-apps"
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource"
  type        = map(string)
  default     = {}
}
