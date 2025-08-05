output "iam_access_key_id" {
  value = aws_iam_access_key.iam_access_key.id
}

output "iam_access_key_secret" {
  value     = aws_iam_access_key.iam_access_key.secret
  sensitive = true
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "backup_plan_id" {
  description = "ID of the backup plan (if backup is enabled)"
  value       = var.enable_backup ? aws_backup_plan.s3_backup_plan[0].id : null
}

output "backup_plan_arn" {
  description = "ARN of the backup plan (if backup is enabled)"
  value       = var.enable_backup ? aws_backup_plan.s3_backup_plan[0].arn : null
}

output "backup_vault_name" {
  description = "Name of the backup vault being used (if backup is enabled)"
  value       = var.enable_backup ? var.backup_vault_name : null
}
