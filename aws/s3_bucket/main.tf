data "aws_canonical_user_id" "current" {}

resource "aws_iam_user" "iam_user" {
  name = "${var.prefix}-${var.name}-user"
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket              = "${var.prefix}-${var.name}"
  object_lock_enabled = var.enable_object_lock
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  count = var.enable_versioning || var.enable_backup ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration { status = "Enabled" }
}

data "aws_iam_policy_document" "iam_policy_document_s3_dedicated_access" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.iam_user.arn}"]
    }

    actions = concat(
      [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectAttributes",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      var.enable_object_lock || var.enable_versioning || var.enable_backup ? [
        "s3:GetBucketVersioning"
      ] : []
    )

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]

    dynamic "condition" {
      for_each = length(var.allowed_ips) > 0 ? [1] : []

      content {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = var.allowed_ips
      }
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_dedicated_access" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.iam_policy_document_s3_dedicated_access.json
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_configuration_enforce_storage_class" {
  count = var.enforce_storage_class != null ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    id     = "EnforceStorageClass"
    status = "Enabled"

    transition {
      days          = 0
      storage_class = var.enforce_storage_class
    }
  }
}

# AWS Backup IAM Role
resource "aws_iam_role" "backup_role" {
  count = var.enable_backup ? 1 : 0

  name = "${var.prefix}-${var.name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policies for S3 backup and restore
resource "aws_iam_role_policy_attachment" "backup_s3_policy" {
  count = var.enable_backup ? 1 : 0

  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "restore_s3_policy" {
  count = var.enable_backup ? 1 : 0

  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForS3Restore"
}

# AWS Backup Plan
resource "aws_backup_plan" "s3_backup_plan" {
  count = var.enable_backup ? 1 : 0

  name = "${var.prefix}-${var.name}-backup-plan"

  # Periodic backup rule
  rule {
    rule_name         = "s3_periodic_backup"
    target_vault_name = var.backup_vault_name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }

    recovery_point_tags = {
      Name   = "${var.prefix}-${var.name}-backup"
      Type   = "periodic"
      Bucket = aws_s3_bucket.s3_bucket.id
    }
  }

  # Continuous backup rule (if enabled)
  dynamic "rule" {
    for_each = var.enable_continuous_backup ? [1] : []

    content {
      rule_name         = "s3_continuous_backup"
      target_vault_name = var.backup_vault_name

      lifecycle {
        delete_after = var.continuous_backup_retention_days
      }

      enable_continuous_backup = true

      recovery_point_tags = {
        Name   = "${var.prefix}-${var.name}-backup"
        Type   = "continuous"
        Bucket = aws_s3_bucket.s3_bucket.id
      }
    }
  }
}

# AWS Backup Selection
resource "aws_backup_selection" "s3_backup_selection" {
  count = var.enable_backup ? 1 : 0

  iam_role_arn = aws_iam_role.backup_role[0].arn
  name         = "${var.prefix}-${var.name}-backup-selection"
  plan_id      = aws_backup_plan.s3_backup_plan[0].id

  resources = [
    aws_s3_bucket.s3_bucket.arn
  ]

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupEnabled"
    value = "true"
  }
}

# Add backup tag to S3 bucket
resource "aws_s3_bucket_tagging" "backup_tags" {
  count = var.enable_backup ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id

  tag_set = {
    BackupEnabled = "true"
    BackupPlan    = aws_backup_plan.s3_backup_plan[0].name
    BackupVault   = var.backup_vault_name
  }
}
