
provider "aws" {
  region = "us-east-1"
}

resource "aws_emr_cluster" "dataeng_modulo_5_emr" {
  name          = "dataeng-modulo-5-emr"
  release_label = "emr-5.30.0"
  applications  = ["Hadoop", "Spark"]
  service_role  = aws_iam_role.emr_service_role.arn
  ec2_attributes {
    instance_profile = aws_iam_instance_profile.emr_instance_profile.arn
    subnet_id        = var.subnet_id
  }
  master_instance_group {
    instance_type = "m5.xlarge"
  }
  core_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 2
  }
  step {
    name = "Setup Hadoop Debugging"
    action_on_failure = "TERMINATE_CLUSTER"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }
  step {
    name = "Spark job"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = ["spark-submit", "s3://path-to-your-bucket/scripts/spark_job.py"]
    }
  }
  tags = {
    Name = "dataeng-modulo-5-emr"
  }
}

resource "aws_iam_role" "emr_service_role" {
  name = "dataeng-modulo-5-emr-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "elasticmapreduce.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "service_role_policy" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "dataeng-modulo-5-emr-instance-profile"
  role = aws_iam_role.emr_service_role.name
}