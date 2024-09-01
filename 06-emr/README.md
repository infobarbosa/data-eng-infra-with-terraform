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
    from pyspark.sql import SparkSession

    spark = SparkSession.builder.appName("CSV to Parquet").getOrCreate()

    BUCKET_NAME = "<<SUBSTITUA_AQUI_PELO_SEU_BUCKET>>"

    # Ler o arquivo CSV do S3
    df = spark.read.csv(f"s3://{BUCKET_NAME}/raw/clientes/", header=True, inferSchema=True)

    # Escrever o arquivo Parquet no S3
    df.write.parquet(f"s3://{BUCKET_NAME}/stage/clientes/")

    #####ADICIONAR O CÓDIGO PARA ATUALIZAÇÃO DO CATÁLOGO DE DADOS!######

    spark.stop()
    ```

    Perceba que você ainda precisa editar o script para inserir o nome do bucket. Mais adiante vamos aprender a tornar esse parâmetro configurável. ;)

5. Adicione o trecho abaixo ao arquivo `./modules/emr/main.tf`:
    ```hcl
    resource "aws_s3_object" "clientes_spark_job" {
        bucket = var.dataeng_bucket_name
        key    = "scripts/clientes_spark_job.py"
        source = "./modules/emr/scripts/clientes_spark_job.py"
    }
    ```

6. Adicione o seguinte conteúdo ao arquivo `./main.tf`:
  ```hcl
  module "emr-cluster" {
    source  = "./modules/emr"

    dataeng_private_subnet_id = module.vpc.public_subnet_id
    dataeng_bucket_name = module.s3.dataeng-bucket
  }
  ```

7. [OPCIONAL] Retire os trechos abaixo do arquivo `./main.tf`:

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

8. Execute o Terraform:
    ```sh
    terraform init
    ```

    ```sh
    terraform plan
    ```

    ```sh
    terraform apply --auto-approve
    ```
8. Verifique a criação do arquivo parquet via console S3.

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

## Referência
O modelo de camadas de armazenamento utilizado neste laboratório tem como base o **AWS Prescriptive Guidance** que pode ser encontrado [aqui](https://docs.aws.amazon.com/prescriptive-guidance/latest/defining-bucket-names-data-lakes/naming-structure-data-layers.html).
