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

### Auto Scaling Groups e Launch Configurations
Auto Scaling Groups permitem que você configure a escalabilidade automática das suas instâncias EC2, garantindo que você tenha o número certo de instâncias para lidar com a carga de trabalho. Launch Configurations definem como as instâncias devem ser iniciadas.

## Laboratório

### Exercício 1: Criar uma Instância EC2

1. Crie a estrutura de pastas para a instância EC2:
    ```
    ec2-instance/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_instance" "dataeng_ec2_instance" {
      ami           = var.ami_id
      instance_type = var.instance_type

      tags = {
        Name = "dataeng-ec2-instance"
      }
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
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
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
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

6. Execute o Terraform:
    ```sh
    terraform init
    ```
    
    ```
    terraform apply --auto-approve
    ```

7. Verifique o resultado no painel AWS EC2.

## Desafio 1
Você deve ter percebido que a instância AWS EC2 foi criada na VPC default da conta.<br>
Altere as configurações de forma que seja remanejada para a VPC e security group corretos.

Referência: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#network-and-credit-specification-example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#network-and-credit-specification-example)

### Exercício 2: Configurar Auto Scaling Group

1. Crie a estrutura de pastas para o Auto Scaling Group:
    ```
    auto-scaling/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_launch_configuration" "dataeng_lc" {
      name          = "dataeng-lc"
      image_id      = var.ami_id
      instance_type = var.instance_type
      key_name      = var.key_name

      lifecycle {
        create_before_destroy = true
      }
    }

    resource "aws_autoscaling_group" "dataeng_asg" {
      desired_capacity     = 1
      max_size             = 2
      min_size             = 1
      launch_configuration = aws_launch_configuration.dataeng_lc.id
      vpc_zone_identifier  = var.subnet_ids

      tag {
        key                 = "Name"
        value               = "dataeng-ec2-instance"
        propagate_at_launch = true
      }
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "ami_id" {
      description = "ID da AMI para a instância EC2"
      type        = string
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
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
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

6. Execute o Terraform:
    ```sh
    terraform init
    ```
    
    ```
    terraform apply --auto-approve
    ```

7. Verifique o resultado no painel AWS EC2.

## Parabéns
Você concluiu o módulo! Agora você sabe como criar instâncias EC2 e configurar Auto Scaling Groups.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy