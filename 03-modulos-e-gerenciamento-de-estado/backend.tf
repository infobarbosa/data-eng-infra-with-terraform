terraform {
  backend "s3" {
    bucket         = "dataeng-modulo-3-backend-<sufixo-aleatorio>"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
