terraform {
  backend "s3" {
    bucket         = "gurumee-terraform-state"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gurumee-terraform-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source                 = "github.com/gurumee92/today-i-learned//terraform_up_and_running/src/ch04/modules/services/webserver-cluster"
  cluster_name           = "websever-stage"
  db_remote_state_bucket = "gurumee-terraform-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 2
  server_port            = 8080
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.elb_security_group_id
  from_port         = 12345
  to_port           = 12345
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

