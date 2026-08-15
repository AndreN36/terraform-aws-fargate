output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.main.name
}

output "ecs_service_arn" {
  description = "ARN do serviço ECS"
  value       = aws_ecs_service.main.id
}

output "ecs_task_definition_arn" {
  description = "ARN da definição de task"
  value       = aws_ecs_task_definition.main.arn
}

output "cloudwatch_log_group_name" {
  description = "Nome do grupo de logs CloudWatch"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].dns_name : null
}

output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].arn : null
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "iam_task_execution_role_arn" {
  description = "ARN da role de execução da task"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "iam_task_role_arn" {
  description = "ARN da role da task"
  value       = aws_iam_role.ecs_task_role.arn
}
