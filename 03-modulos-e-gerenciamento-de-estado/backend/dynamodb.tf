resource "aws_dynamodb_table" "dataeng-modulo-3-teste-tabela-dynamo" {
  name = "dataeng-modulo-3-teste-tabela-dynamo"
  hash_key = "ID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "ID"
    type = "S"
  }
}