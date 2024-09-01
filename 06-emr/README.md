# Módulo 6: Criação do Cluster AWS EMR

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

1. Crie a estrutura de pastas para o cluster EMR:
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
    ```

2. Adicione o seguinte conteúdo ao arquivo `./modules/emr/main.tf`:
    > **Atenção!** Você deve substituir algumas informações no script abaixo, `service_role` e `instance_profile`.

    ```hcl
    resource "aws_emr_cluster" "dataeng_emr" {
      name          = "dataeng-emr"
      release_label = "emr-7.2.0"
      applications  = ["Hadoop", "Spark"]
      service_role  = "EMR_DefaultRole"
      ec2_attributes {
        instance_profile = "EMR_EC2_DefaultRole"
        subnet_id        = var.dataeng_private_subnet_id
      }
      master_instance_group {
        instance_type = "m4.large"
      }
      core_instance_group {
        instance_type = "m4.large"
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
        name = "Clientes Spark Job"
        action_on_failure = "CONTINUE"
        hadoop_jar_step {
          jar = "command-runner.jar"
          args = ["spark-submit", "s3://${var.dataeng_bucket_name}/scripts/clientes_spark_job.py"]
        }
      }
      tags = {
        Name = "dataeng-emr"
      }
    }
    ```
3. Adicione o seguinte conteúdo ao arquivo `./modules/emr/variables.tf`:
    ```hcl
    variable "dataeng_private_subnet_id" {
      description = "Id da subnet privada"
      type        = string
    }

    variable "dataeng_bucket_name" {
      description = "Nome do bucket que vamos usar"
      type        = string
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/emr/outputs.tf`:
    ```hcl
    output "emr_cluster_id" {
      value = aws_emr_cluster.dataeng_emr.id
    }
    ```

5. Crie o script Python `clientes_spark_job.py` na pasta `/modules/emr/scripts/`:
    > **Atenção!** Edite o script para refletir o nome do seu bucket
    ```python
    import sys
    from awsglue.transforms import *
    from awsglue.utils import getResolvedOptions
    from pyspark.context import SparkContext
    from awsglue.context import GlueContext
    from awsglue.job import Job

    # Inicializa o contexto Spark e o contexto Glue
    sc = SparkContext()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)

    # Obtém as opções de execução
    args = getResolvedOptions(sys.argv, ['clientes_spark_job'])

    # Define o nome do job
    job.init(args['clientes_spark_job'], args)

    # Lê a tabela tb_raw_clientes do catálogo Glue
    datasource = glueContext.create_dynamic_frame.from_catalog(database = "dataeng-glue-database", table_name = "tb_raw_clientes")

    # Transformações nos dados
    # ...

    # Escreve a tabela tb_stage_clientes
    glueContext.write_dynamic_frame.from_catalog(frame = datasource, database = "dataeng-glue-database", table_name = "tb_stage_clientes")

    # Atualiza o catálogo Glue
    glueContext.catalog.refresh_table(database = "dataeng-glue-database", table_name = "tb_stage_clientes")

    # Finaliza o job
    job.commit()
    # Configuração do cluster EMR
    job.init(args['clientes_spark_job'], args, connection_args={"--conf": "spark.yarn.submit.waitAppCompletion=false"})
    job_run = job.run()

    # Aguarda a conclusão do job no cluster EMR
    job_run.wait_for_completion()
    ```

    Perceba que no script estamos fazendo referência a uma tabela `tb_stage_clientes` que não existe ainda. Mais adiante vamos adicionar o script para criá-la.

5. Criando a tabela `tb_stage_clientes`

  Adicione o trecho a seguir no arquivo `./modules/glue-catalog/main.tf`:
  ```hcl
  resource "aws_glue_catalog_table" "dataeng-glue-table-stage-clientes" {
      database_name = aws_glue_catalog_database.dataeng-glue-database.name
      name          = "tb_stage_clientes"
      table_type    = "EXTERNAL_TABLE"
      parameters = {
          classification = "parquet",
          "compressionType" = "snappy",
          "skip.header.line.count" = "0"
      }
      storage_descriptor {
          location = "s3://${var.bucket_name}/stage/clientes/"

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

6. Adicione o trecho abaixo ao arquivo `./modules/emr/main.tf`:
    ```hcl
    resource "aws_s3_object" "clientes_spark_job" {
        bucket = var.dataeng_bucket_name
        key    = "scripts/clientes_spark_job.py"
        source = "./modules/emr/scripts/clientes_spark_job.py"
    }
    ```

7. Adicione o seguinte conteúdo ao arquivo `./main.tf`:
  ```hcl
  module "emr" {
    source  = "./modules/emr"

    dataeng_private_subnet_id = module.vpc.public_subnet_id
    dataeng_bucket_name = module.s3.dataeng-bucket
  }
  ```

8. [OPCIONAL] Retire os trechos abaixo do arquivo `./main.tf`:

    Para os propósitos deste laboratório esses recursos não serão mais necessários.
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

9. Execute o Terraform:
    ```sh
    terraform init
    ```

    ```sh
    terraform plan
    ```

    ```sh
    terraform apply --auto-approve
    ```
10. Verifique a criação do arquivo parquet via console S3.

### Desafio 1: Criação da tabela `tb_stage_clientes` no AWS Glue Catalog.
É a sua vez! Utilizando o conhecimento adquirido nos módulos anteriores, crie via Terraform a tabela `tb_stage_clientes`.<br>
Valide que a criação ocorreu com sucesso via console AWS Athena.

### Desafio 2: Criação e execução de EMR Steps de pedidos
Utilizando os conhecimentos adquiridos anterioremente, crie o job `pedidos_spark_job`.
Abaixo segue um exemplo de criação do EMR Step no cluster.

1. Adicione o seguinte conteúdo ao arquivo `main.tf` para incluir os steps:
    ```hcl
    step {
      name = "Pedidos Spark Job"
      action_on_failure = "CONTINUE"
      hadoop_jar_step {
        jar = "command-runner.jar"
        args = ["spark-submit", "s3://${var.bucket_name}/scripts/pedidos_spark_job.py"]
      }
    }
    ```

2. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```
### Desafio 3: Criação da tabela `tb_stage_pedidos` no AWS Glue Catalog.
É a sua vez! Utilizando o conhecimento adquirido nas etapas anteriores, crie via Terraform a tabela `tb_stage_pedidos`.<br>
Valide que a criação ocorreu com sucesso via console AWS Athena.

## Parabéns
Você concluiu o módulo! Agora você sabe como criar um cluster EMR e configurar EMR Steps.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy
```

## Destruição seletiva dos recursos
```sh
terraform plan -destroy -target="module.emr.aws_emr_cluster.dataeng_emr" 
```

```sh
terraform destroy -target="module.emr.aws_emr_cluster.dataeng_emr" --auto-approve
```

## Referência
O modelo de camadas de armazenamento utilizado neste laboratório tem como base o **AWS Prescriptive Guidance** que pode ser encontrado [aqui](https://docs.aws.amazon.com/prescriptive-guidance/latest/defining-bucket-names-data-lakes/naming-structure-data-layers.html).
