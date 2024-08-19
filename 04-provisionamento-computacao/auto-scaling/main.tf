provider "aws" {
  region = "us-east-1"
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

resource "aws_launch_configuration" "dataeng_modulo_4_lc" {
  name          = "dataeng-modulo-4-lc"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dataeng_modulo_4_asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  launch_configuration = aws_launch_configuration.dataeng_modulo_4_lc.id
  vpc_zone_identifier = [aws_subnet.dataeng-modulo-2-subnet.id]
  
  tag {
    key                 = "Name"
    value               = "dataeng-modulo-4-instance"
    propagate_at_launch = true
  }
}