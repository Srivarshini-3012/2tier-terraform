resource "aws_db_instance" "login_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  db_instance_class    = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  name                 = "LoginDB"
  username             = "admin"
  password             = "Test.1234.."
  publicly_accessible  = true
  skip_final_snapshot  = true
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.login_db_subnet.name

  tags = {
    Name = "LoginDB"
  }
}

resource "aws_db_subnet_group" "login_db_subnet" {
  name        = "login-db-subnet-group"
  subnet_ids  = [aws_subnet.subnet.id]
  description = "Subnet group for RDS MySQL instance"
}

output "db_endpoint" {
  value = aws_db_instance.login_db.endpoint
}

output "db_username" {
  value = "admin"
}

output "db_password" {
  value = "Test.1234.."
}

output "db_name" {
  value = "LoginDB"
}
