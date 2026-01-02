variable "name" {
  type        = string
  description = "The name of the authorization rule."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,48}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 1 and 50 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, periods, and underscores."
  }
}

variable "relay_namespace_id" {
  type        = string
  description = "The resource ID of the parent Relay namespace."
}

variable "rights" {
  type        = list(string)
  description = "The list of rights associated with the rule. Possible values are 'Listen', 'Send', and 'Manage'."

  validation {
    condition     = alltrue([for right in var.rights : contains(["Listen", "Send", "Manage"], right)])
    error_message = "Each right must be one of: 'Listen', 'Send', or 'Manage'."
  }
  validation {
    condition     = length(var.rights) > 0
    error_message = "At least one right must be specified."
  }
}

variable "avm_azapi_header" {
  type        = string
  default     = ""
  description = "The AVM AzAPI header value to use for telemetry."
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Controls whether telemetry is enabled for the submodule."
}
