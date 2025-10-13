variable "rds_endpoint" {
  description = "The RDS endpoint"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS DB instance"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS DB instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}
