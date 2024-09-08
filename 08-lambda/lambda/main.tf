
data "aws_iam_roles" "roles" {
  name_regex = "LabRole"
}

locals {
  dataeng_role = data.aws_iam_roles.roles.roles[0].arn
}

resource "aws_lambda_function" "dataeng_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "dataeng_lambda"
  role             = local.dataeng_role
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = base64sha256(file("lambda_function.zip"))
  environment {
    variables = {
      EMR_CLUSTER_ID = var.dataeng_emr_cluster_id
      DATAENG_BUCKET_NAME = var.dataeng_bucket_name
    }
  }
}

resource "aws_lambda_permission" "dataeng_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dataeng_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.dataeng_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.dataeng_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.dataeng_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv.gz"

  }
}