terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

# VPC
resource "aws_vpc" "deff_clin_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "deff-clin-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.deff_clin_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "deff-clin-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.deff_clin_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "deff-clin-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.deff_clin_vpc.id
  tags = {
    Name = "deff-clin-igw"
  }
}

# Route Table for Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.deff_clin_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "deff-clin-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "ec2_sg" {
  name        = "deff-clin-ec2-sg"
  description = "Security group for EC2"
  vpc_id      = aws_vpc.deff_clin_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For simplicity, allow all; in production, restrict
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "rds_sg" {
  name        = "deff-clin-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.deff_clin_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "deff-clin-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.deff_clin_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# RDS
resource "aws_db_subnet_group" "rds" {
  name       = "deff-clin-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
  tags = {
    Name = "deff-clin-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "deffclin"
  username             = "admin"
  password             = "password123"
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  tags = {
    Name = "deff-clin-mysql"
  }
}

# EC2
resource "aws_instance" "ec2" {
  ami                    = "ami-12345678"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "deff-clin-ec2"
  }
}

# S3
resource "aws_s3_bucket" "bucket" {
  bucket = "deff-clin-bucket"
  tags = {
    Name = "deff-clin-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "deff-clin-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Name = "deff-clin-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "deff-clin-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.deff_clin_vpc.id
  health_check {
    path = "/"
    port = "80"
  }
  tags = {
    Name = "deff-clin-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-northeast-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"  # Placeholder, replace with actual
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}

# CloudWatch Alarm for EC2 CPU
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "deff-clin-ec2-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = []  # No actions for simplicity
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
}
