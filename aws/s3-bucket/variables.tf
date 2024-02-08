variable "name" {
  type        = string
  description = "Name of the bucket (without prefix)"
}

variable "prefix" {
  type        = string
  description = "Prefix of the bucket (to make it globally unique)"
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs"
}
