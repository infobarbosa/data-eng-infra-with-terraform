# Módulo 8: Provisionamento de Step Functions

Author: Prof. Barbosa  
Contact: infobarbosa@gmail.com  
Github: [infobarbosa](https://github.com/infobarbosa)

## Atenção aos custos!
A gestão dos custos gerados pelos recursos criados durante os laboratórios é de responsabilidade do aluno. Certifique-se de destruir todos os recursos após a conclusão dos exercícios.

## Teoria

### Parâmetros Essenciais
As AWS Step Functions permitem a criação de fluxos de trabalho escaláveis e resilientes. Os parâmetros essenciais incluem definições de estados, transições e ações.

### Configuração de Máquina de Estado (AWS Step Functions)
Uma máquina de estado é configurada usando o Amazon States Language (ASL). A configuração inclui estados como tarefas, escolhas, esperas, paralelos e finais.

### Exemplo de Criação de Máquina de Estado que Crie o Cluster AWS EMR e Execute um Job Spark
Neste exemplo, criaremos uma máquina de estado que provisiona um cluster AWS EMR e executa um job Spark.

## Laboratório

### Exercício: Configurar uma Máquina de Estados que Crie o Cluster AWS EMR e Execute um Job Spark

1. Crie a estrutura de pastas para o Terraform:
    ```
    terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```

2. Adicione o seguinte conteúdo ao arquivo `main.tf`:
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_s3_bucket" "dataeng_modulo_8_bucket" {
      bucket = "dataeng-modulo-8-${random_string.suffix.result}"
      acl    = "private"
    }

    resource "random_string" "suffix" {
      length  = 6
      special = false
      upper   = false
    }

    resource "aws_iam_role" "step_functions_role" {
      name = "dataeng-modulo-8-step-functions-role"

      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "states.amazonaws.com"
            }
          },
        ]
      })
    }

    resource "aws_iam_role_policy" "step_functions_policy" {
      name   = "dataeng-modulo-8-step-functions-policy"
      role   = aws_iam_role.step_functions_role.id
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "ec2:Describe*",
              "elasticmapreduce:*",
              "s3:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      })
    }

    resource "aws_sfn_state_machine" "emr_step_function" {
      name     = "dataeng-modulo-8-emr-step-function"
      role_arn = aws_iam_role.step_functions_role.arn

      definition = jsonencode({
        Comment = "Cria um cluster EMR e executa um job Spark"
        StartAt = "CreateCluster"
        States = {
          CreateCluster = {
            Type = "Task"
            Resource = "arn:aws:states:::elasticmapreduce:createCluster.sync"
            Parameters = {
              Name = "dataeng-modulo-8-emr-cluster"
              Instances = {
                InstanceGroups = [
                  {
                    Name = "Master nodes"
                    Market = "ON_DEMAND"
                    InstanceRole = "MASTER"
                    InstanceType = "m5.xlarge"
                    InstanceCount = 1
                  },
                  {
                    Name = "Core nodes"
                    Market = "ON_DEMAND"
                    InstanceRole = "CORE"
                    InstanceType = "m5.xlarge"
                    InstanceCount = 2
                  }
                ]
                Ec2KeyName = "my-key"
                KeepJobFlowAliveWhenNoSteps = false
                TerminationProtected = false
              }
              JobFlowRole = "EMR_EC2_DefaultRole"
              ServiceRole = "EMR_DefaultRole"
              ReleaseLabel = "emr-5.30.0"
              Applications = [
                { Name = "Spark" }
              ]
            }
            Next = "SubmitSparkJob"
          }
          SubmitSparkJob = {
            Type = "Task"
            Resource = "arn:aws:states:::elasticmapreduce:addStep.sync"
            Parameters = {
              ClusterId = "$.ClusterId"
              Step = {
                Name = "Spark job"
                ActionOnFailure = "CONTINUE"
                HadoopJarStep = {
                  Jar = "command-runner.jar"
                  Args = ["spark-submit", "--deploy-mode", "cluster", "s3://path-to-your-spark-job.jar"]
                }
              }
            }
            End = true
          }
        }
      })
    }
    ```

3. Adicione o seguinte conteúdo ao arquivo `variables.tf`:
    ```hcl
    variable "bucket_name" {
      description = "Nome do bucket S3"
      type        = string
      default     = "dataeng-modulo-8"
    }
    ```

4. Adicione o seguinte conteúdo ao arquivo `outputs.tf`:
    ```hcl
    output "bucket_name" {
      value = aws_s3_bucket.dataeng_modulo_8_bucket.bucket
    }

    output "state_machine_arn" {
      value = aws_sfn_state_machine.emr_step_function.arn
    }
    ```

5. Execute o Terraform:
    ```sh
    terraform init
    terraform apply
    ```

## Parabéns
Você concluiu o módulo 8! Agora você sabe como configurar uma máquina de estados AWS Step Functions para criar um cluster AWS EMR e executar um job Spark.

## Destruição dos recursos
Para evitar custos adicionais, destrua os recursos criados:
```sh
terraform destroy