terraform {
  backend "s3" {
    bucket         = "gurumee-terraform-state"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gurumee-terraform-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "mysql" {
  source               = "github.com/gurumee92/today-i-learned//terraform_up_and_running/src/ch05/modules/data-stores/mysql"
  db_allocated_storage = 10
  db_instance_class    = "db.t2.micro"
  db_name              = "stage_db"
  db_username          = "admin"
  db_password          = var.db_password
}