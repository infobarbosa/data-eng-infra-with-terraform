# Módulo 1: Introdução ao Terraform
Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
Lembre-se de que a gestão dos custos dos recursos criados é de responsabilidade do aluno. Certifique-se de destruir todos os recursos ao final de cada exercício para evitar cobranças desnecessárias.

## Infraestrutura como Código (IaC)
Infraestrutura como Código (IaC) é a prática de gerenciar e provisionar recursos em data centers por meio de arquivos de definição legíveis por máquina, em vez de configuração física de hardware ou ferramentas de configuração interativas.

---

## Por que **engenheiros de dados** precisam entender de IaC?

![Engenheiro de dados em conflito](data-engineer-conflict.png)

Tradicionalmente, o provisionamento de infraestrutura era mesmo uma atribuição exclusiva de **engenheiros de infraestrutura, SREs ou DevOps**. Mas a realidade da engenharia de dados **moderna e cloud-native** transformou esse cenário.

Vamos a uma análise mais profunda, **estruturada em três eixos**: contexto da mudança, implicações na prática do engenheiro de dados, e os limites entre os papéis.


### 📈 1. **Mudança de paradigma: da separação à convergência**

Antigamente:

* Engenheiros de dados escreviam pipelines.
* Engenheiros de infraestrutura preparavam os ambientes.
* A coordenação era feita por times separados e com fluxos burocráticos.

Hoje:

* Com a **nuvem, IaC e self-service infrastructure**, a **provisão é parte essencial do ciclo de vida dos dados**.
* Muitos projetos de dados exigem recursos sob demanda, orquestração entre serviços cloud (S3, Glue, EMR, RDS, Lake Formation, etc.), **em ciclos que duram horas ou minutos**.
* O tempo entre *codar* e *provisionar* **precisa ser quase nulo** para suportar agilidade e experimentação.

> 💡 **Conclusão:** Em um mundo onde infraestrutura é elástica, programável e versionável, **o engenheiro de dados não pode mais ser cego à infraestrutura**. Ela virou parte do seu toolkit.

---

### 🧠 2. **A prática moderna do engenheiro de dados**

Hoje, os engenheiros de dados operam sobre um stack complexo, que **exige controle sobre a infraestrutura**, mesmo que intermediado por IaC.

#### Exemplos práticos que exigem Terraform:

* **Provisionar um cluster Spark (EMR) com configuração específica** para job de larga escala, ajustando parâmetros como spot instances, autoscaling, security groups.
* Criar **buckets S3 com políticas de versionamento, encriptação e VPC endpoint**, garantindo compliance com LGPD ou ISOs.
* Criar **Glue Crawlers, Glue Jobs e catalog tables**, alinhados a uma arquitetura de Data Lakehouse.
* Instanciar **roles e policies IAM temporárias** para jobs que acessam dados sensíveis.

Em todos os exemplos, a **relação entre o pipeline de dados e os recursos de infraestrutura é direta** — e muitas vezes o time de SRE nem está presente no dia a dia da squad.

> 💡 **Conclusão:** O engenheiro de dados que domina Terraform **ganha autonomia** para testar, escalar e entregar com mais segurança e governança.

---

### 🧭 3. **Onde começa e termina a responsabilidade do engenheiro de dados?**

É aqui que a maturidade organizacional entra:

| Situação                                                                      | Responsabilidade do Engenheiro de Dados                                                   |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Empresas com squads full-stack de dados (Data Mesh, por exemplo)              | Alta: o engenheiro é responsável pelo provisionamento dos recursos que seu *domínio* usa  |
| Equipes com SREs dedicados ao data stack                                      | Média: o engenheiro de dados escreve ou revisa os módulos Terraform junto com SREs        |
| Empresas com infraestrutura gerenciada (por terceiros ou devops centralizado) | Baixa: o engenheiro foca na definição declarativa dos recursos; alguém aplica o Terraform |

Mas mesmo nos cenários com baixo nível de responsabilidade operacional, **é esperado que o engenheiro de dados entenda e seja capaz de revisar o código IaC**, especialmente se trabalha com dados sensíveis, pipelines críticos ou arquiteturas serverless/auto-provisionadas.

> ⚠️ **Não se trata de substituir o SRE ou o DevOps**, mas de eliminar fricções entre código e infraestrutura **com segurança e rastreabilidade**.

---

### ✅ Em resumo

O engenheiro de dados **não precisa ser especialista em Terraform como um DevOps**, mas precisa:

* **Ler, entender e modificar** código Terraform;
* Criar e testar infraestrutura em ambientes de desenvolvimento;
* Trabalhar com módulos reutilizáveis, versionados e seguros;
* Garantir que seu pipeline seja **auditável, reproduzível e escalável**.

> 👉 **IaC virou parte do stack de engenharia de dados**, assim como SQL, Python, e Spark.

---

# O que é Terraform?
Terraform é uma ferramenta de código aberto para construção, alteração e versionamento seguro e eficiente da infraestrutura. Ele é capaz de gerenciar provedores de serviços existentes e populares, bem como soluções internas personalizadas.

### Vantagens do uso de IaC (Infrastructure as Code)
- **Automação**: Reduz a necessidade de intervenção manual.
- **Consistência**: Garante que a infraestrutura seja configurada de maneira consistente.
- **Versionamento**: Permite rastrear mudanças na infraestrutura ao longo do tempo.
- **Escalabilidade**: Facilita a replicação de ambientes.

### Conceitos básicos: Providers, Resources, Modules, State
- **Providers**: São plug-ins gerenciadores de recursos e que interagem com provedores de nuvem, ferramentas de terceiros e outras APIs. Exemplo: AWS, Azure, Google Cloud.
- **Resources**: São os componentes básicos que compõem a infraestrutura, como instâncias EC2, buckets S3, etc.
- **Modules**: são blocos de código independentes que são isolados e empacotados para reutilização.
- **State**: Mantém o mapeamento dos recursos do mundo real para a configuração do Terraform.

---

## Laboratório

### Exercício 1: Instalação do Terraform no AWS Cloud9
Para instalar o Terraform, siga os passos abaixo:
1. **Acesse o AWS Cloud9** e crie um novo ambiente de desenvolvimento com o sistema operacional Ubuntu.

2. **Abra o terminal** no Cloud9.

3. **Baixar o Terraform**:

    ```sh
    wget https://releases.hashicorp.com/terraform/1.11.2/terraform_1.11.2_linux_386.zip

    ```

4. **Descompactar o arquivo**:

    ```sh
    unzip terraform_1.11.2_linux_386.zip

    ``` 

5. **Mover o binário para o diretório de binários**:
    ```sh
    sudo mv terraform /usr/local/bin/

    ```

6. **Verificar a instalação**:
    ```sh
    terraform -v

    ```

---

### Exercício 2: Configuração inicial do Terraform com AWS Provider

1. **Crie** um diretório de trabalho:
    ```sh
    mkdir terraform-lab
    
    ```

    ```sh
    cd terraform-lab
    
    ```

2. **Crie** um arquivo de configuração do Terraform:
    ```sh
    touch main.tf
    
    ```

    **Adicione** o seguinte conteúdo ao arquivo `main.tf`:
    ```h
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_s3_bucket" "pombo_bucket" {
        bucket_prefix = "pombo-bucket-"
        force_destroy = true

        tags = {
            Name        = "pombo_bucket"
            Environment = "Dev"
        }
    }

    ```

3. **Inicialize o Terraform**:
    ```sh
    terraform init

    ```

4. **Crie um plano de execução**:
    ```sh
    terraform plan

    ```

5. **Aplique o plano**:
    ```sh
    terraform apply

    ```

    Perceba que o nome do bucket é informado na saída do comando.

6. **Verifique**:

    Acesse o console **AWS S3** e verifique se o bucket foi criado como esperado.<br>
    No terminal também é possível verificar:
    ```sh
    aws s3 ls

    ```

    ```sh
    aws s3 ls s3://<COLOQUE O NOME DO SEU BUCKET AQUI>

    ```

### Exercício 3: Incluindo um objeto no S3
Para criação e gestão de objetos no S3, utilizamos `aws_s3_object`.

1. **Arquivo de exemplo**:<br>
    Vamos criar o arquivo `pombo.txt`:
    ```sh
    echo "pruuuuu" > pombo.txt
    
    ```

2. **Adicione** o trecho a seguir no arquivo `main.tf`:
    ```h
    resource "aws_s3_object" "pombo_object" {
        bucket = aws_s3_bucket.pombo_bucket.id
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

    Você também pode utilizar o seguinte comando para checar:
    ```sh
    aws s3 ls s3://<O_NOME_DO_SEU_BUCKET_AQUI>/
    
    ```


---

### Exercício 4: Excluindo o recurso `pombo.txt`

Nesse exercício, vamos ver a gestão de estado do Terraform.<br>
Ao excluir um recurso


1. **Remova** o trecho a seguir no arquivo `main.tf`:
    ```h
    resource "aws_s3_object" "pombo_object" {
        bucket = aws_s3_bucket.pombo_bucket.id
        key    = "pombo.txt"
        source = "./pombo.txt"
    }

    ```

2. **Aplique o plano**:
    ```sh
    terraform apply --auto-approve
    
    ```

3. **Verifique**
    Abra o console AWS S3 e verifique se o arquivo foi excluído corretamente.<br>

    Você também pode utilizar o seguinte comando para checar:
    ```sh
    aws s3 ls s3://<O_NOME_DO_SEU_BUCKET_AQUI>/
    
    ```

---

## Destruição dos recursos
O comando `terraform destroy` tem por objetivo destruir todos os recursos gerenciados pelo Terraform que estão definidos no arquivo de configuração atual. Ele remove os recursos provisionados da infraestrutura, garantindo que não haja custos adicionais associados a eles.

```sh
terraform destroy --auto-approve

```

### Alerta! Uso do `terraform destroy` em ambientes de produção

O comando `terraform destroy` deve ser usado com extrema cautela em ambientes de produção. Ele remove todos os recursos gerenciados pelo Terraform, o que pode causar interrupções significativas nos serviços e perda de dados. Antes de executar este comando em produção, considere as seguintes práticas:

- **Backup**: Certifique-se de que todos os dados críticos estejam devidamente salvos e que backups estejam disponíveis.
- **Revisão**: Revise cuidadosamente o plano de destruição gerado pelo comando `terraform plan -destroy`.
- **Aprovação**: Obtenha aprovação formal de todas as partes interessadas antes de proceder.
- **Ambiente de Teste**: Sempre teste o comando em um ambiente de desenvolvimento ou staging antes de aplicá-lo em produção.
- **Automação**: Evite automatizar o uso de `terraform destroy` em pipelines de produção para prevenir execuções acidentais.

Lembre-se de que a destruição de recursos em produção pode ter impactos irreversíveis. Avalie alternativas, como a destruição seletiva ou a desativação manual de recursos, antes de optar por este comando.

### Destruição seletiva

A destruição seletiva de recursos no Terraform permite que você escolha quais recursos deseja destruir, em vez de destruir todos os recursos definidos no seu código.

Para realizar a destruição seletiva, você pode utilizar o comando `terraform destroy` seguido do argumento `-target` e o nome do recurso que deseja destruir. Por exemplo:

1. Destruir apenas o recurso `pombo_object`, mantendo os demais recursos intactos:
    ```sh
    terraform destroy -target=aws_s3_object.pombo_object

    ```

2. Destruir o bucket S3 `pombo_bucket`:
    ```sh
    terraform destroy -target=aws_s3_object.pombo_bucket

    ```


Lembre-se de que a destruição seletiva deve ser usada com cuidado, pois pode levar a dependências não gerenciadas e a um estado inconsistente da infraestrutura. Certifique-se de entender completamente as implicações antes de executar a destruição seletiva.


## Parabéns
Parabéns pela conclusão do módulo! Você aprendeu os conceitos básicos do Terraform e como configurá-lo para trabalhar com a AWS.

