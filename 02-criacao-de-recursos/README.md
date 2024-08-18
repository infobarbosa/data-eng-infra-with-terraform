# Módulo 2: Criação de Recursos Básicos na AWS
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Teoria

### Configuração do AWS Provider
Para configurar o AWS Provider, você precisa definir a região e as credenciais de acesso. Exemplo:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Criando um VPC, Subnets e Internet Gateway
- **VPC**: Virtual Private Cloud é uma rede virtual dedicada à sua conta AWS.
- **Subnets**: Segmentos de uma VPC onde você pode agrupar recursos.
- **Internet Gateway**: Permite que instâncias em uma VPC se comuniquem com a internet.

Exemplo de configuração:
```hcl
resource "aws_vpc" "dataeng-modulo-2-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dataeng-modulo-2-vpc"
  }
}

resource "aws_subnet" "dataeng-modulo-2-subnet" {
  vpc_id            = aws_vpc.dataeng-modulo-2-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-modulo-2-subnet"
  }
}

resource "aws_internet_gateway" "dataeng-modulo-2-igw" {
  vpc_id = aws_vpc.dataeng-modulo-2-vpc.id
  tags = {
    Name = "dataeng-modulo-2-igw"
  }
}
```

### Configuração de Security Groups
Security Groups atuam como firewalls virtuais para controlar o tráfego de entrada e saída das instâncias.

Exemplo de configuração:
```hcl
resource "aws_security_group" "dataeng-modulo-2-sg" {
  vpc_id = aws_vpc.dataeng-modulo-2-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-modulo-2-sg"
  }
}
```

### Variáveis no Terraform
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


### Utilizar outputs para exibir informações
Outputs permitem expor valores de configuração para uso posterior.

Exemplo de definição de outputs:
```hcl
output "vpc_id" {
  value = aws_vpc.dataeng-modulo-2-vpc.id
}
```

## Laboratório

### Exercício Simples: Criar um VPC e Subnet

1. **Crie um diretório de trabalho**:
    ```sh
    mkdir terraform-lab-modulo-2
    cd terraform-lab-modulo-2
    ```

2. **Crie um arquivo de configuração do Terraform**:
    ```sh
    touch main.tf
    ```

3. **Edite o arquivo `main.tf`** com o seguinte conteúdo:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_vpc" "dataeng-modulo-2-vpc" {
      cidr_block = "10.0.0.0/16"
      tags = {
        Name = "dataeng-modulo-2-vpc"
      }
    }

    resource "aws_subnet" "dataeng-modulo-2-subnet" {
      vpc_id            = aws_vpc.dataeng-modulo-2-vpc.id
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      tags = {
        Name = "dataeng-modulo-2-subnet"
      }
    }
    ```

4. **Inicialize o Terraform**:
    ```sh
    terraform init
    ```

5. **Crie um plano de execução**:
    ```sh
    terraform plan
    ```

6. **Aplique o plano**:
    ```sh
    terraform apply
    ```

### Exercício Avançado: Configurar Security Groups e Internet Gateway

1. **Edite o arquivo `main.tf`** para incluir a configuração de Security Groups e Internet Gateway:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_vpc" "dataeng-modulo-2-vpc" {
      cidr_block = "10.0.0.0/16"
      tags = {
        Name = "dataeng-modulo-2-vpc"
      }
    }

    resource "aws_subnet" "dataeng-modulo-2-subnet" {
      vpc_id            = aws_vpc.dataeng-modulo-2-vpc.id
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      tags = {
        Name = "dataeng-modulo-2-subnet"
      }
    }

    resource "aws_internet_gateway" "dataeng-modulo-2-igw" {
      vpc_id = aws_vpc.dataeng-modulo-2-vpc.id
      tags = {
        Name = "dataeng-modulo-2-igw"
      }
    }

    resource "aws_security_group" "dataeng-modulo-2-sg" {
      vpc_id = aws_vpc.dataeng-modulo-2-vpc.id

      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "dataeng-modulo-2-sg"
      }
    }
    ```

2. **Atualize o Terraform**:
    ```sh
    terraform apply
    ```

## Parabéns
Parabéns pela conclusão do módulo 2! Você aprendeu a criar recursos básicos na AWS usando Terraform.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy
```

```sh
terraform apply
```
