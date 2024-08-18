variable "ami_id" {
  description = "ID da AMI para a instância EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da Key Pair para acessar a instância"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets para o Auto Scaling Group"
  type        = list(string)
}