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
    mkdir -p ./modules/lambda/
    mkdir -p ./modules/lambda/scripts/job
    mkdir -p ./modules/lambda/scripts/lambda
    touch ./modules/lambda/main.tf 
    touch ./modules/lambda/variables.tf 
    touch ./modules/lambda/outputs.tf 
    touch ./modules/lambda/scripts/lambda/lambda_function.py
    touch ./modules/lambda/scripts/job/pedidos_spark_job.py

    ```

2. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/main.tf`:
    ```hcl
    data "aws_iam_roles" "lab_role" {
      name_regex = "LabRole"
    }

    locals {
      dataeng_role = tolist(data.aws_iam_roles.lab_role.arns)[0]
    }

    resource "aws_lambda_function" "dataeng_lambda" {
      filename         = "./modules/lambda/scripts/lambda/lambda_function.zip"
      function_name    = "dataeng_lambda"
      role             = local.dataeng_role
      handler          = "lambda_function.lambda_handler"
      runtime          = "python3.12"
      source_code_hash = base64sha256(filebase64("./modules/lambda/scripts/lambda/lambda_function.zip"))
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

3. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/outputs.tf`:
    ```hcl
    output "dataeng_lambda_arn" {
      value = aws_lambda_function.dataeng_lambda.arn
    }

    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/variables.tf`:
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


5. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/scripts/lambda/lambda_function.py`:

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
    zip ./modules/lambda/scripts/lambda/lambda_function.zip ./modules/lambda/scripts/lambda/lambda_function.py

    ```

7. Adicione o seguinte conteúdo ao arquivo `./modules/lambda/scripts/job/pedidos_spark_job.py`:
    ```python
    import os
    import sys
    import boto3
    from datetime import datetime

    from pyspark.sql import SparkSession
    from pyspark.sql.functions import *

    print("Iniciando o script de processamento dos dados: pedidos_spark_job")
    spark = SparkSession \
        .builder \
        .appName("pedidos_spark_job") \
        .config("hive.metastore.client.factory.class", "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory") \
        .enableHiveSupport() \
        .getOrCreate()

    spark.catalog.setCurrentDatabase("dataengdb")

    print("Definindo a variavel BUCKET_NAME que vamos utilizar ao longo do codigo")
    BUCKET_NAME = ""
    s3_client = boto3.client('s3')
    response = s3_client.list_buckets()

    for bucket in response['Buckets']:
        if bucket['Name'].startswith('dataeng-'):
            BUCKET_NAME = bucket['Name']
            break

    print("O bucket que vamos utilizar serah: " + BUCKET_NAME)

    print("Obtendo os dados de pedidos")
    df_pedidos = spark.sql("select * from dataengdb.tb_raw_pedidos")
    df_pedidos.show(5)

    print("Escrevendo os dados de pedidos como parquet no S3")
    df_pedidos.write.format("parquet").mode("overwrite").save(f"s3://{BUCKET_NAME}/stage/pedidos")

    print("Finalizando o script de processamento dos dados: pedidos_spark_job")

    ```

8. Inclua o conteúdo a seguir ao final do arquivo `./modules/lambda/main.tf`:
    ```hcl
    resource "aws_s3_object" "pedidos_spark_job" {
        bucket = var.dataeng_bucket_name
        key    = "scripts/pedidos_spark_job.py"
        source = "./modules/lambda/scripts/job/pedidos_spark_job.py"
    }
    ```

9. Inclua o conteúdo a seguir ao final do arquivo `./main.ft`:
    ```hcl
    module "lambda" {
      source  = "./modules/lambda"

      dataeng_emr_cluster_id = module.emr.dataeng_emr_cluster_id
      dataeng_bucket_name = module.s3.dataeng-bucket
      dataeng_bucket_arn = module.s3.dataeng-bucket-arn
    } 
    ```

10. Execute o Terraform:
    ```sh
    terraform init

    ```

    ```sh
    terraform plan

    ```

    ```sh
    terraform apply --auto-approve

    ```

## Parabéns
Você concluiu o módulo! Agora você sabe como criar uma função Lambda que é ativada por um trigger do S3 e aciona um step no cluster EMR.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy --auto-approve
```

### Destruição Seletiva de Recursos

Caso você queira destruir apenas alguns recursos específicos, ao invés de todos os recursos criados pelo Terraform, você pode utilizar os seguintes comandos:

1. **aws_lambda_function.dataeng_lambda**
  ```sh
  terraform destroy -target=module.lambda.aws_lambda_function.dataeng_lambda --auto-approve
  ```

2. **aws_lambda_permission.dataeng_s3_invoke**
  ```sh
  terraform destroy -target=module.lambda.aws_lambda_permission.dataeng_s3_invoke --auto-approve
  ```

3. Para destruir apenas a notificação do bucket S3, execute o seguinte comando:
  ```sh
  terraform destroy -target=aws_s3_bucket_notification.bucket_notification --auto-approve
  ```

