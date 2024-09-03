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