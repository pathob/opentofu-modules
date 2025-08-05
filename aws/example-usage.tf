# Example: Using S3 Bucket with Backup Vault modules

# Create a shared backup vault that can be used by multiple S3 buckets
module "backup_vault" {
  source = "../backup_vault"

  name = "my-company-shared-backup-vault"

  # Optional: Use customer-managed KMS key for encryption
  # kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Team        = "infrastructure"
    Purpose     = "backup-storage"
  }
}

# Create S3 bucket with backup enabled
module "s3_bucket_with_backup" {
  source = "../s3-bucket"

  name   = "my-app-data"
  prefix = "my-company"

  # Enable backup functionality
  enable_backup                     = true
  backup_vault_name                 = module.backup_vault.backup_vault_name
  backup_schedule                   = "cron(0 2 * * ? *)"  # Daily at 2 AM
  backup_retention_days             = 30

  # Enable continuous backup for point-in-time recovery
  enable_continuous_backup          = true
  continuous_backup_retention_days  = 7

  # S3 bucket configuration
  enable_versioning    = true
  allowed_ips         = ["203.0.113.0/24", "198.51.100.0/24"]

  # Optional: Enforce storage class
  enforce_storage_class = "STANDARD_IA"
}

# Create another S3 bucket using the same backup vault
module "s3_bucket_logs" {
  source = "../s3-bucket"

  name   = "application-logs"
  prefix = "my-company"

  # Enable backup with different retention policy
  enable_backup                     = true
  backup_vault_name                 = module.backup_vault.backup_vault_name
  backup_schedule                   = "cron(0 4 ? * SUN *)"  # Weekly on Sunday at 4 AM
  backup_retention_days             = 90

  # Logs don't need continuous backup
  enable_continuous_backup          = false

  # S3 bucket configuration
  allowed_ips         = ["203.0.113.0/24"]
  enforce_storage_class = "GLACIER"
}

# Outputs
output "backup_vault_info" {
  description = "Information about the shared backup vault"
  value = {
    name = module.backup_vault.backup_vault_name
    arn  = module.backup_vault.backup_vault_arn
  }
}

output "app_bucket_info" {
  description = "Information about the application data bucket"
  value = {
    name           = module.s3_bucket_with_backup.bucket_name
    arn            = module.s3_bucket_with_backup.bucket_arn
    backup_plan_id = module.s3_bucket_with_backup.backup_plan_id
  }
}

output "logs_bucket_info" {
  description = "Information about the logs bucket"
  value = {
    name           = module.s3_bucket_logs.bucket_name
    arn            = module.s3_bucket_logs.bucket_arn
    backup_plan_id = module.s3_bucket_logs.backup_plan_id
  }
}
