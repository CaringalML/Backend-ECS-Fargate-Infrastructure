# Output the repository URL
output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

# Output the task definition ARN
output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

# Output the cluster ARN and Name
output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# Output the certificate ARN
output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.cert.arn
}

# Output the Route 53 zone ID
output "zone_id" {
  description = "The Route 53 Zone ID"
  value       = data.aws_route53_zone.domain.zone_id
}

# Output the DNS name
output "server_dns" {
  description = "The DNS name for the server subdomain"
  value       = aws_route53_record.server.name
}



output "rds_endpoint" {
  description = "The endpoint of the Aurora database"
  value       = aws_rds_cluster.aurora_mysql.endpoint
}

output "rds_reader_endpoint" {
  description = "The reader endpoint of the Aurora database"
  value       = aws_rds_cluster.aurora_mysql.reader_endpoint
}

output "rds_port" {
  description = "The port of the Aurora database"
  value       = aws_rds_cluster.aurora_mysql.port
}