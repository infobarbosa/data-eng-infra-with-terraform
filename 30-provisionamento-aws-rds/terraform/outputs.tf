output "bucket_name" {
  value = aws_s3_bucket.dataeng_modulo_9_bucket.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.dataeng_modulo_9_rds.endpoint
}

output "rds_iam_role_arn" {
  value = aws_iam_role.rds_access_role.arn
}