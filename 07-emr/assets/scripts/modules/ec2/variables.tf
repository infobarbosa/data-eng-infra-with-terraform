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

variable "public_subnet_id" {
    description = "ID da subnet pública"
    type        = string
}
variable "dataeng_public_sg_id" {
    description = "ID do security group público"
    type        = string
}