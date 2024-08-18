# Módulo 3: Módulos e Gerenciamento de Estado

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Introdução a Módulos
Módulos no Terraform são uma maneira de organizar e reutilizar código. Eles permitem que você agrupe recursos relacionados e os reutilize em diferentes partes da sua infraestrutura.

### O que é o State do Terraform?
O state é um arquivo que mapeia os recursos criados pelo Terraform com a configuração definida nos arquivos `.tf`. Ele é essencial para o funcionamento do Terraform, permitindo que ele saiba quais recursos já foram criados e quais precisam ser atualizados ou destruídos.

### Backend Remoto para State
O backend remoto permite que o state do Terraform seja armazenado em um local centralizado, como um bucket S3, facilitando o trabalho em equipe e a recuperação do state em caso de falhas.

## Laboratório

### Exercício Simples: Configurar Backend Remoto no S3

1. Crie um arquivo `backend.tf` com o seguinte conteúdo:
    ```hcl
    terraform {
      backend "s3" {
        bucket         = "dataeng-modulo-3-backend-<sufixo-aleatorio>"
        key            = "terraform/state"
        region         = "us-east-1"
        dynamodb_table = "terraform-lock"
      }
    }
    ```

2. Inicialize o Terraform:
    ```sh
    terraform init
    ```

### Exercício Avançado: Criar e utilizar Módulos para Glue Database e Glue Table

1. Crie a estrutura de pastas para o módulo Glue Database:
    ```
    glue-database/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── tables/
        ├── tb_raw_clientes.json
        └── tb_raw_pedidos.json
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
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
        columns = jsondecode(file("${path.module}/tables/tb_raw_clientes.json"))
        location = "s3://path-to-your-bucket/tb_raw_clientes/"
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        serde_info {
          serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          parameters = {
            "field.delim" = ","
          }
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
        columns = jsondecode(file("${path.module}/tables/tb_raw_pedidos.json"))
        location = "s3://path-to-your-bucket/tb_raw_pedidos/"
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        serde_info {
          serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          parameters = {
            "field.delim" = ","
          }
        }
      }
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "database_name" {
      description = "Nome do banco de dados Glue"
      type        = string
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
    ```hcl
    output "glue_database_name" {
      value = aws_glue_catalog_database.dataeng_modulo_3_db.name
    }
    ```

5. Crie os arquivos JSON para as tabelas:
    - `tb_raw_clientes.json`:
        ```json
        [
          { "Name": "id", "Type": "int" },
          { "Name": "nome", "Type": "string" },
          { "Name": "data_nasc", "Type": "date" },
          { "Name": "cpf", "Type": "string" },
          { "Name": "email", "Type": "string" }
        ]
        ```
    - `tb_raw_pedidos.json`:
        ```json
        [
          { "Name": "id_pedido", "Type": "string" },
          { "Name": "produto", "Type": "string" },
          { "Name": "valor_unitario", "Type": "float" },
          { "Name": "quantidade", "Type": "bigint" },
          { "Name": "data_criacao", "Type": "timestamp" },
          { "Name": "uf", "Type": "string" },
          { "Name": "id_cliente", "Type": "bigint" }
        ]
        ```

6. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 3! Agora você sabe como configurar o backend remoto para o state do Terraform e criar módulos reutilizáveis.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy
```