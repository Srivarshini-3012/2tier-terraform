output "ec2_public_ip" {
  description = "Public IP of EC2 Instance"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL Endpoint"
  value       = module.rds.db_endpoint
}
