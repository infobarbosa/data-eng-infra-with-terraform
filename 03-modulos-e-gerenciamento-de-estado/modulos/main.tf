provider "aws" {
  region = "us-east-1"
}

module "glue-catalog" {
  source  = "./modules/glue-catalog"

  database_name = "dataeng-modulo-3-glue-database"
}
