# Módulo 1: Introdução ao Terraform
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Teoria

### O que é Terraform?
Terraform é uma ferramenta de código aberto para construção, alteração e versionamento seguro e eficiente da infraestrutura. Ele é capaz de gerenciar provedores de serviços existentes e populares, bem como soluções internas personalizadas.

### Infraestrutura como Código (IaC)
Infraestrutura como Código (IaC) é a prática de gerenciar e provisionar recursos em data centers por meio de arquivos de definição legíveis por máquina, em vez de configuração física de hardware ou ferramentas de configuração interativas.

### Vantagens do uso de IaC (Infrastructure as Code)
- **Automação**: Reduz a necessidade de intervenção manual.
- **Consistência**: Garante que a infraestrutura seja configurada de maneira consistente.
- **Versionamento**: Permite rastrear mudanças na infraestrutura ao longo do tempo.
- **Escalabilidade**: Facilita a replicação de ambientes.

### Conceitos básicos: Providers, Resources, Modules, State
- **Providers**: São responsáveis por gerenciar os recursos. Exemplo: AWS, Azure, Google Cloud.
- **Resources**: São os componentes básicos que compõem a infraestrutura, como instâncias EC2, buckets S3, etc.
- **Modules**: São contêineres para múltiplos recursos que são usados juntos.
- **State**: Mantém o mapeamento dos recursos do mundo real para a configuração do Terraform.

### Instalação e configuração do Terraform
Para instalar o Terraform, siga os passos abaixo:

1. **Baixar o Terraform**:
    ```sh
    wget https://releases.hashicorp.com/terraform/1.9.4/terraform_1.9.4_linux_386.zip
    ```

2. **Descompactar o arquivo**:
    ```sh
    unzip terraform_1.9.4_linux_386.zip
    ```

3. **Mover o binário para o diretório de binários**:
    ```sh
    sudo mv terraform /usr/local/bin/
    ```

4. **Verificar a instalação**:
    ```sh
    terraform -v
    ```

## Laboratório

### Exercício Simples: Instalação do Terraform no AWS Cloud9

1. **Acesse o AWS Cloud9** e crie um novo ambiente de desenvolvimento com o sistema operacional Ubuntu.
2. **Abra o terminal** no Cloud9 e execute os comandos de instalação do Terraform mencionados na seção de teoria.
3. **Verifique a instalação** executando `terraform -v`.

### Exercício Avançado: Configuração inicial do Terraform com AWS Provider

1. **Crie um diretório de trabalho**:
    ```sh
    mkdir terraform-lab
    cd terraform-lab
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

    resource "aws_s3_bucket" "dataeng-modulo-1-bucket" {
      bucket = "dataeng-modulo-1-${random_string.suffix.result}"
      acl    = "private"

      tags = {
        Name        = "dataeng-modulo-1-bucket"
        Environment = "Dev"
      }
    }

    resource "random_string" "suffix" {
      length  = 6
      special = false
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

## Parabéns
Parabéns pela conclusão do módulo 1! Você aprendeu os conceitos básicos do Terraform e como configurá-lo para trabalhar com a AWS.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados:
```sh
terraform destroy
```
