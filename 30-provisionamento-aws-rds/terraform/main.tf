provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "dataeng_modulo_9_bucket" {
  bucket = "dataeng-modulo-9-${random_string.suffix.result}"
  acl    = "private"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_db_instance" "dataeng_modulo_9_rds" {
  identifier              = "dataeng-modulo-9-rds"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  name                    = "dataengmodulo9db"
  username                = "admin"
  password                = "password"
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
}

resource "aws_iam_role" "rds_access_role" {
  name = "dataeng-modulo-9-rds-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "rds_access_policy" {
  name   = "dataeng-modulo-9-rds-access-policy"
  role   = aws_iam_role.rds_access_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:*",
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}