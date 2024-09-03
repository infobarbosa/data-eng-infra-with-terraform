provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "glue-catalog" {
  source  = "./modules/glue-catalog"

  database_name = "dataeng-glue-database"
}

resource "aws_s3_bucket" "dataeng-bucket" {
  bucket = "dataeng-modulo-1-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = {
    Name        = "dataeng-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "dataeng-bucket-ownership-controls" {
    bucket = aws_s3_bucket.dataeng-bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "dataeng-bucket-acl" {
    depends_on = [aws_s3_bucket_ownership_controls.dataeng-bucket-ownership-controls]

    bucket = aws_s3_bucket.dataeng-bucket.id
    acl    = "private"
}

resource "random_string" "suffix" {
  length  = 6
  lower = true
  min_lower = 6
  special = false
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

resource "aws_vpc" "dataeng-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dataeng-vpc"
  }
}

resource "aws_subnet" "dataeng-public-subnet" {
  vpc_id            = aws_vpc.dataeng-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-public-subnet"
  }
}

resource "aws_internet_gateway" "dataeng-igw" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}

resource "aws_security_group" "dataeng-sg" {
  vpc_id = aws_vpc.dataeng-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-sg"
  }
}