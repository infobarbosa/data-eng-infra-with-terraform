terraform {
  backend "s3" {
    bucket         = dataeng-modulo-3-tf-backend.id
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "dataeng-modulo-3-tf-backend-state-lock"
  }
}
