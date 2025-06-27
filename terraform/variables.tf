variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
}

variable "hosted_zone" {
  description = "Route53 hosted zone for domain validation"
  type        = string
}

variable "image" {
  description = "Docker image URL for the ECS service"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Amount of CPU (in units) for the ECS task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Amount of memory (in MiB) for the ECS task"
  type        = number
  default     = 512
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}
