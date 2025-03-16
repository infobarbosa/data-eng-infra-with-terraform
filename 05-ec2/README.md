# Módulo 5: Provisionamento de Recursos de Computação

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Criando Instâncias EC2
As instâncias EC2 são máquinas virtuais que você pode usar para executar suas aplicações na AWS. Você pode configurar o tipo de instância, a AMI (Amazon Machine Image) e as Key Pairs para acessar a instância.

### Configuração de AMIs e Key Pairs
AMIs são modelos que contêm a configuração necessária para iniciar uma instância, incluindo o sistema operacional e o software instalado. Key Pairs são usadas para acessar as instâncias de forma segura.

### Auto Scaling Groups e Launch Templates
Auto Scaling Groups permitem que você configure a escalabilidade automática das suas instâncias EC2, garantindo que você tenha o número certo de instâncias para lidar com a carga de trabalho. Launch Templates definem como as instâncias devem ser iniciadas.

## Laboratório

### Exercício 1: Criar uma Instância EC2

1. Crie a estrutura de pastas para a instância EC2:
    ```
    ec2/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```

    ```sh
    mkdir -p modules/ec2
    touch modules/ec2/main.tf
    touch modules/ec2/variables.tf
    touch modules/ec2/outputs.tf

    ```

2. Adicione o seguinte conteúdo ao arquivo `./modules/ec2/main.tf`:
    ```hcl
    resource "aws_instance" "dataeng_ec2_instance" {
        ami                         = var.ami_id
        instance_type               = var.instance_type
        security_groups             = [var.dataeng_public_sg_id]
        subnet_id                   = var.public_subnet_id
        key_name                    = "vockey"
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

    ```

3. Adicione o seguinte conteúdo ao arquivo `./modules/ec2/variables.tf`:
    ```hcl
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

    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/ec2/outputs.tf`:
    ```hcl
    output "instance_id" {
      value = aws_instance.dataeng_ec2_instance.id
    }

    output "instance_public_ip" {
      value = aws_instance.dataeng_ec2_instance.public_ip
    }

    ```

5. Verifique o id da AMI utilizando o seguinte comando no terminal:
    ```sh
    aws ec2 describe-images \
      --filters "Name=architecture,Values=x86_64" "Name=creation-date,Values=2024-08-*" "Name=owner-id,Values=099720109477" "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240801" \
      --owners amazon \
      --query 'Images[*].[ImageId,Name,Description]' \
      --output json
    
    ```

6. Acrescente o trecho a seguir em `main.tf`:
    ```hcl
    module "ec2" {
      source = "./modules/ec2"

      public_subnet_id     = module.vpc.public_subnet_id
      dataeng_public_sg_id = module.vpc.dataeng_public_sg_id
    }
    
    ```

7. Execute o Terraform:
    ```sh
    terraform init

    ```
    
    ```
    terraform apply --auto-approve
    
    ```

8. Verifique o resultado no painel AWS EC2.

    ```sh
    aws ec2 describe-instances --filters "Name=tag:Name,Values=dataeng-ec2-instance" --query "Reservations[*].Instances[*].[InstanceId, State.Name,   InstanceType, PublicIpAddress]" --output table

    ```

9. Destrua apenas o recurso EC2.
    ```sh
    terraform plan -destroy -target="module.ec2.aws_instance.dataeng_ec2_instance"
    
    ```

    ```sh
    terraform destroy -target="module.ec2.aws_instance.dataeng_ec2_instance" --auto-approve

    ```

### Exercício 2: Configurar Auto Scaling Group

1. Crie a estrutura de pastas para o Auto Scaling Group:
    ```
    ├── main.tf
    ├── modules
    │   ├── asg
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    ```

    ```sh
    mkdir -p modules/asg
    touch modules/asg/main.tf
    touch modules/asg/variables.tf
    touch modules/asg/outputs.tf

    ```
2. Crie um arquivo `./modules/asg/userdata.sh` com o seguinte conteúdo:
    ```sh
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "<h1>Welcome to the Apache server!</h1>" > /var/www/html/index.html
    echo "<p>Server IP: \$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>" >> /var/www/html/index.html
    systemctl restart apache2

    ```

3. Adicione o seguinte conteúdo ao arquivo `./modules/asg/main.tf`:
    ```hcl
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
    ```

3. Adicione o seguinte conteúdo ao arquivo `./modules/asg/variables.tf`:
    ```hcl
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

    variable "dataeng_public_subnet_id" {
        description = "Id da subnet publica"
        type        = string
    }

    variable "dataeng_public_sg_id" {
        description = "Id do security group"
        type        = string
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/asg/outputs.tf`:
    ```hcl
    output "autoscaling_group_name" {
      value = aws_autoscaling_group.dataeng_asg.name
    }
    ```

5. Verifique o id da AMI utilizando o seguinte comando no terminal:
    ```sh
    aws ec2 describe-images \
      --filters "Name=architecture,Values=x86_64" "Name=creation-date,Values=2024-08-*" "Name=owner-id,Values=099720109477" "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240801" \
      --owners amazon \
      --query 'Images[*].[ImageId,Name,Description]' \
      --output json
    ```

6. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    module "asg" {
      source = "./modules/asg"

      dataeng_public_subnet_id  = module.vpc.public_subnet_id
      dataeng_public_sg_id      = module.vpc.dataeng_public_sg_id
    } 
    ```

7. Execute o Terraform:
    ```sh
    terraform init

    ```
    
    ```
    terraform apply --auto-approve

    ```

8. Verifique o resultado no painel AWS EC2.

9. Destrua o Auto Scaling Group.
  ```sh
  terraform plan -destroy -target="module.asg.aws_autoscaling_group.dataeng_asg" 

  ```
  
  ```sh
  terraform plan -destroy -target="module.asg.aws_launch_template.dataeng_lt" 

  ```
  
  ```sh
  terraform destroy -target="module.asg.aws_autoscaling_group.dataeng_asg" --auto-approve

  ```
  
  ```sh
  terraform destroy -target="module.asg.aws_launch_template.dataeng_lt" --auto-approve

  ```

## Parabéns
Você concluiu o módulo! Agora você sabe como criar instâncias EC2 e configurar Auto Scaling Groups.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
  ```sh
  terraform destroy --auto-approve

  ```

### Destruição Seletiva dos Recursos

Para realizar a destruição seletiva dos recursos criados neste módulo, siga os passos abaixo:

1. Abra o terminal e navegue até o diretório do projeto.

2. Execute o seguinte comando para visualizar o plano de destruição dos recursos:
  ```sh
  terraform plan -destroy

  ```

3. Analise o plano de destruição para verificar quais recursos serão removidos.

4. Selecione os recursos que deseja destruir e execute o comando abaixo substituindo `$RESOURCE_NAME` pelo nome do recurso:
    ```sh
    terraform destroy -target="module.ec2.aws_instance.dataeng_ec2_instance"
    
    ```

    ```sh
    terraform destroy -target="module.asg.aws_autoscaling_group.dataeng_asg"
    ```

    ```sh
    terraform destroy -target="module.asg.aws_launch_template.dataeng_lt"
    ```

5. Confirme a destruição dos recursos quando solicitado.

Lembre-se de que a destruição seletiva dos recursos pode resultar em dependências não resolvidas. Certifique-se de entender as implicações antes de prosseguir.
