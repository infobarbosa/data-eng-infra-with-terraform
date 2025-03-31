# Módulo 4: Provisionamento de rede na AWS
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Introdução
A infraestrutura de rede é um componente fundamental para o sucesso de qualquer projeto de engenharia de dados. Neste tutorial, vamos explorar como provisionar uma rede na AWS usando o Terraform. Você aprenderá a criar uma VPC, subnets, internet gateway e muito mais. Além disso, vamos abordar a configuração e a associação de tabelas de roteamento. Ao final, você terá os conhecimentos necessários para criar uma infraestrutura de rede escalável e automatizada na AWS. Vamos começar! 

### Conceitos
- **VPC**: Virtual Private Cloud é uma rede virtual dedicada à sua conta AWS.
- **Subnets**: Segmentos de uma VPC onde você pode agrupar recursos.
- **Internet Gateway**: Permite que instâncias em uma VPC se comuniquem com a internet.

---

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

---

## 2. VPC
O recurso `aws_vpc` é usado no Terraform para criar uma Virtual Private Cloud (VPC) na AWS. Uma VPC é uma rede virtual dedicada à sua conta AWS, onde você pode provisionar recursos como instâncias EC2, sub-redes, gateways de internet e muito mais. Ao criar um recurso `aws_vpc`, você precisa especificar o bloco CIDR da VPC, que define o intervalo de endereços IP disponíveis para os recursos dentro da VPC. Além disso, você pode adicionar tags para identificação e gerenciamento do recurso. Através do uso do Terraform, é possível automatizar a criação e configuração de VPCs de forma simples e escalável.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
# 2. VPC
resource "aws_vpc" "dataeng_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true  
  tags = {
    Name = "dataeng-vpc"
  }
}

```

---

## 3. Subnet pública
O recurso `aws_subnet` é usado no Terraform para criar uma subnet na AWS. Uma subnet é um segmento de uma VPC onde você pode agrupar recursos. Ela é definida por um bloco CIDR e está associada a uma VPC específica. A subnet pode ser configurada com várias propriedades, como o ID da VPC, o bloco CIDR, a zona de disponibilidade e tags para identificação e gerenciamento. <br>
Através do uso do recurso `aws_subnet`, é possível criar e gerenciar subnets de forma automatizada e escalável na infraestrutura da AWS.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
# 3. Subnet pública
resource "aws_subnet" "dataeng_public_subnet" {
  vpc_id            = aws_vpc.dataeng_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dataeng-public-subnet"
  }
}

```

---

## 4. Internet Gateway
O recurso `aws_internet_gateway` é usado no Terraform para criar um gateway de internet na AWS. Esse gateway permite que as instâncias em uma VPC se comuniquem com a internet. Ele é associado à VPC e pode ser usado para rotear o tráfego de rede entre a VPC e a internet. O recurso pode ser configurado com tags para facilitar a identificação e gerenciamento.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
# 4. Internet Gateway
resource "aws_internet_gateway" "dataeng_igw" {
  vpc_id = aws_vpc.dataeng_vpc.id
  tags = {
    Name = "dataeng-igw"
  }
}

```

---

## 5. Tabela de rotas para a subnet pública (route table)

O recurso `aws_route_table` é usado para criar uma tabela de roteamento na AWS. <br>
Uma tabela de roteamento é responsável por determinar para onde o tráfego de rede deve ser encaminhado.<br>
Ela contém regras de roteamento que especificam os destinos e os gateways ou instâncias associados a esses destinos.<br>
Com a tabela de roteamento, é possível controlar o fluxo de tráfego entre as sub-redes na sua infraestrutura de nuvem.<br>
A tabela de roteamento é um componente essencial para a configuração de redes virtuais na AWS.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```hcl
# 5. Tabela de rotas para a subnet pública (route table)
resource "aws_route_table" "dataeng_public_rt" {
  vpc_id = aws_vpc.dataeng_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dataeng_igw.id
  }
  tags = {
    Name = "dataeng-public-rt"
  }
}

```

---

## 6. Associar a tabela de rotas à subnet pública
O recurso `aws_route_table_association` permite associar uma tabela de roteamento do Amazon Web Services (AWS) a uma sub-rede específica. Essa associação determina qual tabela de roteamento será usada para direcionar o tráfego de rede para a sub-rede correspondente. Ao utilizar esse recurso, é possível configurar de forma eficiente as rotas de rede para as sub-redes em uma infraestrutura na nuvem da AWS, garantindo a conectividade correta entre os recursos.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:

```h
# 6. aws_route_table_association
resource "aws_route_table_association" "dataeng_public_association" {
  subnet_id      = aws_subnet.dataeng_public_subnet.id
  route_table_id = aws_route_table.dataeng_public_rt.id
}

```

---

## 7. Security Group
Security Groups atuam como firewalls virtuais para controlar o tráfego de entrada e saída das instâncias.

**Adicione** o trecho a seguir no arquivo `./modules/vpc/main.tf`:
```h
# 7. aws_security_group
# Primeiro security group
resource "aws_security_group" "dataeng_public_sg" {
  name        = "public-sg"
  description = "Security group para a subnet publica"
  vpc_id      = aws_vpc.dataeng_vpc.id

  # Permitir tráfego de entrada
  ingress {
    description      = "Allow inbound traffic"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24"]
  }

  # Permitir tráfego SSH de entrada
  ingress {
    description      = "Allow SSH inbound traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24"]
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

# Segundo security group
resource "aws_security_group" "dataeng_too_public_sg" {
  name        = "too-public-sg"
  description = "Security group para a subnet publica"
  vpc_id      = aws_vpc.dataeng_vpc.id

  # Permitir tráfego de entrada
  ingress {
    description      = "Allow inbound traffic"
    from_port        = 80
    to_port          = 80
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
    Name = "dataeng-too-public-sg"
  }
}

```

---

## 8. Outputs Values

**Adicione** o trecho a seguir no arquivo `./modules/vpc/outputs.tf`:
```
# 8. Outputs Values
# Output dos IDs dos recursos
output "vpc_id" {
  value = aws_vpc.dataeng_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.dataeng_public_subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.dataeng_igw.id
}

output "dataeng_public_sg_id" {
  value = aws_security_group.dataeng_public_sg.id
}

output "dataeng_too_public_sg_id" {
  value = aws_security_group.dataeng_too_public_sg.id
}

```

---

## 9. Defina o module em `./main.tf`
```hcl
# 9. Module VPC em `./main.tf`
module "vpc" {
  source  = "./modules/vpc"
}

```

---

## 13. Aplique o script
```sh
terraform init

```

```sh
terraform plan

```

```sh
terraform apply --auto-approve

```

---

## 14. Verifique
Abra o console AWS e verifique se todos os recursos foram criados como esperado.

Para verificar via terminal, siga os passos a seguir:
    
  - VPC
  ```sh
  aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dataeng-vpc" --query "Vpcs[*].VpcId" --output text
  
  ```

  - Subnet Pública
  ```sh
  aws ec2 describe-subnets --filters "Name=tag:Name,Values=dataeng-public-subnet" --query "Subnets[*].SubnetId" --output text


  ```

  - Internet Gateway
  ```sh
  aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=dataeng-igw" --query "InternetGateways[*].InternetGatewayId" --output text


  ```

  - Route Table (subnet pública)
  ```sh
  aws ec2 describe-route-tables --filters "Name=tag:Name,Values=dataeng-public-rt" --query "RouteTables[*].RouteTableId" --output text


  ```

  - Route Tables Association (subnet pública)
  ```sh
  aws ec2 describe-route-tables --filters "Name=tag:Name,Values=dataeng-public-rt" --query "RouteTables[*].Associations[*].RouteTableAssociationId" --output text


  ```

  - Security Groups
  ```sh
  aws ec2 describe-security-groups --filters "Name=tag:Name,Values=dataeng-public-sg" --query "SecurityGroups[*].GroupId" --output text

  ```

  #### Verificação com Localstack

  **Atenção!** Execute apenas se estiver utilizando Localstack

  - VPC
    ```sh
    aws ec2 --endpoint-url http://localhost:4566 describe-vpcs --filters "Name=tag:Name,Values=dataeng-vpc" --query "Vpcs[*].VpcId" --output text

    ```

  - Subnet Pública
    ```SH
    aws ec2 --endpoint-url http://localhost:4566 describe-subnets --filters "Name=tag:Name,Values=dataeng-public-subnet" --query "Subnets[*].SubnetId" --output text

    ```

  - Internet Gateway
    ```sh
    aws ec2 --endpoint-url http://localhost:4566 describe-internet-gateways --filters "Name=tag:Name,Values=dataeng-igw" --query "InternetGateways[*].InternetGatewayId" --output text
    
    ```

  - Route Table (subnet pública)
    ```sh
    aws ec2 --endpoint-url http://localhost:4566 describe-route-tables --filters "Name=tag:Name,Values=dataeng-public-rt" --query "RouteTables[*].RouteTableId" --output text
    
    ```

  - Route Tables Association (subnet pública)
    ```sh
    aws ec2 --endpoint-url http://localhost:4566 describe-route-tables --filters "Name=tag:Name,Values=dataeng-public-rt" --query "RouteTables[*].Associations[*].RouteTableAssociationId" --output text

    ```

  - Security Groups
    ```sh
    aws ec2 --endpoint-url http://localhost:4566 describe-security-groups --filters "Name=tag:Name,Values=dataeng-public-sg" --query "SecurityGroups[*].GroupId" --output text

    ```

---

## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu a criar recursos de rede na AWS usando Terraform.

---

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados: <br>

```sh
terraform destroy --auto-approve

```

### Destruição seletiva
Se você deseja destruir seletivamente os recursos criados neste arquivo, você pode usar os seguintes comandos:

**VPC**
```sh
terraform plan -destroy -target="module.vpc.aws_vpc.dataeng_vpc" 

```

```sh
terraform destroy -target="module.vpc.aws_vpc.dataeng_vpc" --auto-approve

```

**Subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_subnet.dataeng_public_subnet" 

```

```sh
terraform destroy -target="module.vpc.aws_subnet.dataeng_public_subnet" --auto-approve

```

**Internet Gateway**
```sh
terraform plan -destroy -target="module.vpc.aws_internet_gateway.dataeng_igw" 

```

```sh
terraform destroy -target="module.vpc.aws_internet_gateway.dataeng_igw" --auto-approve

```

**Tabela de rotas para a subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table.dataeng_public_rt" 

```

```sh
terraform destroy -target="module.vpc.aws_route_table.dataeng_public_rt" --auto-approve

```

**Associação da tabela de rotas à subnet pública**
```sh
terraform plan -destroy -target="module.vpc.aws_route_table_association.dataeng_public_association" 

```

```sh
terraform destroy -target="module.vpc.aws_route_table_association.dataeng_public_association" --auto-approve

```

**Security Group para a Subnet Pública**
```sh
terraform plan -destroy -target="module.vpc.aws_security_group.dataeng_public_sg" 

```

```sh
terraform destroy -target="module.vpc.aws_security_group.dataeng_public_sg" --auto-approve

```


