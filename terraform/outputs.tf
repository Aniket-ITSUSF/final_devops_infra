output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "db_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.default.address
}

output "db_port" {
  description = "RDS endpoint port"
  value       = aws_db_instance.default.port
}

output "ecr_repositories" {
  description = "URLs of all ECR repos"
  value       = [for r in aws_ecr_repository.services : r.repository_url]
}
