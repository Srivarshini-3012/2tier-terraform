provider "aws" {
  region = "ap-south-1"
}

module "rds_mysql" {
  source = "./modules/rds"
}

module "ec2_instance" {
  source = "./modules/ec2"
  rds_endpoint = module.rds_mysql.db_endpoint
  db_username  = module.rds_mysql.db_username
  db_password  = module.rds_mysql.db_password
  db_name      = module.rds_mysql.db_name
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}

output "rds_endpoint" {
  value = module.rds_mysql.db_endpoint
}
