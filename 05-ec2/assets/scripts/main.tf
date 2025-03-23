provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "glue-catalog" {
  source  = "./modules/glue-catalog"

  database_name = "dataeng-glue-database"
}

resource "aws_s3_bucket" "dataeng_bucket" {
  bucket = "dataeng-modulo-1-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = {
    Name        = "dataeng_bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "dataeng_bucket_ownership_controls" {
    bucket = aws_s3_bucket.dataeng_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "dataeng_bucket_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.dataeng_bucket-ownership-controls]

    bucket = aws_s3_bucket.dataeng_bucket.id
    acl    = "private"
}

resource "random_string" "suffix" {
  length  = 6
  lower = true
  min_lower = 6
  special = false
}


resource "aws_s3_object" "dataset_clientes" {
    bucket = aws_s3_bucket.dataeng_bucket.id
    key    = "raw/clientes/clientes.csv.gz"
    source = "./datasets-csv-clientes/clientes.csv.gz"
}

resource "aws_s3_object" "dataset_pedidos" {
    bucket = aws_s3_bucket.dataeng_bucket.id
    key    = "raw/pedidos/pedidos-2024-01-01.csv.gz"
    source = "./datasets-csv-pedidos/pedidos-2024-01-01.csv.gz"
}

resource "aws_vpc" "dataeng_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dataeng-vpc"
  }
}

resource "aws_subnet" "dataeng_public_subnet" {
  vpc_id            = aws_vpc.dataeng_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-public-subnet"
  }
}

resource "aws_internet_gateway" "dataeng_igw" {
  vpc_id = aws_vpc.dataeng_vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}

resource "aws_security_group" "dataeng_sg" {
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

resource "aws_launch_template" "dataeng_lt" {
  name_prefix   = "dataeng-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "dataeng-lt"
    }
  }
}

resource "aws_instance" "dataeng_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "dataeng-ec2-instance"
  }
}

resource "aws_autoscaling_group" "dataeng_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.dataeng_public_subnet.id]
  launch_template {
    id      = aws_launch_template.dataeng_lt.id
    version = "$Latest"
  }  
  
  tag {
    key                 = "Name"
    value               = "dataeng-ec2-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}