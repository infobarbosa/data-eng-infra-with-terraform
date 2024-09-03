resource "aws_s3_bucket" "dataeng-bucket" {
  bucket_prefix = "dataeng-"
  force_destroy = true

  tags = {
    Name        = "dataeng-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object" {
    bucket = aws_s3_bucket.dataeng-bucket.id
    key    = "pombo.txt"
    source = "./pombo.txt"
}


resource "aws_s3_object" "dataset_clientes" {
    bucket = aws_s3_bucket.dataeng-bucket.id
    key    = "raw/clientes/clientes.csv.gz"
    source = "./datasets-csv-clientes/clientes.csv.gz"
}

resource "aws_s3_object" "dataset_pedidos" {
    bucket = aws_s3_bucket.dataeng-bucket.id
    key    = "raw/pedidos/pedidos-2024-01-01.csv.gz"
    source = "./datasets-csv-pedidos/pedidos-2024-01-01.csv.gz"
}

