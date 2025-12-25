terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

# ローカルで鍵を生成（CloudShell/Cloud9 上で自動）
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated" {
  key_name   = "iac-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${path.module}/iac-key.pem"
  file_permission = "0600"
}

# VPC / subnet / IGW / route table (single public subnet for simplicity)
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "iac-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "iac-public-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "iac-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security groups
resource "aws_security_group" "web_sg" {
  name        = "iac-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "iac-db-sg"
  description = "Allow MySQL from web"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS (MySQL) - 単一AZ 単純構成
resource "aws_db_subnet_group" "default" {
  name       = "iac-db-subnet-group"
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_type
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  tags = { Name = "iac-mysql" }
}

# AMI
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# user_data template
data "template_file" "user_data" {
  template = file("${path.module}/wp-user-data.sh.tpl")
  vars = {
    db_endpoint = aws_db_instance.mysql.address
    db_name     = var.db_name
    db_user     = var.db_username
    db_pass     = var.db_password
  }
}

# EC2 x2
resource "aws_instance" "web" {
  count                      = 2
  ami                        = data.aws_ami.al2.id
  instance_type              = var.instance_type
  subnet_id                  = aws_subnet.public.id
  key_name                   = aws_key_pair.generated.key_name
  vpc_security_group_ids     = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data                  = data.template_file.user_data.rendered
  tags = { Name = "iac-web-${count.index + 1}" }
}

# ALB
resource "aws_lb" "alb" {
  name               = "iac-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.web_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "iac-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  health_check {
    path = "/"
    port = "80"
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

resource "aws_lb_target_group_attachment" "attach" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}