# Módulo 3: Gerenciamento de Estado

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## State do Terraform
O state é um arquivo que mapeia os recursos criados pelo Terraform com a configuração definida nos arquivos `.tf`. Ele é essencial para o funcionamento do Terraform, permitindo que ele saiba quais recursos já foram criados e quais precisam ser atualizados ou destruídos.

### Backend Remoto para State
O backend remoto permite que o state do Terraform seja armazenado em um local centralizado, como um bucket S3, facilitando o trabalho em equipe e a recuperação do state em caso de falhas.

### Laboratório

#### Exercício 1: Configurar Backend Remoto no S3

1. Crie um bucket no S3 via Console com nome `dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>`.<br>

  ```sh
  BUCKET_NAME=dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>
  ```

  ```sh
  aws s3api create-bucket --bucket ${BUCKET_NAME}
  ```

2. Crie uma tabela no DynamoDB via Console AWS com nome `dataeng-modulo-3-backend-terraform-lock`.<br>
  ```sh
  aws dynamodb create-table \
    --table-name "dataeng-modulo-3-backend-terraform-lock" \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --table-class STANDARD
  ```

3. Crie um arquivo `backend.tf` com o seguinte conteúdo:
    ```hcl
    terraform {
      backend "s3" {
        bucket         = "dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>"
        key            = "terraform/state"
        region         = "us-east-1"
        dynamodb_table = "dataeng-modulo-3-backend-terraform-lock"
      }
    }
    ```

    Atenção! Altere `dataeng-modulo-3-backend-terraform-<sufixo-aleatorio>` para o mesmo nome do bucket que você criou no passo 1.

4. Inicialize o Terraform:
    ```sh
    terraform init
    ```


## Parabéns
Você concluiu o módulo 3! Agora você sabe como configurar o backend remoto para o state do Terraform.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy
```