provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"
}

module "s3" {
  source = "./modules/s3"
}

module "glue-catalog" {
  source  = "./modules/glue-catalog"

  database_name = "dataeng-glue-database"
  bucket_name   = module.s3.dataeng-bucket
}

module "ec2" {
  source = "./modules/ec2"

  public_subnet_id     = module.vpc.public_subnet_id
  dataeng_public_sg_id = module.vpc.dataeng_public_sg_id
}

module "asg" {
  source = "./modules/asg"

  dataeng_public_subnet_id  = module.vpc.public_subnet_id
  dataeng_public_sg_id      = module.vpc.dataeng_public_sg_id
} 