output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.backup_vault.name
}

output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.backup_vault.arn
}

output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = aws_backup_vault.backup_vault.id
}

output "backup_vault_recovery_points" {
  description = "Number of recovery points in the backup vault"
  value       = aws_backup_vault.backup_vault.recovery_points
}
