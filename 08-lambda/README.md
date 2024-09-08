# Módulo 8: Funções AWS Lambda

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Visão Geral de uma Função Lambda Ativada por um Trigger do S3
A AWS Lambda é um serviço de computação que permite executar código sem provisionar ou gerenciar servidores. Você pode configurar uma função Lambda para ser ativada por eventos de outros serviços da AWS, como o Amazon S3. Neste módulo, vamos criar uma função Lambda que será ativada quando um arquivo CSV for adicionado a um bucket S3. A função Lambda, então, acionará um step no cluster EMR criado no módulo anterior.

## Laboratório

### Exercício: Implantação de Função Lambda

1. Crie a estrutura de pastas para a função Lambda:
    ```
    ├── main.tf
    ├── modules
    │   ├── lambda
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── scripts
    │   │   │   ├── lambda_function.py
    │   │   │   └── pedidos_spark_job.py
    │   │   └── variables.tf
    ```

    ```sh
    mkdir -p ./modules/lambda/scripts
    touch ./modules/lambda/main.tf 
    touch ./modules/lambda/variables.tf 
    touch ./modules/lambda/outputs.tf 
    touch ./modules/lambda/scripts/lambda_function.py
    touch ./modules/lambda/scripts/pedidos_spark_job.py
    ```

2. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/main.tf`:
    ```hcl
    data "aws_iam_roles" "roles" {
      name_regex = "LabRole"
    }

    locals {
      dataeng_role = data.aws_iam_roles.roles.roles[0].arn
    }

    resource "aws_lambda_function" "dataeng_lambda" {
      filename         = "./modules/lambda/scripts/lambda_function.zip"
      function_name    = "dataeng_lambda"
      role             = local.dataeng_role
      handler          = "lambda_function.lambda_handler"
      runtime          = "python3.8"
      source_code_hash = base64sha256(file("./modules/lambda/scripts/lambda_function.zip"))
      environment {
        variables = {
          EMR_CLUSTER_ID = var.dataeng_emr_cluster_id
          DATAENG_BUCKET_NAME = var.dataeng_bucket_name
        }
      }
    }

    resource "aws_lambda_permission" "dataeng_s3_invoke" {
      statement_id  = "AllowS3Invoke"
      action        = "lambda:InvokeFunction"
      function_name = aws_lambda_function.dataeng_lambda.function_name
      principal     = "s3.amazonaws.com"
      source_arn    = var.dataeng_bucket_arn
    }

    resource "aws_s3_bucket_notification" "bucket_notification" {
      bucket = var.dataeng_bucket_name

      lambda_function {
        lambda_function_arn = aws_lambda_function.dataeng_lambda.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "raw/pedidos/"
        filter_suffix       = ".csv.gz"

      }
    }

    ```

3. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/variables.tf`:
    ```hcl
    variable "dataeng_emr_cluster_id" {
      description = "ID do cluster EMR"
      type        = string
    }

    variable "dataeng_bucket_name" {
      description = "Nome do bucket S3"
      type        = string
    }

    variable "dataeng_bucket_arn" {
      description = "ARN do bucket S3"
      type        = string
    }

    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/outputs.tf`:
    ```hcl
    output "dataeng_lambda_arn" {
      value = aws_lambda_function.dataeng_lambda.arn
    }

    ```

5. Crie o script Python `lambda_function.py` na pasta `lambda/`:
    ```python
    import boto3
    import os

    def lambda_handler(event, context):
        emr_client = boto3.client('emr')
        dataeng_cluster_id = os.environ['DATAENG_EMR_CLUSTER_ID']
        dataeng_bucket_name = os.environ['DATAENG_BUCKET_NAME']

        step = {
            'Name': 'Processamento de pedidos',
            'ActionOnFailure': 'CONTINUE',
            'HadoopJarStep': {
                'Jar': 'command-runner.jar',
                'Args': ['spark-submit', f's3://{dataeng_bucket_name}/scripts/pedidos_spark_job.py']
            }
        }
        response = emr_client.add_job_flow_steps(
            JobFlowId=dataeng_cluster_id,
            Steps=[step]
        )
        return response
    ```

6. Crie um arquivo `lambda_function.zip` contendo o script `lambda_function.py`:
    ```sh
    zip lambda_function.zip lambda_function.py
    ```

7. Execute o Terraform:
    ```sh
    terraform init
    ```

    ```sh
    terraform apply --auto-approve
    ```

## Parabéns
Você concluiu o módulo! Agora você sabe como criar uma função Lambda que é ativada por um trigger do S3 e aciona um step no cluster EMR.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy