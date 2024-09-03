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

### Exercício 1: Instalação do Terraform no AWS Cloud9

1. **Acesse o AWS Cloud9** e crie um novo ambiente de desenvolvimento com o sistema operacional Ubuntu.
2. **Abra o terminal** no Cloud9 e execute os comandos de instalação do Terraform mencionados na seção de teoria.
3. **Verifique a instalação** executando `terraform -v`.

### Exercício 2: Configuração inicial do Terraform com AWS Provider

1. **Crie um diretório de trabalho**:
    ```sh
    mkdir terraform-lab
    cd terraform-lab
    ```

2. **Crie um arquivo de configuração do Terraform**:
    ```sh
    touch main.tf
    ```

3. **Edite o arquivo `main.tf`** :
    ```sh
    nano main.tf
    ```

    Inclua o seguinte conteúdo:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_s3_bucket" "dataeng-bucket" {
        bucket_prefix = "dataeng-"
        force_destroy = true

        tags = {
            Name        = "dataeng-bucket"
            Environment = "Dev"
        }
    }
    ```

    Se utilizou no `nano` então utilize `Control+O` (letra O) para salvar e `Control+X` para fechar.

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

    Output esperado:
    ```
    ...
    Plan: 1 to add, 0 to change, 0 to destroy.
    aws_s3_bucket.dataeng-bucket: Creating...
    aws_s3_bucket.dataeng-bucket: Creation complete after 4s [id=dataeng-20240831140200859000000001]
    ```

    Perceba que o nome do bucket é informado na saída do comando.

7. **Verifique**:
    Acesse o console AWS S3 e verifique se o bucket foi criado como esperado.

### Exercício 3: Incluindo um objeto no S3
Para criação e gestão de objetos no S3, utilizamos `aws_s3_object`.

1. **Arquivo de exemplo**:<br>
    Vamos criar o arquivo `pombo.txt`:
    ```sh
    echo "pruuuuu" > pombo.txt
    ```

2. **Edite novamente o arquivo `main.tf`**:
    ```sh
    nano main.tf
    ```

    Copie o trecho a seguir e inclua ao final do arquivo `main.tf`:
    ```hcl

    resource "aws_s3_object" "pombo-object" {
        bucket = aws_s3_bucket.dataeng-bucket.id
        key    = "pombo.txt"
        source = "./pombo.txt"
    }
    ```

3. **Crie um plano de execução**:
    ```sh
    terraform plan
    ```

4. **Aplique o plano**:
    ```sh
    terraform apply --auto-approve
    ```
5. **Verifique**
    Abra o console AWS S3 e verifique se o arquivo foi criado corretamente.<br>
    Repare que não foi criado um novo bucket, apenas incluído o arquivo como esperado.

## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu os conceitos básicos do Terraform e como configurá-lo para trabalhar com a AWS.

## Destruição dos recursos
Para evitar custos desnecessários, destrua os recursos criados:
```sh
terraform destroy
```

### Destruição seletiva

A destruição seletiva de recursos no Terraform permite que você escolha quais recursos deseja destruir, em vez de destruir todos os recursos definidos no seu código.

Para realizar a destruição seletiva, você pode utilizar o comando `terraform destroy` seguido do argumento `-target` e o nome do recurso que deseja destruir. Por exemplo:

```sh
terraform destroy -target=aws_s3_object.pombo-object
```

Isso irá destruir apenas o recurso do bucket S3 chamado `pombo-object`, mantendo os demais recursos intactos.

Lembre-se de que a destruição seletiva deve ser usada com cuidado, pois pode levar a dependências não gerenciadas e a um estado inconsistente da infraestrutura. Certifique-se de entender completamente as implicações antes de executar a destruição seletiva.
