terraform {
  backend "s3" {
    bucket         = "gurumee-terraform-state"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gurumee-terraform-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source                 = "github.com/gurumee92/today-i-learned//terraform_up_and_running/src/ch05/modules/services/webserver-cluster"
  cluster_name           = "websever-prod"
  db_remote_state_bucket = "gurumee-terraform-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
  instance_type          = "m4.large"
  min_size               = 2
  max_size               = 10
  server_port            = 8080
  server_text            = "Hello Version2"
  enable_autoscaling     = true
}