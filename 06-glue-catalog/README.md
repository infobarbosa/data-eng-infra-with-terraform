# Módulo 6: Glue Catalog

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Introdução ao AWS Glue Catalog

O AWS Glue Catalog é um serviço de metadados totalmente gerenciado que facilita a descoberta, organização e consulta de dados em várias fontes de dados. Ele fornece um catálogo centralizado onde você pode registrar e gerenciar metadados de tabelas, partições e esquemas de dados.

Com o AWS Glue Catalog, você pode criar e gerenciar bancos de dados, tabelas e partições, além de definir esquemas de dados para suas fontes de dados. Ele também oferece recursos de descoberta de dados, permitindo que você pesquise e navegue pelos metadados armazenados no catálogo.

Além disso, o AWS Glue Catalog é integrado a outros serviços da AWS, como o AWS Glue, que permite a execução de ETL (Extração, Transformação e Carga) em seus dados, e o Amazon Athena, que permite a consulta interativa de dados usando SQL padrão.

Com o AWS Glue Catalog, você pode organizar e estruturar seus dados de forma eficiente, facilitando a análise e o processamento de dados em escala. Ele oferece uma solução completa para gerenciar metadados e simplificar a descoberta e o acesso aos seus dados.

### Glue Database

O AWS Glue Database é um recurso do AWS Glue Catalog que permite criar e gerenciar bancos de dados para organizar e estruturar seus metadados de tabelas e esquemas de dados. Com o Glue Database, você pode agrupar tabelas relacionadas em um único banco de dados, facilitando a organização e a consulta dos dados.

Exemplo:
```hcl
resource "aws_glue_catalog_database" "example_database" {
  name = "dataeng_db"
}
```

### Glue Table

O AWS Glue Table é um recurso do AWS Glue Catalog que representa uma tabela de dados em um banco de dados. Uma tabela contém informações sobre a estrutura dos dados, como colunas, tipos de dados, localização física e outros metadados relevantes.

Exemplo:
```hcl
resource "aws_glue_catalog_table" "example_table" {
  database_name = "dataeng_db"
  name          = "dataeng_tb"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    classification = "parquet",
    "compressionType" = "snappy",
    "skip.header.line.count" = "1"
  }
  storage_descriptor {
    location = "s3://qualquer-bucket/data/"
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed = false
    number_of_buckets = -1
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
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
        name = "idade"
        type = "int"
    }
  } 
}
```

### Laboratório

#### Exercício 1: Criar e utilizar o módulo `glue-catalog`

Neste exercício vamos criar dois recursos importantes para o nosso projeto: Glue Database e Glue Table

**Referência**: [Glue Catalog](https://docs.aws.amazon.com/prescriptive-guidance/latest/serverless-etl-aws-glue/aws-glue-data-catalog.html)

1. Crie a estrutura de pastas para o módulo `glue-catalog`:
    ```
    ├── main.tf
    ├── modules
    │   ├── glue-catalog
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    ```

    ```sh
    mkdir -p ./modules/glue-catalog
    touch ./modules/glue-catalog/main.tf
    touch ./modules/glue-catalog/variables.tf
    touch ./modules/glue-catalog/outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `./main.tf`:
    ```hcl
    # 2. module glue-catalog
    module "glue-catalog" {
      source  = "./modules/glue-catalog"

      dataeng_database_name = "dataengdb"
      dataeng_bucket_name   = module.s3.dataeng-bucket
    }
    ```
3. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/main.tf`:
    ```hcl
    # 3.1. dataeng-glue-database
    resource "aws_glue_catalog_database" "dataeng-glue-database" {
      name = var.dataeng_database_name
    }

    # 3.2. dataeng-glue-table-clientes
    resource "aws_glue_catalog_table" "dataeng-glue-table-clientes" {
      database_name = aws_glue_catalog_database.dataeng-glue-database.name
      name          = "tb_raw_clientes"
      table_type    = "EXTERNAL_TABLE"
      parameters = {
        classification = "csv",
        "compressionType" = "gzip",
        "skip.header.line.count" = "1"
      }
      storage_descriptor {
        location = "s3://${var.dataeng_bucket_name}/raw/clientes/"
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

    ```

4. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/variables.tf`:
    ```hcl
    # 4. ./modules/glue-catalog/variables.tf
    variable "dataeng_database_name" {
      description = "O nome do database no Glue Catalog"
      type        = string
    }

    variable "dataeng_bucket_name" {
      description = "O nome do bucket no AWS S3"
      type        = string
    }
    ```

5. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/outputs.tf`:
    ```hcl
    # 5. ./modules/glue-catalog/outputs.tf
    output "glue_database_name" {
      value = aws_glue_catalog_database.dataeng-glue-database.name
    }
    ```

6. Execute o Terraform no diretório raiz:
    ```sh
    terraform init
    ```

    ```sh
    terraform apply --auto-approve
    ```

7. Verifique no Athena se a tabela foi criada como esperado.

## Desafio
Execute novamente o exercício anterior, desta vez crie a tabela `tb_raw_pedidos`.
Os tipos das colunas:

| Atributo        | Tipo      | Obs                                               | 
| ---             | ---       | ---                                               |
| ID_PEDIDO       | string    | O identificador da pessoa                         | 
| PRODUTO         | string    | O nome do produto no pedido                       | 
| VALOR_UNITARIO  | float     | O valor unitário do produto no pedido             | 
| QUANTIDADE      | bigint    | A quantidade do produto no pedido                 | 
| DATA_CRIACAO    | timestamp | A data da criação do pedido                       | 
| UF              | string    | A sigla da unidade federativa (estado) no Brasil  | 
| ID_CLIENTE      | bigint    | O identificador do cliente                        | 

A seguir está o template:
```hcl
    resource "aws_glue_catalog_table" "dataeng-glue-table-pedidos" {
      database_name = <AJUSTE_AQUI>
      name          = <AJUSTE_AQUI>
      table_type    = "EXTERNAL_TABLE"
      parameters = {
        classification = <AJUSTE_AQUI>,
        "compressionType" = <AJUSTE_AQUI>,
        "skip.header.line.count" = <AJUSTE_AQUI>
      }
      storage_descriptor {
        location = <AJUSTE_AQUI>
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        ser_de_info {
          serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          parameters = {
            "field.delim" = "<AJUSTE_AQUI>"
          }
        }
        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }      

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }

        columns {
            name = "<AJUSTE_AQUI>"
            type = "<AJUSTE_AQUI>"
        }  
      } 
    }

```
## Solução do desafio
<details>
  <summary>Clique aqui</summary>
  
  ```hcl
        resource "aws_glue_catalog_table" "dataeng-glue-table-pedidos" {
          database_name = aws_glue_catalog_database.dataeng-glue-database.name
          name          = "tb_raw_pedidos"
          table_type    = "EXTERNAL_TABLE"
          parameters = {
            classification = "csv",
            "compressionType" = "gzip",
            "skip.header.line.count" = "1"
          }
          storage_descriptor {
            location = "s3://${var.dataeng_bucket_name}/raw/pedidos/"
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
</details>

Não esqueça de verificar o resultado no AWS Athena. ;)

## Parabéns
Você concluiu o módulo! Agora você sabe como criar recursos do AWS Glue via Terraform.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy --auto-approve
```

### Destruição seletiva

Para destruir seletivamente os recursos criados pelo Terraform neste arquivo, você pode utilizar os seguintes comandos:

1. Para destruir apenas o módulo `glue-catalog` e seus recursos associados, execute o seguinte comando:
  ```sh
  terraform destroy -target="module.glue-catalog.aws_glue_catalog_database.dataeng-glue-database" --auto-approve
  ```

2. Para destruir apenas a tabela `tb_raw_clientes`, execute o seguinte comando:
  ```sh
  terraform destroy -target=module.glue-catalog.aws_glue_catalog_table.dataeng-glue-table-clientes --auto-approve
  ```

Certifique-se de revisar cuidadosamente os recursos que serão destruídos antes de executar esses comandos, pois eles não podem ser desfeitos.