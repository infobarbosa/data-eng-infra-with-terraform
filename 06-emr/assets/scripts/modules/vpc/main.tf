resource "aws_vpc" "dataeng-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true  
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
resource "aws_subnet" "dataeng-private-subnet" {
  vpc_id            = aws_vpc.dataeng-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-private-subnet"
  }
}
resource "aws_internet_gateway" "dataeng-igw" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}
resource "aws_route_table" "dataeng-public-rt" {
  vpc_id = aws_vpc.dataeng-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dataeng-igw.id
  }
  tags = {
    Name = "dataeng-public-rt"
  }
}
resource "aws_route_table_association" "dataeng-public-association" {
  subnet_id      = aws_subnet.dataeng-public-subnet.id
  route_table_id = aws_route_table.dataeng-public-rt.id
}
resource "aws_route_table" "dataeng-private-rt" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-private-rt"
  }
}
resource "aws_route_table_association" "dataeng-private-association" {
  subnet_id      = aws_subnet.dataeng-private-subnet.id
  route_table_id = aws_route_table.dataeng-private-rt.id
}

resource "aws_security_group" "dataeng-public-sg" {
  name        = "public-sg"
  description = "Security group para a subnet publica"
  vpc_id      = aws_vpc.dataeng-vpc.id

  # Permitir tráfego HTTP de entrada
  ingress {
    description      = "Allow HTTP inbound traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Permitir tráfego SSH de entrada
  ingress {
    description      = "Allow SSH inbound traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-public-sg"
  }
}

resource "aws_security_group" "dataeng-private-sg" {
  name        = "private-sg"
  description = "Security group para a subnet privada"
  vpc_id      = aws_vpc.dataeng-vpc.id

  # Permitir tráfego de entrada HTTP da subnet pública
  ingress {
    description      = "Allow HTTP inbound traffic from public subnet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.dataeng-public-subnet.cidr_block]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-private-sg"
  }
}
