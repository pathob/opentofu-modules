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

variable "enable_backup" {
  description = "Enable AWS Backup for the S3 bucket"
  type        = bool
  default     = false
}

variable "backup_vault_name" {
  description = "Name of the existing backup vault to use (required if enable_backup is true)"
  type        = string
  default     = null
  validation {
    condition = var.enable_backup == false || (var.enable_backup == true && var.backup_vault_name != null)
    error_message = "backup_vault_name must be provided when enable_backup is true."
  }
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule (e.g., 'cron(0 2 * * ? *)')"
  type        = string
  default     = "cron(0 2 * * ? *)" # Daily at 2 AM
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "enable_continuous_backup" {
  description = "Enable continuous backup for point-in-time recovery (max 35 days)"
  type        = bool
  default     = false
}

variable "continuous_backup_retention_days" {
  description = "Number of days to retain continuous backups (max 35)"
  type        = number
  default     = 7
  validation {
    condition     = var.continuous_backup_retention_days <= 35
    error_message = "Continuous backup retention cannot exceed 35 days."
  }
}
