terraform {
  backend "s3" {
    bucket         = "dataeng-modulo-3-tf-backend-lht"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "dataeng-modulo-3-tf-backend-state-lock"
  }
}