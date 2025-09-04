output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "ECS task security group ID"
  value       = aws_security_group.ecs_tasks.id
}
