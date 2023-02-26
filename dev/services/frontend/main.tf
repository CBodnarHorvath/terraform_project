variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

provider "aws" {
 region = "ap-southeast-1"
}

resource "aws_launch_configuration" "techsecops-exercise" {
  image_id        = "ami-005835d578c62050d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.alb.id]

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
  })

   lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc" "techsecops" {
  default = true
}

resource "aws_autoscaling_group" "techsecops-exercise" {
  launch_configuration = aws_launch_configuration.techsecops-exercise.name
  vpc_zone_identifier  = data.aws_subnets.techsecops.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 3

  tag {
    key                 = "Name"
    value               = "techsecops-exercise-asg"
    propagate_at_launch = true
  }
}

resource "aws_lb" "techsecops" {
  name               = "techsecops-terraform-asg"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.techsecops.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.techsecops.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

data "aws_subnets" "techsecops" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techsecops.id]
  }
}

resource "aws_security_group" "alb" {
  name = "techsecops-exercise-new"
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "techsecops-terraform-asg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.techsecops.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}