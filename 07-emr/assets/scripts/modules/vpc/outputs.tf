# Output dos IDs dos recursos
output "vpc_id" {
  value = aws_vpc.dataeng-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.dataeng-public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.dataeng-private-subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.dataeng-igw.id
}

output "dataeng_public_sg_id" {
  value = aws_security_group.dataeng-public-sg.id
}

output "dataeng_private_sg_id" {
  value = aws_security_group.dataeng-private-sg.id
}
