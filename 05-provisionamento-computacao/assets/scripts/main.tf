provider "aws" {
  region = "us-east-1"
}

module "glue-catalog" {
  source  = "./modules/glue-catalog"

  database_name = "dataeng-glue-database"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "dataeng-modulo-1-bucket" {
  bucket = "dataeng-modulo-1-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "dataeng-modulo-1-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "dataeng-modulo-1-bucket-ownership-controls" {
    bucket = aws_s3_bucket.dataeng-modulo-1-bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "dataeng-modulo-1-bucket-acl" {
    depends_on = [aws_s3_bucket_ownership_controls.dataeng-modulo-1-bucket-ownership-controls]

    bucket = aws_s3_bucket.dataeng-modulo-1-bucket.id
    acl    = "private"
}

resource "random_string" "suffix" {
  length  = 6
  lower = true
  min_lower = 6
  special = false
}

resource "aws_s3_object" "dataset_clientes" {
    bucket = aws_s3_bucket.dataeng-modulo-1-bucket.id
    key    = "raw/clientes/clientes.csv.gz"
    source = "./datasets-csv-clientes/clientes.csv.gz"
}

resource "aws_s3_object" "dataset_pedidos" {
    bucket = aws_s3_bucket.dataeng-modulo-1-bucket.id
    key    = "raw/pedidos/pedidos-2024-01-01.csv.gz"
    source = "./datasets-csv-pedidos/pedidos-2024-01-01.csv.gz"
}

resource "aws_vpc" "dataeng-modulo-2-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dataeng-modulo-2-vpc"
  }
}

resource "aws_subnet" "dataeng-modulo-2-subnet" {
  vpc_id            = aws_vpc.dataeng-modulo-2-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-modulo-2-subnet"
  }
}

resource "aws_internet_gateway" "dataeng-modulo-2-igw" {
  vpc_id = aws_vpc.dataeng-modulo-2-vpc.id
  tags = {
    Name = "dataeng-modulo-2-igw"
  }
}

resource "aws_security_group" "dataeng-modulo-2-sg" {
  vpc_id = aws_vpc.dataeng-modulo-2-vpc.id

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
    Name = "dataeng-modulo-2-sg"
  }
}

resource "aws_instance" "dataeng_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "dataeng-ec2-instance"
  }
}

