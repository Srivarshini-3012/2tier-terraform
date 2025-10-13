output "ec2_public_ip" {
  value = aws_instance.login_page.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.login_db.endpoint
}
