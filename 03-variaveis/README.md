# Módulo 3: Variáveis no Terraform
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Introdução
Variáveis permitem parametrizar a configuração do Terraform, tornando-a mais flexível e reutilizável.

Exemplo de definição e uso de variáveis:
```hcl
variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}
```
### Locals

As variáveis Locals no Terraform permitem definir valores intermediários que podem ser reutilizados em várias partes do código. Elas são úteis para evitar repetição de código e simplificar a leitura e manutenção do código.

Um exemplo simples de uso de variáveis Locals é a definição de um nome de recurso concatenando o nome do ambiente e o nome do projeto:

```hcl
locals {
  environment = "dev"
  project = "myproject"
  resource_name = "${local.environment}-${local.project}-resource"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = local.resource_name
  }
}
```

Neste exemplo, a variável Local `resource_name` é definida como a concatenação das variáveis `environment` e `project`. Em seguida, ela é utilizada como valor para a tag `Name` do recurso `aws_instance`. Isso permite que o nome do recurso seja automaticamente gerado com base nas variáveis definidas.

### Arquivo `variables.tfvars`

O arquivo `variables.tfvars` é usado no Terraform para definir os valores das variáveis em um formato de arquivo separado. Isso permite que você defina os valores das variáveis de forma mais organizada e fácil de gerenciar.

Exemplo de um arquivo `variables.tfvars`:

```hcl
region = "us-west-2"
instance_count = 3
enable_logging = false
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
tags = {
  Environment = "prod"
  Project = "myproject"
}
instance_config = {
  instance_type = "t3.medium"
  ami_id = "ami-0123456789abcdef0"
}
subnet_ids = ["subnet-0123456789abcdef0", "subnet-1234567890abcdef1", "subnet-234567890abcdef2"]
```

Para usar o arquivo `variables.tfvars`, você pode passá-lo como um argumento ao executar o comando `terraform apply` ou `terraform plan`, por exemplo:

```sh
terraform apply -var-file=variables.tfvars
```

Isso permitirá que o Terraform leia as variáveis definidas no arquivo `variables.tfvars` e as utilize durante a execução do plano ou aplicação.

Certifique-se de que o arquivo `variables.tfvars` esteja no mesmo diretório do seu arquivo de configuração do Terraform (geralmente chamado de `main.tf`).


### Exemplos de Tipos de Variáveis no Terraform

No Terraform, as variáveis podem ser de diferentes tipos. Aqui estão alguns exemplos:

#### String
```hcl
variable "region" {
  description = "A região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}
```

#### Number
```hcl
variable "instance_count" {
  description = "Número de instâncias a serem criadas"
  type        = number
  default     = 2
}
```

#### Boolean
```hcl
variable "enable_logging" {
  description = "Habilitar ou desabilitar logging"
  type        = bool
  default     = true
}
```

#### List
```hcl
variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
```

#### Map
```hcl
variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "dataeng"
  }
}
```

#### Object
```hcl
variable "instance_config" {
  description = "Configuração da instância"
  type = object({
    instance_type = string
    ami_id        = string
  })
  default = {
    instance_type = "t2.micro"
    ami_id        = "ami-0c55b159cbfafe1f0"
  }
}
```

#### Tuple
```hcl
variable "subnet_ids" {
  description = "Lista de IDs de sub-rede"
  type        = tuple([string, string, string])
  default     = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
}
```

## Parabéns
Parabéns pela conclusão do módulo 2! Você aprendeu a utilizar as variáveis do Terraform.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy
```

