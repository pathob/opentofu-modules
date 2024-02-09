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

data "aws_iam_policy_document" "iam_policy_document_s3_dedicated_access" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.iam_user.arn}"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.allowed_ips
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_dedicated_access" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.iam_policy_document_s3_dedicated_access.json
}
