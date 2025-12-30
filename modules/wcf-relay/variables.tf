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
