resource "aws_instance" "dataeng_ec2_instance" {
    ami           = var.ami_id
    instance_type = var.instance_type
    key_name      = "vockey"
    subnet_id     = var.public_subnet_id
    vpc_security_group_ids = [var.dataeng_public_sg_id]
    associate_public_ip_address = true
    tags = {
        Name = "dataeng-ec2-instance"
    }

    user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2
        EOF
}
       