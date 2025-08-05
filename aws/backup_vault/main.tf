# AWS Backup Vault
resource "aws_backup_vault" "backup_vault" {
  name         = var.name
  kms_key_arn  = var.kms_key_arn
  force_destroy = var.force_destroy

  tags = var.tags
}
