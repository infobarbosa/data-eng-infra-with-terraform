resource "aws_dynamodb_table" "dataeng-modulo-3-backend-terraform-lock" {
  name = "dataeng-modulo-3-backend-terraform-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}