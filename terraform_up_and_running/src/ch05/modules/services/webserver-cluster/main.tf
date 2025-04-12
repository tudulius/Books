resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.elb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.elb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0d5eff06f840b45e9"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]

  user_data = templatefile("${path.module}/user-data.tpl", {
    server_port = var.server_port,
    server_text = var.server_text,
    db_address  = data.terraform_remote_state.db.outputs.address,
    db_port     = data.terraform_remote_state.db.outputs.port,
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                 = "${var.cluster_name}-${aws_launch_configuration.example.name}"
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names

  load_balancers    = [aws_elb.example.name]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name               = "${var.cluster_name}-elb"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = [aws_security_group.elb.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                  = (var.enable_autoscaling) ? 1 : 0
  scheduled_action_name  = "scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                  = (var.enable_autoscaling) ? 1 : 0
  scheduled_action_name  = "scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utiliaction" {
  alarm_name  = "${var.cluster_name}-high-cpu-utiliaction"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpui_credit_balance" {
  count       = (format("%.1s", var.instance_type) == "t") ? 1 : 0
  alarm_name  = "${var.cluster_name}-low-cpui-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "10"
  unit                = "Count"
}