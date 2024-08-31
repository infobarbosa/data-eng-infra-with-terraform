# Módulo 2: Provisionamento de rede na AWS
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

## 1. VPC
O recurso `aws_vpc` é usado no Terraform para criar uma Virtual Private Cloud (VPC) na AWS. Uma VPC é uma rede virtual dedicada à sua conta AWS, onde você pode provisionar recursos como instâncias EC2, sub-redes, gateways de internet e muito mais. Ao criar um recurso `aws_vpc`, você precisa especificar o bloco CIDR da VPC, que define o intervalo de endereços IP disponíveis para os recursos dentro da VPC. Além disso, você pode adicionar tags para identificação e gerenciamento do recurso. Através do uso do Terraform, é possível automatizar a criação e configuração de VPCs de forma simples e escalável.

Exemplo:
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

## 2. Subnet pública
O recurso `aws_subnet` é usado no Terraform para criar uma subnet na AWS. Uma subnet é um segmento de uma VPC onde você pode agrupar recursos. Ela é definida por um bloco CIDR e está associada a uma VPC específica. A subnet pode ser configurada com várias propriedades, como o ID da VPC, o bloco CIDR, a zona de disponibilidade e tags para identificação e gerenciamento. <br>
Através do uso do recurso `aws_subnet`, é possível criar e gerenciar subnets de forma automatizada e escalável na infraestrutura da AWS.

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

## 3. Subnet privada
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

## 4. Internet Gateway
O recurso `aws_internet_gateway` é usado no Terraform para criar um gateway de internet na AWS. Esse gateway permite que as instâncias em uma VPC se comuniquem com a internet. Ele é associado à VPC e pode ser usado para rotear o tráfego de rede entre a VPC e a internet. O recurso pode ser configurado com tags para facilitar a identificação e gerenciamento.

```hcl
resource "aws_internet_gateway" "dataeng-igw" {
  vpc_id = aws_vpc.dataeng-vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}
```

## 5. Tabela de rotas para a subnet pública (route table)

 O recurso `aws_route_table` é usado para criar uma tabela de roteamento na AWS. <br>
 Uma tabela de roteamento é responsável por determinar para onde o tráfego de rede deve ser encaminhado.<br>
 Ela contém regras de roteamento que especificam os destinos e os gateways ou instâncias associados a esses destinos.<br>
 Com a tabela de roteamento, é possível controlar o fluxo de tráfego entre as sub-redes na sua infraestrutura de nuvem.<br>
 A tabela de roteamento é um componente essencial para a configuração de redes virtuais na AWS.

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

## 6. Associar a tabela de rotas à subnet pública
O recurso `aws_route_table_association` permite associar uma tabela de roteamento do Amazon Web Services (AWS) a uma sub-rede específica. Essa associação determina qual tabela de roteamento será usada para direcionar o tráfego de rede para a sub-rede correspondente. Ao utilizar esse recurso, é possível configurar de forma eficiente as rotas de rede para as sub-redes em uma infraestrutura na nuvem da AWS, garantindo a conectividade correta entre os recursos.

```hcl
resource "aws_route_table_association" "dataeng-public-association" {
  subnet_id      = aws_subnet.dataeng-public-subnet.id
  route_table_id = aws_route_table.dataeng-public-rt.id
}
```

## 7. Tabela de rotas para a subnet privada (private route table)
```hcl
resource "aws_route_table" "dataeng-private-rt" {
  vpc_id = aws_vpc.aws_vpc.dataeng-vpc.id.id
  tags = {
    Name = "dataeng-private-rt"
  }
}
```
## 8. Associar a tabela de rotas à subnet privada
```hcl
resource "aws_route_table_association" "dataeng-private-association" {
  subnet_id      = aws_subnet.dataeng-private-subnet.id
  route_table_id = aws_route_table.dataeng-private-rt.id
}
```

## 9. Outputs Values
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

Exemplos:
### 10.1 - Security Group para a Subnet Pública
```hcl
resource "aws_security_group" "dataeng-public-sg" {
  name        = "public-sg"
  description = "Security group para a subnet pública"
  vpc_id      = aws_vpc.aws_vpc.dataeng-vpc.id.id

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
```hcl
resource "aws_security_group" "dataeng-private-sg" {
  name        = "private-sg"
  description = "Security group para a subnet privada"
  vpc_id      = aws_vpc.aws_vpc.dataeng-vpc.id.id

  # Permitir tráfego de entrada HTTP da subnet pública
  ingress {
    description      = "Allow HTTP inbound traffic from public subnet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.dataeng-public-sg.cidr_block]
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
```hcl
output "dataeng-public-sg-id" {
  value = aws_security_group.dataeng-public-sg.id
}

output "dataeng-private-sgid" {
  value = aws_security_group.dataeng-private-sg.id
}
```


## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu a criar recursos de rede na AWS usando Terraform.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy
```

