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
  count = var.enable_versioning ? 1 : 0

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
      var.enable_object_lock || var.enable_versioning ? [
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

resource "aws_s3_bucket_lifecycle_configuration" "example_dev_lifecycle" {
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
