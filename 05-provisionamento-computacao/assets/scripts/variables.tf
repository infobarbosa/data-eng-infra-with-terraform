variable "ami_id" {
  description = "ID da AMI para a instância EC2"
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}