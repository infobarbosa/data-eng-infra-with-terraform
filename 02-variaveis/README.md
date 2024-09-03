# Módulo 2: Variáveis no Terraform
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

### Arquivo `variables.tf`

O arquivo `variables.tf` é usado no Terraform para definir as variáveis que serão utilizadas na configuração do ambiente. Nele, você pode especificar o tipo de cada variável, sua descrição e um valor padrão, caso necessário.

Aqui está um exemplo completo de um arquivo `variables.tf` com cada tipo de variável:

```hcl
# Variável do tipo string
variable "region" {
  description = "A região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

# Variável do tipo number
variable "instance_count" {
  description = "Número de instâncias a serem criadas"
  type        = number
  default     = 2
}

# Variável do tipo boolean
variable "enable_logging" {
  description = "Habilitar ou desabilitar logging"
  type        = bool
  default     = true
}

# Variável do tipo list
variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Variável do tipo map
variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "dataeng"
  }
}

# Variável do tipo object
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

# Variável do tipo tuple
variable "subnet_ids" {
  description = "Lista de IDs de sub-rede"
  type        = tuple([string, string, string])
  default     = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
}
```

Neste exemplo, cada variável é definida com seu tipo, descrição e valor padrão. Essas variáveis podem ser utilizadas em outros arquivos de configuração do Terraform para parametrizar a criação dos recursos de acordo com suas necessidades.

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

## Outputs Values
O Terraform Outputs é uma funcionalidade do Terraform que permite definir e expor valores calculados ou informações relevantes sobre a infraestrutura provisionada. Esses valores podem ser utilizados por outros módulos ou recursos do Terraform, ou podem ser exibidos para o usuário final como informações úteis.

**Uso**:<br>
Os outputs são definidos no arquivo de configuração do Terraform usando a sintaxe "output". Cada output é composto por um nome e um valor, que pode ser uma expressão ou uma referência a um recurso existente. Os outputs podem ser referenciados em outros módulos ou recursos usando a sintaxe: <br>

  * `"${module.<nome_do_modulo>.<nome_do_output>}"`
 
  Exemplo:
  ```
  output "instance_ip" {
    value = aws_instance.dataeng-exemplo.public_ip
  }
  ```
 
  Neste exemplo, estamos definindo um output chamado "instance_ip" que retorna o endereço IP público de uma instância EC2 criada usando o provedor AWS. Esse valor pode ser utilizado em outros módulos ou recursos do Terraform.

## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu a utilizar as variáveis e outputs do Terraform.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy
```

