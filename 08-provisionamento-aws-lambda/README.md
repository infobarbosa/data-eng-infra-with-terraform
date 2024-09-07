# Módulo 6: Criação de Função AWS Lambda

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
    lambda/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── lambda_function.py
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_s3_bucket" "dataeng_modulo_6_bucket" {
      bucket = "dataeng-modulo-6-bucket"
      acl    = "private"
    }

    resource "aws_iam_role" "lambda_exec_role" {
      name = "dataeng-modulo-6-lambda-exec-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }]
      })
    }

    resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
      role       = aws_iam_role.lambda_exec_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }

    resource "aws_lambda_function" "dataeng_modulo_6_lambda" {
      filename         = "lambda_function.zip"
      function_name    = "dataeng_modulo_6_lambda"
      role             = aws_iam_role.lambda_exec_role.arn
      handler          = "lambda_function.lambda_handler"
      runtime          = "python3.8"
      source_code_hash = filebase64sha256("lambda_function.zip")
      environment {
        variables = {
          EMR_CLUSTER_ID = var.emr_cluster_id
        }
      }
    }

    resource "aws_lambda_permission" "allow_s3_to_invoke" {
      statement_id  = "AllowS3Invoke"
      action        = "lambda:InvokeFunction"
      function_name = aws_lambda_function.dataeng_modulo_6_lambda.function_name
      principal     = "s3.amazonaws.com"
      source_arn    = aws_s3_bucket.dataeng_modulo_6_bucket.arn
    }

    resource "aws_s3_bucket_notification" "bucket_notification" {
      bucket = aws_s3_bucket.dataeng_modulo_6_bucket.id

      lambda_function {
        lambda_function_arn = aws_lambda_function.dataeng_modulo_6_lambda.arn
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = ".csv"
      }
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "emr_cluster_id" {
      description = "ID do cluster EMR"
      type        = string
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
    ```hcl
    output "lambda_function_arn" {
      value = aws_lambda_function.dataeng_modulo_6_lambda.arn
    }

    output "s3_bucket_name" {
      value = aws_s3_bucket.dataeng_modulo_6_bucket.bucket
    }
    ```

5. Crie o script Python `lambda_function.py` na pasta `lambda/`:
    ```python
    import boto3
    import os

    def lambda_handler(event, context):
        emr_client = boto3.client('emr')
        cluster_id = os.environ['EMR_CLUSTER_ID']
        step = {
            'Name': 'Process CSV File',
            'ActionOnFailure': 'CONTINUE',
            'HadoopJarStep': {
                'Jar': 'command-runner.jar',
                'Args': ['spark-submit', 's3://path-to-your-bucket/scripts/spark_job.py']
            }
        }
        response = emr_client.add_job_flow_steps(
            JobFlowId=cluster_id,
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
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 6! Agora você sabe como criar uma função Lambda que é ativada por um trigger do S3 e aciona um step no cluster EMR.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy