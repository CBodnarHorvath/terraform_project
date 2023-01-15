variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

provider "aws" {
 region = "ap-southeast-1"
}

resource "aws_instance" "techsecops-exercise" {
 ami	= "ami-005835d578c62050d"
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.instance.id]

user_data = templatefile("user-data.sh", {
    server_port = var.server_port
  })

 user_data_replace_on_change = true

 tags = {
  Name = "techsecops-exercise"
 }
}

resource "aws_security_group" "instance" {
  name = "techsecops-exercise-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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
