# Módulo 7: Criação do Cluster AWS EMR

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Introdução

### Parâmetros essenciais
Para criar um cluster EMR, você precisa definir parâmetros como o nome do cluster, a versão do Hadoop, a configuração das instâncias e os passos (steps) que serão executados no cluster.

### Criação do cluster EMR
O AWS EMR (Elastic MapReduce) é um serviço gerenciado que facilita o processamento de grandes volumes de dados usando frameworks como Hadoop, Spark, e HBase.

### Criação de EMR Steps
Steps são tarefas que você pode adicionar ao seu cluster EMR para serem executadas automaticamente. Eles podem incluir jobs Spark, Hive, Pig, entre outros.

## Laboratório

### Exercício 1: Configuração de parâmetros essenciais

1. **Crie** a estrutura de pastas para o cluster EMR:
    ```
    ├── main.tf
    └── modules
        ├── emr
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── scripts
        │   │   └── clientes_spark_job.py
        │   └── variables.tf
    ```

    ```sh
    mkdir -p ./modules/emr
    touch ./modules/emr/main.tf
    touch ./modules/emr/variables.tf
    touch ./modules/emr/outputs.tf
    mkdir -p ./modules/emr/scripts
    touch ./modules/emr/scripts/clientes_spark_job.py
    touch ./modules/emr/scripts/bootstrap-actions.sh

    ```

2. **Adicione** o seguinte conteúdo ao arquivo **`./modules/emr/main.tf`**:
    > **Atenção!** Você deve substituir algumas informações no script abaixo, `service_role` e `instance_profile`.

    ```hcl
    # 2. ./modules/emr/main.tf
    resource "aws_emr_cluster" "dataeng_emr" {
      name          = "dataeng-emr"
      release_label = "emr-7.2.0"
      applications  = ["Hadoop", "Spark"]
      service_role  = "EMR_DefaultRole"
      log_uri = "s3://${var.dataeng_bucket_name}/emr/logs/"
      ec2_attributes {
        instance_profile = "EMR_EC2_DefaultRole"
        subnet_id        = var.dataeng_public_subnet_id
      }
      master_instance_group {
        instance_type = "m4.large"
      }
      core_instance_group {
        instance_type = "m4.large"
        instance_count = 1
      }
      bootstrap_action {
        path = "s3://${var.dataeng_bucket_name}/scripts/bootstrap-actions.sh"
        name = "Install boto3 e awsglue"
      }  
      step {
        name = "Setup Hadoop Debugging"
        action_on_failure = "TERMINATE_CLUSTER"
        hadoop_jar_step {
          jar = "command-runner.jar"
          args = ["state-pusher-script"]
        }
      }
      step {
        name = "Clientes Spark Job"
        action_on_failure = "CONTINUE"
        hadoop_jar_step {
          jar = "command-runner.jar"
          args = [
            "spark-submit", 
            "s3://${var.dataeng_bucket_name}/scripts/clientes_spark_job.py",
            "${var.dataeng_bucket_name}"
          ]
        }
      }
      tags = {
        Name = "dataeng-emr"
      }
    }

    ```
3. **Adicione** o seguinte conteúdo ao arquivo **`./modules/emr/variables.tf`**:
    ```h
    # 3. ./modules/emr/variables.tf
    variable "dataeng_public_subnet_id" {
      description = "Id da subnet publica"
      type        = string
    }

    variable "dataeng_bucket_name" {
      description = "Nome do bucket que vamos usar"
      type        = string
    }

    ```

4. **Adicione** o seguinte conteúdo ao arquivo **`./modules/emr/outputs.tf`**:
    ```h
    # 4. ./modules/emr/outputs.tf
    output "dataeng_emr_cluster_id" {
      value = aws_emr_cluster.dataeng_emr.id
    }

    ```

5. **Adicione** o seguinte conteúdo ao arquivo **`./modules/emr/scripts/clientes_spark_job.py`**:
    
    ```python
    import os
    import sys
    import logging
    from datetime import datetime
    from pyspark.sql import SparkSession

    def main():

        # Inicialização da SparkSession
        spark = SparkSession \
            .builder \
            .appName("clientes_spark_job") \
            .config("hive.metastore.client.factory.class", "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory") \
            .enableHiveSupport() \
            .getOrCreate()

        log4jLogger = spark._jvm.org.apache.log4j
        logger = log4jLogger.LogManager.getLogger("clientes_spark_job")
        logger.info("Iniciando processamento [clientes_spark_job]")

        spark.catalog.setCurrentDatabase("dataengdb")

        # Determinando bucket S3
        logger.info("Buscando bucket S3 com prefixo 'dataeng-'")
        BUCKET_NAME = ""
        try:

            if len(sys.argv) < 2:
                logger.info("Uso: spark-submit clientes_spark_job.py <BUCKET_NAME>")
                sys.exit(1)

            BUCKET_NAME = sys.argv[1]
            logger.info(f"O bucket que vamos utilizar será: {BUCKET_NAME}")

        except Exception as e:
            logger.exception("Erro ao listar buckets S3")
            sys.exit(1)

        # Carregando dados de clientes
        logger.info("Lendo dados da tabela 'tb_raw_clientes'")
        try:
            df_clientes = spark.sql("SELECT * FROM dataengdb.tb_raw_clientes")
            logger.info(f"Total de registros lidos: {df_clientes.count()}")
        except Exception as e:
            logger.exception("Erro ao ler dados da tabela 'tb_raw_clientes'")
            sys.exit(1)

        # Gravando os dados no S3 em formato Parquet
        output_path = f"s3://{BUCKET_NAME}/stage/clientes"
        logger.info(f"Gravando dados no path: {output_path}")
        try:
            df_clientes.write.format("parquet").mode("overwrite").save(output_path)
            logger.info("Dados gravados com sucesso.")
        except Exception as e:
            logger.exception("Erro ao gravar dados no S3")
            sys.exit(1)

        logger.info("Finalizando o script de processamento dos dados: clientes_spark_job")

    if __name__ == "__main__":
        main()

    ```

    Perceba que no script estamos fazendo referência a uma tabela `tb_stage_clientes` que não existe ainda. Mais adiante vamos adicionar o script para criá-la.

6. Criando a tabela `tb_stage_clientes`

    **Adicione** o trecho a seguir no arquivo **`./modules/glue_catalog/main.tf`**:
  
    ```hcl
    # 6. ./modules/glue_catalog/main.tf
    resource "aws_glue_catalog_table" "dataeng_glue_table_stage_clientes" {
        database_name = aws_glue_catalog_database.dataeng_glue_database.name
        name          = "tb_stage_clientes"
        table_type    = "EXTERNAL_TABLE"
        parameters = {
            classification = "parquet",
            "compressionType" = "snappy",
            "skip.header.line.count" = "0"
        }
        storage_descriptor {
            location = "s3://${var.dataeng_bucket_name}/stage/clientes/"

            input_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
            output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
            compressed = true
            number_of_buckets = -1
            ser_de_info {
                serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
                parameters = {
                    "serialization.format" = "1"
                }
            }
            columns {
                name = "id"
                type = "int"
            }
            columns {
                name = "nome"
                type = "string"
            }
            columns {
                name = "data_nasc"
                type = "date"
            }
            columns {
                name = "cpf"
                type = "string"
            }
            columns {
                name = "email"
                type = "string"
            }  
        }
    }  
    
    ```

7. **Adicione** o trecho abaixo ao arquivo **`./modules/emr/main.tf`**:
  ```hcl
  # 7. ./modules/emr/main.tf
  resource "aws_s3_object" "clientes_spark_job" {
      bucket = var.dataeng_bucket_name
      key    = "scripts/clientes_spark_job.py"
      source = "./modules/emr/scripts/clientes_spark_job.py"
  }

  ```

8. **Adicione** o trecho abaixo ao arquivo **`./modules/emr/main.tf`**:
  ```hcl
  # 8. ./modules/emr/main.tf
  resource "aws_s3_object" "bootstrap_actions_sh" {
      bucket = var.dataeng_bucket_name
      key    = "scripts/bootstrap-actions.sh"
      source = "./modules/emr/scripts/bootstrap-actions.sh"
  }  

  ```

9. **Adicione** o seguinte conteúdo ao arquivo **`./modules/emr/scripts/bootstrap-actions.sh`**:
  ```sh
  #!/bin/bash

  echo "`date -Is` - Instalando boto3"
  sudo pip install boto3 

  ```
10. **Adicione** o seguinte conteúdo ao arquivo **`./main.tf`**:
  ```hcl
  # 10. EMR
  module "emr" {
    source  = "./modules/emr"

    dataeng_public_subnet_id = module.vpc.public_subnet_id
    dataeng_bucket_name = module.s3.dataeng_bucket
  }

  ```

11. [OPCIONAL] Retire os trechos abaixo do arquivo `./main.tf`:

    Caso você tenha feito o módulo **05-ec2** Para os propósitos deste laboratório esses recursos não serão mais necessários.
    ```
    module "ec2" {
      ...
    }
    ```

    ```
    module "asg" {
      ...
    }
    ```

12. Execute o Terraform:
    ```sh
    terraform init

    ```

    ```sh
    terraform plan

    ```

    ```sh
    terraform apply --auto-approve

    ```
13. **Verifique**
    - No console AWS EMR verifique o status de criacao do cluster `dataeng-emr`.
    - Via terminal:

      ```sh
      aws emr list-clusters --active --query "Clusters[?Name=='dataeng-emr'].Id" --output text

      ``` 

      ```sh
      aws emr list-clusters --active --query "Clusters[?Name=='dataeng-emr'].[Id,Status.State,Status.Timeline.CreationDateTime]" --output table

      ```

    - No console AWS Glue Catalog verifique a criação da tabela `tb_stage_clientes`

    - Via terminal:
      ```sh
      aws glue get-tables --database-name dataengdb --query "TableList[*].Name" --output table

      ```

    - No console AWS S3 verifique a criação do arquivo parquet na pasta `.../stage/clientes`.

    - No console AWS Athena verifique os dados via consulta SQL:
      ```sql
      SELECT * FROM "dataengdb"."tb_stage_clientes" limit 10;

      ``` 

14. Valide que a criação da tabela ocorreu com sucesso via console AWS Glue e AWS Athena.

### Desafio 1: Criação e execução de EMR Steps de pedidos
Utilizando os conhecimentos adquiridos anterioremente, crie o job `pedidos_spark_job`.
Abaixo segue um exemplo de criação do EMR Step no cluster.

1. Adicione o seguinte conteúdo ao arquivo `main.tf` para incluir os steps:
    ```hcl
    step {
      name = "Pedidos Spark Job"
      action_on_failure = "CONTINUE"
      hadoop_jar_step {
        jar = "command-runner.jar"
        args = ["spark-submit", "s3://${var.dataeng_bucket_name}/scripts/pedidos_spark_job.py"]
      }
    }
    ```

2. Execute o Terraform:
    ```sh
    terraform init

    ```

    ```sh
    terraform plan

    ```

    ```sh
    terraform apply --auto-approve

    ```

### Desafio 2: Criação da tabela `tb_stage_pedidos` no AWS Glue Catalog.

Utilizando o conhecimento adquirido nas etapas anteriores, crie via Terraform a tabela `tb_stage_pedidos`.<br>
Valide que a criação ocorreu com sucesso via console AWS Athena.

## Parabéns
Você concluiu o módulo! Agora você sabe como criar um cluster EMR e configurar EMR Steps.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy --auto-approve
```

## Destruição seletiva dos recursos

**Cluster EMR**
```sh
terraform plan -destroy -target="module.emr.aws_emr_cluster.dataeng_emr" 

```

```sh
terraform destroy -target="module.emr.aws_emr_cluster.dataeng_emr" --auto-approve

```

**Spark Job Clientes**
```sh
terraform destroy -target="module.emr.aws_s3_object.clientes_spark_job" --auto-approve

```

```sh
terraform destroy -target="module.emr.aws_s3_object.bootstrap_actions_sh" --auto-approve

```

## Referência
O modelo de camadas de armazenamento utilizado neste laboratório tem como base o **AWS Prescriptive Guidance** que pode ser encontrado [aqui](https://docs.aws.amazon.com/prescriptive-guidance/latest/defining-bucket-names-data-lakes/naming-structure-data-layers.html).
