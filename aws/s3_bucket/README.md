AWS S3 Bucket
=============

This module helps configuring secure AWS S3 buckets with optional backup functionality.

## Features

- Secure S3 bucket configuration with public access blocking
- IAM user and access key generation
- Optional versioning and object lock
- Optional AWS Backup integration for automated backups
- Lifecycle configuration for storage class enforcement
- IP-based access restrictions

## Backup Functionality

This module supports AWS Backup integration for automated S3 bucket backups. The backup functionality requires an external backup vault to be created separately using the `backup-vault` module.

When enabled, it provides:

- **Periodic Backups**: Scheduled backups based on cron expression
- **Continuous Backups**: Point-in-time recovery for up to 35 days (optional)
- **IAM Roles**: Properly configured service roles for backup operations
- **Integration**: Works with externally managed backup vaults for better modularity

### Prerequisites for Backup

- A backup vault must be created using the `backup-vault` module (or externally)
- S3 versioning is automatically enabled when backup is enabled (required by AWS Backup)
- Ensure your AWS account has the necessary service quotas for AWS Backup

### Backup Types

1. **Periodic Backups**: Snapshot-based backups with customizable retention (up to 99 years)
2. **Continuous Backups**: Real-time backup with point-in-time recovery (max 35 days retention)

### Cost Considerations

- Backup storage costs apply based on data size and retention period
- Consider using lifecycle policies to manage backup costs
- Continuous backups may have higher costs due to real-time tracking

## Usage Example

```hcl
# First, create a backup vault
module "backup_vault" {
  source = "../backup-vault"

  name = "my-company-backup-vault"
  
  tags = {
    Environment = "production"
    Team        = "infrastructure"
  }
}

# Then, create the S3 bucket with backup enabled
module "s3_bucket" {
  source = "./path/to/this/module"

  name   = "my-bucket"
  prefix = "my-company"
  
  # Enable backup functionality
  enable_backup                     = true
  backup_vault_name                 = module.backup_vault.backup_vault_name
  backup_schedule                   = "cron(0 2 * * ? *)"  # Daily at 2 AM
  backup_retention_days             = 30
  
  # Optional: Enable continuous backup for point-in-time recovery
  enable_continuous_backup          = true
  continuous_backup_retention_days  = 7
  
  # Other configuration
  enable_versioning    = true
  allowed_ips         = ["203.0.113.0/24"]
}
```

## Notes

- It is only necessary to configure server-side encryption for the S3 bucket if you want to use a customer-provided key that is stored at AWS Key Management Service (SSE-KMS).
  If you want to use server-side encryption with a customer-provided key that is only provided during requests and not stored at AWS (SSE-C), then this needs to be configured at the client-side.
  If you don't configure any server-side encryption, then AWS S3 automatically enables server-side encryption with AWS S3 managed keys (SSE-S3).
- When backup is enabled, S3 versioning is automatically enabled as it's required by AWS Backup.
- Backup functionality requires an external backup vault (use the `backup-vault` module) for better modularity and reusability.
- Multiple S3 buckets can share the same backup vault, reducing resource overhead.
- Backup functionality creates additional AWS resources (IAM roles, backup plan) which may incur additional costs.
