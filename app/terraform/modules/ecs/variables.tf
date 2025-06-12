variable "name_prefix" {
  type        = string
  description = "Prefix for ECS resource names"
}


variable "image" {
  type        = string
  description = "Container image URI"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 3000
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS tasks (usually private subnets)"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for ECS tasks"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN for service"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "cpu" {
  type        = number
  description = "Task CPU units"
  default     = 256
}

variable "memory" {
  type        = number
  description = "Task memory in MB"
  default     = 512
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}
variable "vpc_id" {
  description = "VPC ID to associate the ECS security group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB security group ID to allow ingress from"
  type        = string
}