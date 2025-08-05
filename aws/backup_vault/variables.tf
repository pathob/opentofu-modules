variable "name" {
  description = "Name of the backup vault"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for backup vault encryption (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the backup vault"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Force destroy the backup vault even if it contains recovery points"
  type        = bool
  default     = false
}
