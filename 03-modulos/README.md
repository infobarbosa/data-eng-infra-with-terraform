# Módulo 3: Módulos no Terraform

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

O arquivo `./modules/vpc/main.tf`
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

## Laboratório

### Exercício 1: Refatorar os recursos de S3 em seu próprio módulo

  ```
  ├── main.tf
  ├── modules
  │   ├── s3
  │   │   ├── main.tf
  │   │   ├── outputs.tf
  │   │   └── variables.tf

  ```

1. **Crie** a estrutura de diretórios:
    ```sh
    mkdir -p ./modules/s3
    touch ./modules/s3/main.tf
    touch ./modules/s3/variables.tf
    touch ./modules/s3/outputs.tf

    ```

2. **Adicione** o trecho a seguir em **`./modules/s3/main.tf`** :
    ```hcl
    resource "aws_s3_bucket" "dataeng_bucket" {
        bucket = "dataeng-${var.dataeng_turma}-${var.dataeng_account_id}"
        force_destroy = true

        tags = {
            Name        = "dataeng_bucket"
            Environment = "Dev"
        }
    }

    ```
3. **Adicione** o trecho a seguir no arquivo **`./modules/s3/variables.tf`**.
    ```hcl
    variable "dataeng_turma" {
        description = "O identificador da sua turma em letras minusculas, sem espaços ou caracteres especiais"
        type        = string
    }

    variable "dataeng_account_id" {
        description = "O account id"
        type        = string
    }

    ```

4. **Adicione** o trecho a seguir no arquivo **`./modules/s3/outputs.tf`**.
    ```hcl
    output "dataeng_bucket" {
        description = "O nome do bucket S3"
        value = aws_s3_bucket.dataeng_bucket.bucket
    }

    output "dataeng_bucket_arn" {
        description = "O ARN do bucket S3"
        value = aws_s3_bucket.dataeng_bucket.arn
    }

    ```

5. **Adicione** o trecho a seguir no **início** do arquivo **`./main.tf`**:
    ```hcl
    data "aws_caller_identity" "current" {}

    locals {
        dataeng_account_id = data.aws_caller_identity.current.account_id
        dataeng_turma = "<<SUBSTITUA PELA SUA TURMA EM LETRAS MINUSCULAS>>"
    }

    ```

6. **Adicione** o trecho a seguir no **final** do arquivo **`./main.tf`**:
    ```hcl
    module "s3" {
      source  = "./modules/s3"
      dataeng_account_id = local.dataeng_account_id
      dataeng_turma = local.dataeng_turma
    }

    ```

7. **Remova** o recurso `pombo_bucket` de **`./main.tf`**:
    ```hcl
    resource "aws_s3_bucket" "pombo_bucket" {
      ...
    }

    ```

    **Remova** também o recurso `pombo_object`:
    ```hcl
    resource "aws_s3_object" "pombo_object" {
      ...
    }

    ```

8. **Inicialize** o módulo:
    ```sh
    terraform init

    ```

9. **Crie** um plano de execução:
    ```sh
    terraform plan

    ```

10. **Aplique o plano**:
    ```sh
    terraform apply --auto-approve

    ```

11. **Verifique**
    ```sh
    aws s3 ls

    ```
        
### Exercício 2: Incluindo objetos **úteis** no S3

Nesta etapa vamos fazer o download de dois datasets que vamos utilizar ao longo do curso.<br>
Uma vez baixados, vamos criar os objetos no nosso bucket S3 utilizando o recurso `aws_s3_object`.

1. **Faça o clone** dos repositórios a seguir:<br>
    ```sh
    git clone https://github.com/infobarbosa/datasets-csv-clientes

    ```

    ```sh
    git clone https://github.com/infobarbosa/datasets-csv-pedidos

    ```

2. **Edite** o arquivo `./modules/s3/main.tf`:

    Adicione o trecho a seguir ao final do arquivo:
    ```hcl

    resource "aws_s3_object" "dataset_clientes" {
        bucket = aws_s3_bucket.dataeng_bucket.id
        key    = "raw/clientes/clientes.csv.gz"
        source = "./datasets-csv-clientes/clientes.csv.gz"
    }

    ```

3. **Crie** um plano de execução:
    ```sh
    terraform plan

    ```

4. **Aplique o plano**:
    ```sh
    terraform apply --auto-approve

    ```
5. **Verifique**
    Abra o **console AWS S3** e verifique se o arquivo foi criado corretamente.<br>
    Repare que não foi criado um novo bucket, apenas incluído o arquivo como esperado.

    Para verificar via terminal, siga o seguinte procedimento:
    
    - Exporte a variável de ambiente `DATAENG_BUCKET`
    ```sh
    export DATAENG_BUCKET=$(aws s3 ls | awk '{print $3}' | grep '^dataeng-' | head -n 1)

    ``` 

    - Verifique se a variável foi criada corretamente:
    ```sh
    echo $DATAENG_BUCKET
    
    ```

    - Execute o comando a seguir:
    ```sh
    aws s3 ls "s3://${DATAENG_BUCKET}/raw/clientes/"

    ```

---

### Exercício 3 - Upload do objeto `pedidos-2024-01-01.csv.gz`
Agora é com você! Utilizando o conhecimento dos exercícios anteriores, altere o arquivo `./modules/s3/main.tf` para fazer o upload do arquivo `./datasets-csv-pedidos/pedidos-2024-01-01.csv.gz` para a pasta `raw/pedidos/` no bucket que criamos.

---

## Parabéns
Você concluiu o módulo! Agora você sabe como criar módulos reutilizáveis no Terraform.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy --auto-approve

```

## Destruição Seletiva

Para destruir seletivamente os recursos criados neste módulo, execute os seguintes comandos:

1. Destruição do bucket S3:
    ```sh
    terraform destroy -target=module.s3.aws_s3_bucket.dataeng_bucket

    ```

2. Destruição dos objetos no bucket S3:
    ```sh
    terraform destroy -target=module.s3.aws_s3_object.dataset_clientes

    ```
