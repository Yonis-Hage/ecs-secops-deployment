variable "github_repo" {
  description = "GitHub repository in owner/repo form"
  type        = string
}

variable "allowed_branches" {
  description = "Branch refs allowed to use the apply role"
  type        = list(string)
  default     = ["refs/heads/main"]
}

variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_lock_table_arn" {
  description = "ARN of DynamoDB table for state locking"
  type        = string
}

variable "ecr_repo_arn" {
  description = "ARN of ECR repo"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of ECS Task Role"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
