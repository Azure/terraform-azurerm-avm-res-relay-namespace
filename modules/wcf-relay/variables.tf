variable "location" {
  type        = string
  description = "The Azure region for this module's resources or telemetry deployment."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the WCF relay."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._/]{0,258}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 1 and 260 characters long, start and end with a letter or number, and can only contain letters, numbers, hyphens, periods, underscores, and forward slashes."
  }
}

variable "relay_namespace_id" {
  type        = string
  description = "The resource ID of the parent Relay namespace."
}

variable "relay_type" {
  type        = string
  description = "The type of the WCF relay. Possible values are 'NetTcp' or 'Http'."

  validation {
    condition     = contains(["NetTcp", "Http"], var.relay_type)
    error_message = "The relay_type must be either 'NetTcp' or 'Http'."
  }
}

variable "avm_azapi_header" {
  type        = string
  default     = ""
  description = "The AVM AzAPI header value to use for telemetry."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "requires_client_authorization" {
  type        = bool
  default     = true
  description = "Indicates whether client authorization is required."
}

variable "requires_transport_security" {
  type        = bool
  default     = true
  description = "Indicates whether transport security is required."
}

variable "user_metadata" {
  type        = string
  default     = null
  description = "The user metadata associated with the WCF relay."
}
