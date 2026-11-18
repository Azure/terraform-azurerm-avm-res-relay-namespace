variable "ignore_body_changes" {
  type = object({
    relay_namespaces_hybrid_connections = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored for the Relay resource. Paths use dot notation. Changes take effect only after apply. Ignored configuration is not sent to Azure until the path is removed.

- `relay_namespaces_hybrid_connections` - The hybrid connection.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    relay_namespaces_hybrid_connections = optional(string, "Microsoft.Relay/namespaces/hybridConnections@2024-01-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `relay_namespaces_hybrid_connections` - The hybrid connection.
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
