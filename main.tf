provider "aws" {
  region = var.region
}

resource "aws_instance" "nginx" {
  ami                          = var.ami_id
  instance_type                = var.instance_type
  subnet_id                    = data.aws_subnets.default_subnets.ids[0]  
  security_groups              = [aws_security_group.nginx_sg.id]
  associate_public_ip_address  = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "nginx-server"
  }
}

resource "aws_security_group" "nginx_sg" {
  name_prefix = "nginx_sg"
  description = "Allow inbound HTTP traffic to EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = data.aws_subnets.default_subnets.ids  

  enable_deletion_protection = false

  tags = {
    Name = "nginx-lb"
  }
}

resource "aws_lb_target_group" "nginx_target_group" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.nginx_target_group.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

# Route 53 A record for ALB DNS
resource "aws_route53_record" "dev_record" {
  zone_id = var.hosted_zone_id
  name    = "dev.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nginx_lb.dns_name
    zone_id                = aws_lb.nginx_lb.zone_id
    evaluate_target_health = true
  }
}

# Output Load Balancer DNS
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.nginx_lb.dns_name
}

# Data sources for VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
