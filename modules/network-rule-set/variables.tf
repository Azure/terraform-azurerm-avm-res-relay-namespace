variable "relay_namespace_id" {
  type        = string
  description = "The resource ID of the parent Relay namespace."
}

variable "default_action" {
  type        = string
  default     = "Allow"
  description = "The default action when no rule matches. Possible values are 'Allow' or 'Deny'."

  validation {
    condition     = contains(["Allow", "Deny"], var.default_action)
    error_message = "The default_action must be either 'Allow' or 'Deny'."
  }
}

variable "public_network_access" {
  type        = string
  default     = "Enabled"
  description = "Public network access for the namespace. Possible values are 'Enabled', 'Disabled', or 'SecuredByPerimeter'."

  validation {
    condition     = contains(["Enabled", "Disabled", "SecuredByPerimeter"], var.public_network_access)
    error_message = "The public_network_access must be one of: 'Enabled', 'Disabled', or 'SecuredByPerimeter'."
  }
}

variable "ip_rules" {
  type = list(object({
    ipMask = string
    action = optional(string, "Allow")
  }))
  default     = []
  description = "List of IP rules. Each rule must contain an ipMask and optionally an action (default: Allow)."
}

variable "trusted_service_access_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable trusted Azure service access."
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Controls whether telemetry is enabled for the submodule."
}

variable "avm_azapi_header" {
  type        = string
  default     = ""
  description = "The AVM AzAPI header value to use for telemetry."
}
