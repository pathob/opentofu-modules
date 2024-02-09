output "bucket_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
}

output "iam_access_key_id" {
  value = aws_iam_access_key.iam_access_key.id
}

output "iam_access_key_secret" {
  value     = aws_iam_access_key.iam_access_key.secret
  sensitive = true
}
