    resource "aws_launch_template" "dataeng_lt" {
      name_prefix   = "dataeng-lt"
      image_id      = var.ami_id
      instance_type = var.instance_type
      key_name      = var.key_name
      
      network_interfaces {
        associate_public_ip_address = true
        delete_on_termination      = true
        security_groups = [ var.dataeng_public_sg_id ]
      }

      user_data = filebase64("${path.module}/userdata.sh")

      lifecycle {
        create_before_destroy = true
      }

      block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
          delete_on_termination = true
          volume_size           = 8
          volume_type           = "gp3"
        }
      }

      tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "dataeng-lt"
        }
      }
    }

    resource "aws_autoscaling_group" "dataeng_asg" {
      desired_capacity     = 2
      max_size             = 3
      min_size             = 1
      vpc_zone_identifier  = [var.dataeng_public_subnet_id]
      launch_template {
        id      = aws_launch_template.dataeng_lt.id
        version = "$Latest"
      }  

      tag {
        key                 = "Name"
        value               = "dataeng-ec2-instance"
        propagate_at_launch = true
      }
   
      lifecycle {
        create_before_destroy = true
      }
    }
