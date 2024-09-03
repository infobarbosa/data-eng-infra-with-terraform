# Módulo 4: Provisionamento de rede na AWS
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Introdução
A infraestrutura de rede é um componente fundamental para o sucesso de qualquer projeto de engenharia de dados. Neste tutorial, vamos explorar como provisionar uma rede na AWS usando o Terraform. Você aprenderá a criar uma VPC, subnets, internet gateway e muito mais. Além disso, vamos abordar a configuração do AWS Provider e a associação de tabelas de roteamento. Ao final, você terá os conhecimentos necessários para criar uma infraestrutura de rede escalável e automatizada na AWS. Vamos começar! 

### Configuração do AWS Provider
Para configurar o AWS Provider, você precisa definir a região e as credenciais de acesso.<br> 
Exemplo:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

A configuração para o AWS Provider pode ser derivada de várias fontes, que são aplicadas na seguinte ordem:

1. Parâmetros na configuração do provedor
2. Variáveis ​​de ambiente
3. Arquivos de credenciais compartilhadas
4. Arquivos de configuração compartilhados
5. Credenciais do contêiner
6. Credenciais do perfil da instância e região


### Criando um VPC, Subnets e Internet Gateway
- **VPC**: Virtual Private Cloud é uma rede virtual dedicada à sua conta AWS.
- **Subnets**: Segmentos de uma VPC onde você pode agrupar recursos.
- **Internet Gateway**: Permite que instâncias em uma VPC se comuniquem com a internet.

## 1. Estrutura de diretórios
  ```
  ├── main.tf
  ├── modules
  │   └── vpc
  │       ├── main.tf
  │       ├── outputs.tf
  │       └── variables.tf
  ```

  Crie a estrutura de diretórios:
  ```sh
  mkdir -p ./modules/vpc
  touch ./modules/vpc/main.tf
  touch ./modules/vpc/variables.tf
  touch ./modules/vpc/outputs.tf
  ```

## 2. VPC
O recurso `aws_vpc` é usado no Terraform para criar uma Virtual Private Cloud (VPC) na AWS. Uma VPC é uma rede virtual dedicada à sua conta AWS, onde você pode provisionar recursos como instâncias EC2, sub-redes, gateways de internet e muito mais. Ao criar um recurso `aws_vpc`, você precisa especificar o bloco CIDR da VPC, que define o intervalo de endereços IP disponíveis para os recursos dentro da VPC. Além disso, você pode adicionar tags para identificação e gerenciamento do recurso. Através do uso do Terraform, é possível automatizar a criação e configuração de VPCs de forma simples e escalável.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_vpc" "dataeng-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true  
  tags = {
    Name = "dataeng-vpc"
  }
}
```

## 3. Subnet pública
O recurso `aws_subnet` é usado no Terraform para criar uma subnet na AWS. Uma subnet é um segmento de uma VPC onde você pode agrupar recursos. Ela é definida por um bloco CIDR e está associada a uma VPC específica. A subnet pode ser configurada com várias propriedades, como o ID da VPC, o bloco CIDR, a zona de disponibilidade e tags para identificação e gerenciamento. <br>
Através do uso do recurso `aws_subnet`, é possível criar e gerenciar subnets de forma automatizada e escalável na infraestrutura da AWS.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_subnet" "dataeng-public-subnet" {
  vpc_id            = aws_vpc.dataeng-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-public-subnet"
  }
}
```

## 4. Subnet privada

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_subnet" "dataeng-private-subnet" {
  vpc_id            = aws_vpc.dataeng-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-private-subnet"
  }
}
```

## 5. Internet Gateway
O recurso `aws_internet_gateway` é usado no Terraform para criar um gateway de internet na AWS. Esse gateway permite que as instâncias em uma VPC se comuniquem com a internet. Ele é associado à VPC e pode ser usado para rotear o tráfego de rede entre a VPC e a internet. O recurso pode ser configurado com tags para facilitar a identificação e gerenciamento.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_internet_gateway" "dataeng-igw" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}
```

## 6. Tabela de rotas para a subnet pública (route table)

O recurso `aws_route_table` é usado para criar uma tabela de roteamento na AWS. <br>
Uma tabela de roteamento é responsável por determinar para onde o tráfego de rede deve ser encaminhado.<br>
Ela contém regras de roteamento que especificam os destinos e os gateways ou instâncias associados a esses destinos.<br>
Com a tabela de roteamento, é possível controlar o fluxo de tráfego entre as sub-redes na sua infraestrutura de nuvem.<br>
A tabela de roteamento é um componente essencial para a configuração de redes virtuais na AWS.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_route_table" "dataeng-public-rt" {
  vpc_id = aws_vpc.dataeng-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dataeng-igw.id
  }
  tags = {
    Name = "dataeng-public-rt"
  }
}
```

## 7. Associar a tabela de rotas à subnet pública
O recurso `aws_route_table_association` permite associar uma tabela de roteamento do Amazon Web Services (AWS) a uma sub-rede específica. Essa associação determina qual tabela de roteamento será usada para direcionar o tráfego de rede para a sub-rede correspondente. Ao utilizar esse recurso, é possível configurar de forma eficiente as rotas de rede para as sub-redes em uma infraestrutura na nuvem da AWS, garantindo a conectividade correta entre os recursos.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_route_table_association" "dataeng-public-association" {
  subnet_id      = aws_subnet.dataeng-public-subnet.id
  route_table_id = aws_route_table.dataeng-public-rt.id
}
```

## 8. Tabela de rotas para a subnet privada (private route table)

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_route_table" "dataeng-private-rt" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-private-rt"
  }
}
```
## 9. Associar a tabela de rotas à subnet privada

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_route_table_association" "dataeng-private-association" {
  subnet_id      = aws_subnet.dataeng-private-subnet.id
  route_table_id = aws_route_table.dataeng-private-rt.id
}
```

## 9. Outputs Values

**Adicione** o trecho a seguir no arquivo `./modules/vpc/outputs.tf`:
```
# Output dos IDs dos recursos
output "vpc_id" {
  value = aws_vpc.dataeng-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.dataeng-public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.dataeng-private-subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.dataeng-igw.id
}
```

## 10. Security Groups
Security Groups atuam como firewalls virtuais para controlar o tráfego de entrada e saída das instâncias.


### 10.1 - Security Group para a Subnet Pública

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_security_group" "dataeng-public-sg" {
  name        = "public-sg"
  description = "Security group para a subnet publica"
  vpc_id      = aws_vpc.dataeng-vpc.id

  # Permitir tráfego HTTP de entrada
  ingress {
    description      = "Allow HTTP inbound traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Permitir tráfego SSH de entrada
  ingress {
    description      = "Allow SSH inbound traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-public-sg"
  }
}
```

### 10.2 - Security Group para a Subnet Privada

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
resource "aws_security_group" "dataeng-private-sg" {
  name        = "dataeng-private-sg"
  description = "Security group para a subnet privada"
  vpc_id      = aws_vpc.dataeng-vpc.id

  # Permitir tráfego de entrada HTTP da subnet pública
  ingress {
    description      = "Allow HTTP inbound traffic from public subnet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.dataeng-public-subnet.cidr_block]
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataeng-private-sg"
  }
}
```

### 10.3 - Output dos IDs dos Security Groups

**Adicione** o trecho a seguir no arquivo `./modules/vpc/outputs.tf`:
```hcl
output "dataeng_public_sg_id" {
  value = aws_security_group.dataeng-public-sg.id
}

output "dataeng_private_sg_id" {
  value = aws_security_group.dataeng-private-sg.id
}
```
## 11. Defina o module em `./main.tf`
```hcl
module "vpc" {
  source  = "./modules/vpc"
}
```

## 12. Aplique o script
```sh
terraform plan
```

```sh
terraform apply --auto-approve
```

## 13. Verifique
Abra o console AWS e verifique se todos os recursos foram criados como esperado.

## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu a criar recursos de rede na AWS usando Terraform.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy
```

### Destruição seletiva
Se você deseja destruir seletivamente os recursos criados neste arquivo, você pode usar os seguintes comandos:

**VPC**
```sh
terraform plan -destroy -target="module.vpc.aws_vpc.dataeng-vpc" 
```

```sh
terraform destroy -target="module.vpc.aws_vpc.dataeng-vpc" --auto-approve
```

**Subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_subnet.dataeng-public-subnet" 
```

```sh
terraform destroy -target="module.vpc.aws_subnet.dataeng-public-subnet" --auto-approve
```

**Subnet privada**
```sh
terraform plan -destroy -target="module.vpc.aws_subnet.dataeng-private-subnet" 
```

```sh
terraform destroy -target="module.vpc.aws_subnet.dataeng-private-subnet" --auto-approve
```

**Internet Gateway**
```sh
terraform plan -destroy -target="module.vpc.aws_internet_gateway.dataeng-igw" 
```

```sh
terraform destroy -target="module.vpc.aws_internet_gateway.dataeng-igw" --auto-approve
```

**Tabela de rotas para a subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table.dataeng-public-rt" 
```

```sh
terraform destroy -target="module.vpc.aws_route_table.dataeng-public-rt" --auto-approve
```

**Associação da tabela de rotas à subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table_association.dataeng-public-association" 
```

```sh
terraform destroy -target="module.vpc.aws_route_table_association.dataeng-public-association" --auto-approve
```

**Tabela de rotas para a subnet privada**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table.dataeng-private-rt" 
```

```sh
terraform destroy -target="module.vpc.aws_route_table.dataeng-private-rt" --auto-approve
```

**Associação da tabela de rotas à subnet privada**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table_association.dataeng-private-association" 
```

```sh
terraform destroy -target="module.vpc.aws_route_table_association.dataeng-private-association" --auto-approve
```

**Security Group para a Subnet Pública**
```sh
terraform plan -destroy -target="module.vpc.aws_security_group.dataeng-public-sg" 
```

```sh
terraform destroy -target="module.vpc.aws_security_group.dataeng-public-sg" --auto-approve
```

**Security Group para a Subnet Privada**
```sh
terraform plan -destroy -target="module.vpc.aws_security_group.dataeng-private-sg" 
```

```sh
terraform destroy -target="module.vpc.aws_security_group.dataeng-private-sg" --auto-approve
```


