variable "name" {
  type        = string
  description = "The name of the hybrid connection."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._/]{0,258}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 1 and 260 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, periods, underscores, and forward slashes."
  }
}

variable "relay_namespace_id" {
  type        = string
  description = "The resource ID of the parent Relay namespace."
}

variable "requires_client_authorization" {
  type        = bool
  default     = true
  description = "Indicates whether client authorization is required."
}

variable "user_metadata" {
  type        = string
  default     = null
  description = "The user metadata associated with the hybrid connection."
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
