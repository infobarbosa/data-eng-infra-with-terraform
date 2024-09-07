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