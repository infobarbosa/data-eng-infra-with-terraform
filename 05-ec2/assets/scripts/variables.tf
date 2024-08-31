variable "ami_id" {
  description = "ID da AMI para a instância EC2"
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome da Key Pair para acessar a instância"
  type        = string
  default     = "vockey"
}