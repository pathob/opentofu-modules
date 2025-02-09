variable "name" {
  description = "Name of the bucket (without prefix)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.name))
    error_message = "Invalid S3 bucket name."
  }
}

variable "prefix" {
  description = "Prefix of the bucket (to make it globally unique)"
  type        = string
}

variable "enable_object_lock" {
  description = "Enable object lock (implies enabling versioning)"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "List of allowed IPs"
  type        = list(string)
}

variable "enforce_storage_class" {
  description = "Enforce the given storage class with a lifecycle configuration"
  type        = string
  default     = null
}
