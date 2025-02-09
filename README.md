AWS S3 Bucket
=============

This module helps configuring secure AWS S3 buckets.

## Notes

- It is only necessary to configure server-side encryption for the S3 bucket if you want to use a customer-provided key that is stored at Amazon AWS with AWS Key Management Service (AWS KMS).
  If you want to use server-side encryption with a customer-provided key that is only provided during requests and not stored at AWS (SSE-C), then this needs to be configured at the client-side.
  If you don't configure any server-side encryption, then Amazon S3 automatically enables server-side encryption with Amazon S3 managed keys (SSE-S3).

- It is not necessary to disable public access if you don't want the bucket to be publicy accessible since this is the default configuration.
