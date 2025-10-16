############################################
# RDS Outputs
############################################

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.this.endpoint
}

output "rds_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.this.name
}
