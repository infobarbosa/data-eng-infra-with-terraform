output "lambda_function_arn" {
  value = aws_lambda_function.dataeng_modulo_6_lambda.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.dataeng_modulo_6_bucket.bucket
}