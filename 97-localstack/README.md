Author: Prof. Barbosa<br>
Contact: infobarbosa@gmail.com<br>
Github: [infobarbosa](https://github.com/infobarbosa)

# 01 - Ambiente localstack

Uma alternativa ao uso do ambiente real AWS é o Localstack.<br>
Localstack é uma plataforma que simula a AWS em um ambiente local, permitindo o desenvolvimento e teste de aplicações que utilizam serviços da AWS sem a necessidade de acessar a nuvem real.

Pré-requisitos: 
- AWS Cli
- Docker

# 02 - Pull do localstack
```bash
docker pull localstack/localstack

```

# 03 - Um exemplo

```bash
docker run --rm -it \
  -p 4566:4566 \
  -p 4510-4559:4510-4559 \
  -e SERVICES=s3 \
  localstack/localstack

```

Onde:

Explicação dos parâmetros:

- `--rm`: Remove o container quando ele for parado.
- `-it`: Modo interativo.
- `-p 4566:4566`: Mapeia a porta principal do LocalStack (porta de entrada para os serviços).
- `-p 4510-4559:4510-4559`: Mapeia um range de portas para serviços internos.
- `-e SERVICES=s3`: Configura o LocalStack para iniciar apenas o serviço S3 (você pode incluir outros serviços, separando-os por vírgula).

# 04 - Configurando AWS CLI

Você pode configurar um profile exclusivo para o LocalStack sem interferir nos seus profiles atuais. Isso é feito definindo um novo profile nos arquivos de configuração do AWS CLI (~/.aws/credentials e ~/.aws/config) e utilizando-o junto com o parâmetro --profile (ou definindo a variável de ambiente AWS_PROFILE). A seguir, veja como fazer isso:

1. Arquivo de credenciais
Abra (ou crie, se não existir) o arquivo ~/.aws/credentials e adicione o seguinte bloco:
```
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

2. Arquivo de configuração
```
[profile localstack]
region = us-east-1
output = json

```

3. Verifique a instalação
- Listar buckets S3
```bash
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls

```

- Criar um bucket
```bash
aws --profile localstack --endpoint-url=http://localhost:4566 s3 mb s3://meu-bucket

```

- Utilizando a variável de ambiente `AWS_PROFILE`
```bash
export AWS_PROFILE=localstack

```

Depois disso, todos os comandos do AWS CLI usarão o profile localstack automaticamente (mas não esqueça de especificar o --endpoint-url para apontar para o LocalStack):
```bash
aws --endpoint-url=http://localhost:4566 s3 ls

```

# 05 - Docker Compose
Segue um exemplo de arquivo `compose.yml` que inicia o LocalStack com os serviços desejados, atribuindo um nome ao projeto (através de um label) e um nome fixo para o container:

```yaml
version: '3.8'

services:
  localstack:
    image: localstack/localstack:latest
    container_name: localstack_stack
    ports:
      - "4566:4566"
      - "4510-4559:4510-4559"
    environment:
      - SERVICES=glue,emr,s3,dynamodb,lambda,gluecatalog
      - DEFAULT_REGION=us-east-1
      - DEBUG=1
    volumes:
      - ./localstack:/var/lib/localstack

```

### Detalhes

- **container_name:** Define o nome fixo do container como `localstack_stack`.
- **environment:** A variável `SERVICES` lista os serviços que serão iniciados: glue, emr, s3, dynamodb, lambda e gluecatalog.
- **volumes:** É opcional, mas pode ser útil para persistir dados do LocalStack entre reinicializações.

Para iniciar, basta executar:

```bash
docker compose up
```

# Parabéns! 

Seu ambiente **Localstack** está pronto pra uso! ;)
