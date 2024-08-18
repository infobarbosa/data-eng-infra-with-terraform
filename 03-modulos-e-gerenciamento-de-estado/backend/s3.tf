provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region     = "us-east-1"
}

resource "aws_s3_bucket" "dataeng-modulo-3-tf-backend" {
    bucket = "dataeng-modulo-3-tf-backend-${random_string.suffix.result}"
    acl = "private"

    tags = {
        Name        = "dataeng-modulo-1-bucket"
        Environment = "Dev"
    }
}

resource "random_string" "suffix" {
    length  = 6
    lower = true
    min_lower = 6
    special = false
}
