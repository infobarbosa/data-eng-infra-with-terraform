# Módulo 9: Provisionamento de RDS MySQL

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Configuração de RDS (MySQL)
O Amazon RDS (Relational Database Service) facilita a configuração, operação e escalabilidade de bancos de dados relacionais na nuvem. Para configurar uma instância RDS MySQL, é necessário definir parâmetros como nome da instância, tipo de instância, versão do MySQL, configurações de rede, entre outros.

### Políticas de IAM para Acesso aos Recursos
As políticas de IAM (Identity and Access Management) são usadas para gerenciar permissões de acesso aos recursos da AWS. Para acessar uma instância RDS, é necessário configurar políticas que permitam a criação, leitura, atualização e exclusão de recursos RDS.

## Laboratório

### Exercício: Configurar uma Instância RDS e Associar Políticas de IAM

1. Crie a estrutura de pastas para o Terraform:
    ```
    terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_s3_bucket" "dataeng_modulo_9_bucket" {
      bucket = "dataeng-modulo-9-${random_string.suffix.result}"
      acl    = "private"
    }

    resource "random_string" "suffix" {
      length  = 6
      special = false
      upper   = false
    }

    resource "aws_db_instance" "dataeng_modulo_9_rds" {
      identifier              = "dataeng-modulo-9-rds"
      allocated_storage       = 20
      engine                  = "mysql"
      engine_version          = "8.0"
      instance_class          = "db.t3.micro"
      name                    = "dataengmodulo9db"
      username                = "admin"
      password                = "password"
      parameter_group_name    = "default.mysql8.0"
      skip_final_snapshot     = true
    }

    resource "aws_iam_role" "rds_access_role" {
      name = "dataeng-modulo-9-rds-access-role"

      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "rds.amazonaws.com"
            }
          },
        ]
      })
    }

    resource "aws_iam_role_policy" "rds_access_policy" {
      name   = "dataeng-modulo-9-rds-access-policy"
      role   = aws_iam_role.rds_access_role.id
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "rds:*",
              "s3:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      })
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "bucket_name" {
      description = "Nome do bucket S3"
      type        = string
      default     = "dataeng-modulo-9"
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
    ```hcl
    output "bucket_name" {
      value = aws_s3_bucket.dataeng_modulo_9_bucket.bucket
    }

    output "rds_endpoint" {
      value = aws_db_instance.dataeng_modulo_9_rds.endpoint
    }

    output "rds_iam_role_arn" {
      value = aws_iam_role.rds_access_role.arn
    }
    ```

5. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 9! Agora você sabe como configurar uma instância RDS MySQL e associar políticas de IAM para acesso aos recursos.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy