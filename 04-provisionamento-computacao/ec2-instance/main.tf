provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "dataeng_modulo_4_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "dataeng-modulo-4-instance"
  }
}

