provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = element(var.user_names, count.index)
}

data "aws_iam_policy_document" "ec2_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_read_only" {
  name   = "ec2-read-only"
  policy = data.aws_iam_policy_document.ec2_read_only.json
}

resource "aws_iam_user_policy_attachment" "ec2_access" {
  count      = length(var.user_names)
  user       = element(aws_iam_user.example.*.name, count.index)
  policy_arn = aws_iam_policy.ec2_read_only.arn
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:Describe", "cloudwatch:Get", "cloudwatch:List"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch-full-access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

resource "aws_iam_user_policy_attachment" "gurumee_cloudwatch_full_access" {
  count      = var.give_gurumee_cloudwatch_full_access ? 1 : 0
  user       = aws_iam_user.example.0.name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "gurumee_cloudwatch_read_only" {
  count      = var.give_gurumee_cloudwatch_full_access ? 0 : 1
  user       = aws_iam_user.example.0.name
  policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}