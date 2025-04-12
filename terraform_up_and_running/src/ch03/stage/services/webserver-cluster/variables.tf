variable "server_port" {
  description = "The port the server will use HTTP requests"
  default     = 8080
}

data "aws_availability_zones" "all" {}