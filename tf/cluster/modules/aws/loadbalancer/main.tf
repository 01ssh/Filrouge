
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "allow_https" {
  name        = "dev_allow_tls"
  description = "Allow HTTP/TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = var.environment
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg-${var.environment}"
    environment = var.environment
  }
}


resource "aws_lb" "load_balancer" {
  count              = var.enable==true?1:0
  name               = "ALB_${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_https.id]
  subnets            = var.public_subnet_azs

  enable_deletion_protection = false

  access_logs {
    bucket  = var.s3_bucket_log_id
    prefix  = "ALB_${var.environment}"
    enabled = false
  }

  tags = {
    environment = var.environment
  }
}



