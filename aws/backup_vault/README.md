AWS Backup Vault
================

This module creates an AWS Backup Vault for storing backup recovery points.

## Features

- Creates an AWS Backup Vault with optional KMS encryption
- Configurable tags for resource management
- Optional force destroy capability for testing environments

## Usage

```hcl
module "backup_vault" {
  source = "./path/to/backup-vault"

  name        = "my-backup-vault"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Team        = "infrastructure"
  }
}

# Use the outputs
output "backup_vault_name" {
  value = module.backup_vault.backup_vault_name
}

output "backup_vault_arn" {
  value = module.backup_vault.backup_vault_arn
}
```

## Notes

- The backup vault will store all recovery points from backup plans that reference it
- KMS encryption is optional but recommended for sensitive data
- Use `force_destroy = true` only in testing environments where you want to delete the vault even if it contains recovery points
- Recovery points in the vault will incur storage costs based on the backup size and retention period
