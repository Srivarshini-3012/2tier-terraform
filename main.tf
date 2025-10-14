provider "aws" {
  region = "ap-south-1"
}

# 🔹 Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# 🔹 EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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

  tags = { Name = "EC2-SG" }
}

# 🔹 RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL from EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "MySQL access from EC2"
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

  tags = { Name = "RDS-SG" }
}

# 🔹 RDS Module
module "rds" {
  source       = "./modules/rds"
  db_username  = var.db_username
  db_password  = var.db_password
  rds_sg_id    = aws_security_group.rds_sg.id
}

# 🔹 EC2 Module
module "ec2" {
  source       = "./modules/ec2"
  ami_id       = var.ami_id
  instance_type = var.instance_type
  key_name     = var.key_name
  ec2_sg_id    = aws_security_group.ec2_sg.id
  rds_endpoint = module.rds.db_endpoint
  db_username  = var.db_username
  db_password  = var.db_password
}

