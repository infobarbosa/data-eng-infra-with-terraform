# Módulo 4: Módulos

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Módulos do Terraform
Módulos no Terraform são uma maneira de organizar e reutilizar código. Eles permitem que você agrupe recursos relacionados e os reutilize em diferentes partes da sua infraestrutura.

Para criar um módulo Terraform, você deve seguir os seguintes passos:

1. Crie uma estrutura de diretórios para o seu módulo, com um arquivo `main.tf`, um arquivo `variables.tf` e um arquivo `outputs.tf`.
2. No arquivo `main.tf`, defina os recursos que serão criados pelo módulo.
3. No arquivo `variables.tf`, defina as variáveis que serão utilizadas pelo módulo.
4. No arquivo `outputs.tf`, defina as saídas que serão retornadas pelo módulo.
5. Utilize o módulo em outros arquivos Terraform, referenciando-o com a diretiva `module`.
6. Passe os valores das variáveis necessárias para o módulo através dos argumentos da diretiva `module`.
7. Utilize as saídas do módulo conforme necessário nos outros arquivos Terraform.

Dessa forma, você poderá criar e reutilizar módulos Terraform para organizar e simplificar o seu código.

Exemplo:

A estrutura de diretórios:
```
├── main.tf
├── modules
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
```

O arquivo `./modules/vpc/main.tf
```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

...
# outros recursos
```

No arquivo `main.tf` (diretório principal), você faria referência ao módulo VPC da seguinte forma:

```hcl
module "vpc" {
  source  = "./modules/vpc"

  // Especifique quaisquer variáveis necessárias para o módulo VPC aqui
}
```

### Laboratório

#### Exercício 1: Refatorar os recursos de rede em seu próprio módulo
    ```
    ├── main.tf
    ├── modules
    │   └── vpc
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ```

#### Exercício 2: Refatorar os recursos de S3 em seu próprio módulo
    ```
    ├── main.tf
    ├── modules
    │   ├── s3
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── vpc
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ```

  Adicione o trecho a seguir no arquivo `./modules/s3/outputs.tf`.
  ```hcl
  output "dataeng-bucket" {
      value = aws_s3_bucket.dataeng-bucket.bucket
  }
  ```
#### Exercício 3: Criar e utilizar Módulos para Glue Database e Glue Table

**Referência**: [Glue Catalog](https://docs.aws.amazon.com/prescriptive-guidance/latest/serverless-etl-aws-glue/aws-glue-data-catalog.html)

1. Crie a estrutura de pastas para o módulo `glue-catalog`:
    ```
    ├── main.tf
    ├── modules
    │   ├── glue-catalog
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── s3
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── vpc
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ```

    ```sh
    mkdir -p ./modules/glue-catalog
    touch ./modules/glue-catalog/main.tf
    touch ./modules/glue-catalog/variables.tf
    touch ./modules/glue-catalog/outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `./main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    module "glue-catalog" {
      source  = "./modules/glue-catalog"

      database_name = "dataeng-glue-database"
    }
    ```
4. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/main.tf`:
    ```hcl
    resource "aws_glue_catalog_database" "dataeng-glue-database" {
      name = var.database_name
    }

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
        location = "s3://<ALTERE_AQUI_PARA_O_NOME_DO_SEU_BUCKET>/raw/clientes/"
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

5. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/variables.tf`:
    ```hcl
    variable "database_name" {
      description = "The name of the Glue database"
      type        = string
    }

    variable "bucket_name" {
      description = "The name of the S3 bucket"
      type        = string
    }
    ```

6. Adicione o seguinte conteúdo ao arquivo `./modules/glue-catalog/outputs.tf`:
    ```hcl
    output "glue_database_name" {
      value = aws_glue_catalog_database.dataeng-glue-database.name
    }
    ```

7. Execute o Terraform no diretório raiz:
    ```sh
    terraform init
    ```

    ```sh
    terraform apply --auto-approve
    ```

8. Verifique no Athena se a tabela foi criada como esperado.

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
            location = "s3://<ALTERE_AQUI_PARA_O_NOME_DO_SEU_BUCKET>/raw/pedidos/"
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
Você concluiu o módulo! Agora você sabe como criar módulos reutilizáveis no Terraform.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy
```