variable "ignore_body_changes" {
  type = object({
    authorization_locks                               = optional(list(string), [])
    authorization_role_assignments                    = optional(list(string), [])
    insights_diagnostic_settings                      = optional(list(string), [])
    network_private_endpoints                         = optional(list(string), [])
    network_private_endpoints_private_dns_zone_groups = optional(list(string), [])
    relay_namespaces                                  = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored for each AzAPI resource. Paths use dot notation. Changes take effect only after apply. Ignored configuration is not sent to Azure until the path is removed. Non-empty values require Terraform 1.11 or later.

- `authorization_locks` - Namespace and private endpoint locks.
- `authorization_role_assignments` - Namespace and private endpoint role assignments.
- `insights_diagnostic_settings` - Namespace diagnostic settings.
- `network_private_endpoints` - Private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Private endpoint DNS zone groups.
- `relay_namespaces` - The Relay namespace.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    authorization_locks                               = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments                    = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    insights_diagnostic_settings                      = optional(string, "Microsoft.Insights/diagnosticSettings@2021-05-01-preview")
    network_private_endpoints                         = optional(string, "Microsoft.Network/privateEndpoints@2024-05-01")
    network_private_endpoints_private_dns_zone_groups = optional(string, "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01")
    relay_namespaces                                  = optional(string, "Microsoft.Relay/namespaces@2024-01-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `authorization_locks` - Namespace and private endpoint locks.
- `authorization_role_assignments` - Namespace and private endpoint role assignments.
- `insights_diagnostic_settings` - Namespace diagnostic settings.
- `network_private_endpoints` - Private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Private endpoint DNS zone groups.
- `relay_namespaces` - The Relay namespace.
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
Retry configuration applied to each AzAPI resource declared by this module.

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
Operation timeouts applied to each AzAPI resource declared by this module. Values are duration strings; null uses the provider defaults.

- `create` - Create timeout.
- `read` - Read timeout.
- `update` - Update timeout.
- `delete` - Delete timeout.
DESCRIPTION
}
