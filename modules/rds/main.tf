resource "aws_db_instance" "mysql" {
  identifier              = "login-db"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_name                 = "LoginDB"
  skip_final_snapshot     = true
  publicly_accessible     = true
  vpc_security_group_ids  = [var.rds_sg_id]
}

output "db_endpoint" {
  value = aws_db_instance.mysql.address
}

