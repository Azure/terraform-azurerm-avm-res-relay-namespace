variable "resource_types" {
  type = object({
    relay_namespaces_network_rule_sets = optional(string, "Microsoft.Relay/namespaces/networkRuleSets@2024-01-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `relay_namespaces_network_rule_sets` - The network rule set.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to the AzAPI resource declared by this module.

- `error_message_regex` - Error patterns that trigger a retry.
- `interval_seconds` - Initial retry interval in seconds.
- `max_interval_seconds` - Maximum retry interval in seconds.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Operation timeouts applied to the AzAPI resource declared by this module. Values are duration strings; null uses provider defaults.

- `create` - Create timeout.
- `read` - Read timeout.
- `update` - Update timeout.
- `delete` - Delete timeout.
DESCRIPTION
}
