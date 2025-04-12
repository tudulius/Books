# terraform {
#   backend "s3" {
#     bucket         = "gurumee-terraform-state"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "gurumee-terraform-lock"
#   }
# }

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "gurumee-terraform-state"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle {
    # prevent_destroy = true
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "gurumee-terraform-lock"
  hash_key       = "LockID"
  read_capacity  = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }
}
