# Módulo 3: Módulos e Gerenciamento de Estado

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## State do Terraform
O state é um arquivo que mapeia os recursos criados pelo Terraform com a configuração definida nos arquivos `.tf`. Ele é essencial para o funcionamento do Terraform, permitindo que ele saiba quais recursos já foram criados e quais precisam ser atualizados ou destruídos.

### Backend Remoto para State
O backend remoto permite que o state do Terraform seja armazenado em um local centralizado, como um bucket S3, facilitando o trabalho em equipe e a recuperação do state em caso de falhas.

### Laboratório

#### Exercício 1: Configurar Backend Remoto no S3

1. Crie um bucket no S3 via Console com nome `dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>`.
2. Crie uma tabela no DynamoDB via Console AWS com nome `dataeng-modulo-3-backend-terraform-lock`.
3. Crie um arquivo `backend.tf` com o seguinte conteúdo:
    ```hcl
    terraform {
      backend "s3" {
        bucket         = "dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>"
        key            = "terraform/state"
        region         = "us-east-1"
        dynamodb_table = "dataeng-modulo-3-backend-terraform-lock"
      }
    }
    ```

4. Inicialize o Terraform:
    ```sh
    terraform init
    ```

## Módulos do Terraform
Módulos no Terraform são uma maneira de organizar e reutilizar código. Eles permitem que você agrupe recursos relacionados e os reutilize em diferentes partes da sua infraestrutura.

### Laboratório

#### Exercício 2: Criar e utilizar Módulos para Glue Database e Glue Table
1. Navegue para o diterório `03-modulos-e-gerenciamento-de-estado/modulos/`
2. Crie a estrutura de pastas para o módulo Glue Database:
    ```
    ├── main.tf
    ├── modules
    │   └── glue-catalog
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── terraform.tfstate
    └── terraform.tfstate.backup
    ```
3. Adicione o seguinte conteúdo ao arquivo `./main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    module "glue-catalog" {
      source  = "./modules/glue-catalog"

      database_name = "dataeng-modulo-3-glue-database"
    }
    ```
4. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/main.tf`:
    ```hcl
    resource "aws_glue_catalog_database" "dataeng_modulo_3_db" {
      name = var.database_name
    }

    resource "aws_glue_catalog_table" "dataeng_modulo_3_tb_clientes" {
      database_name = aws_glue_catalog_database.dataeng_modulo_3_db.name
      name          = "tb_raw_clientes"
      table_type    = "EXTERNAL_TABLE"
      parameters = {
        classification = "csv"
      }
      storage_descriptor {
        location = "s3://path-to-your-bucket/tb_raw_clientes/"
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        ser_de_info {
          serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          parameters = {
            "field.delim" = ";"
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

    resource "aws_glue_catalog_table" "dataeng_modulo_3_tb_pedidos" {
      database_name = aws_glue_catalog_database.dataeng_modulo_3_db.name
      name          = "tb_raw_pedidos"
      table_type    = "EXTERNAL_TABLE"
      parameters = {
        classification = "csv"
      }
      storage_descriptor {
        location = "s3://path-to-your-bucket/tb_raw_pedidos/"
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        ser_de_info {
          serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          parameters = {
            "field.delim" = ";"
          }
        }
        columns {
            name = "id_pedido"
            type = "string"
        }

        columns {
            name = "produto"
            type = "string"
        }

        columns {
            name = "valor_unitario"
            type = "float"
        }

        columns {
            name = "quantidade"
            type = "bigint"
        }

        columns {
            name = "data_criacao"
            type = "timestamp"
        }      

        columns {
            name = "uf"
            type = "string"
        }

        columns {
            name = "id_cliente"
            type = "bigint"
        }  
      } 
    }
    ```

5. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/variables.tf`:
    ```hcl
    variable "database_name" {
      description = "Nome do banco de dados Glue"
      type        = string
    }
    ```

6. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/outputs.tf`:
    ```hcl
    output "glue_database_name" {
      value = aws_glue_catalog_database.dataeng_modulo_3_db.name
    }
    ```

7. Execute o Terraform no diretório raiz:
    ```sh
    terraform init
    ```

    ```sh
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 3! Agora você sabe como configurar o backend remoto para o state do Terraform e criar módulos reutilizáveis.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy
```