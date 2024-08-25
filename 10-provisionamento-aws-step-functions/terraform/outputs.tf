output "bucket_name" {
  value = aws_s3_bucket.dataeng_modulo_8_bucket.bucket
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.emr_step_function.arn
}