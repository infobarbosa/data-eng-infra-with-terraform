provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "dataeng_modulo_6_bucket" {
  bucket = "dataeng-modulo-6-bucket"
  acl    = "private"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "dataeng-modulo-6-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "dataeng_modulo_6_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "dataeng_modulo_6_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_function.zip")
  environment {
    variables = {
      EMR_CLUSTER_ID = var.emr_cluster_id
    }
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dataeng_modulo_6_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dataeng_modulo_6_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.dataeng_modulo_6_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dataeng_modulo_6_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
}