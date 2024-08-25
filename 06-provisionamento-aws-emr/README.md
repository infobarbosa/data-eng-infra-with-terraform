# Módulo 5: Criação do Cluster AWS EMR

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Parâmetros essenciais
Para criar um cluster EMR, você precisa definir parâmetros como o nome do cluster, a versão do Hadoop, a configuração das instâncias e os passos (steps) que serão executados no cluster.

### Criação do cluster EMR
O AWS EMR (Elastic MapReduce) é um serviço gerenciado que facilita o processamento de grandes volumes de dados usando frameworks como Hadoop, Spark, e HBase.

### Criação de EMR Steps
Steps são tarefas que você pode adicionar ao seu cluster EMR para serem executadas automaticamente. Eles podem incluir jobs Spark, Hive, Pig, entre outros.

## Laboratório

### Exercício Simples: Configuração de parâmetros essenciais

1. Crie a estrutura de pastas para o cluster EMR:
    ```
    emr-cluster/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── scripts/
        └── spark_job.py
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_emr_cluster" "dataeng_modulo_5_emr" {
      name          = "dataeng-modulo-5-emr"
      release_label = "emr-5.30.0"
      applications  = ["Hadoop", "Spark"]
      service_role  = aws_iam_role.emr_service_role.arn
      ec2_attributes {
        instance_profile = aws_iam_instance_profile.emr_instance_profile.arn
        subnet_id        = var.subnet_id
      }
      master_instance_group {
        instance_type = "m5.xlarge"
      }
      core_instance_group {
        instance_type = "m5.xlarge"
        instance_count = 2
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
        name = "Spark job"
        action_on_failure = "CONTINUE"
        hadoop_jar_step {
          jar = "command-runner.jar"
          args = ["spark-submit", "s3://path-to-your-bucket/scripts/spark_job.py"]
        }
      }
      tags = {
        Name = "dataeng-modulo-5-emr"
      }
    }

    resource "aws_iam_role" "emr_service_role" {
      name = "dataeng-modulo-5-emr-service-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "elasticmapreduce.amazonaws.com"
          }
        }]
      })
    }

    resource "aws_iam_role_policy_attachment" "service_role_policy" {
      role       = aws_iam_role.emr_service_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
    }

    resource "aws_iam_instance_profile" "emr_instance_profile" {
      name = "dataeng-modulo-5-emr-instance-profile"
      role = aws_iam_role.emr_service_role.name
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "subnet_id" {
      description = "ID da subnet para o cluster EMR"
      type        = string
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
    ```hcl
    output "emr_cluster_id" {
      value = aws_emr_cluster.dataeng_modulo_5_emr.id
    }
    ```

5. Crie o script Python `spark_job.py` na pasta `scripts/`:
    ```python
    from pyspark.sql import SparkSession

    spark = SparkSession.builder.appName("CSV to Parquet").getOrCreate()

    # Ler o arquivo CSV do S3
    df = spark.read.csv("s3://path-to-your-bucket/input-data/", header=True, inferSchema=True)

    # Escrever o arquivo Parquet no S3
    df.write.parquet("s3://path-to-your-bucket/output-data/")

    spark.stop()
    ```

6. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```

### Exercício Avançado: Criação do cluster EMR e execução de EMR Steps

1. Adicione o seguinte conteúdo ao arquivo `main.tf` para incluir os steps:
    ```hcl
    step {
      name = "Spark job"
      action_on_failure = "CONTINUE"
      hadoop_jar_step {
        jar = "command-runner.jar"
        args = ["spark-submit", "s3://path-to-your-bucket/scripts/spark_job.py"]
      }
    }
    ```

2. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 5! Agora você sabe como criar um cluster EMR e configurar EMR Steps.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy