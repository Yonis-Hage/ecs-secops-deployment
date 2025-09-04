resource "aws_route53_record" "this" {
  zone_id         = var.zone_id
  name            = var.record_name
  type            = var.record_type
  ttl             = var.alias_name == "" ? var.ttl : null
  allow_overwrite = true

  dynamic "alias" {
    for_each = var.alias_name != "" && var.alias_zone_id != "" ? [1] : []
    content {
      name                   = var.alias_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = true
    }
  }

  records = var.alias_name == "" ? var.records : null
}

module "iam" {
  source = "./modules/iam"

  github_repo             = "Yonis-Hage/ecs-secops-deployment"
  allowed_branches        = ["refs/heads/main"]
  tf_state_bucket         = "my-ecs-secops-state"
  dynamodb_lock_table_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/tf-locks"
  ecr_repo_arn            = "arn:aws:ecr:us-east-1:123456789012:repository/ecs-secops"
  ecs_task_role_arn       = "arn:aws:iam::123456789012:role/ecs-task"
  account_id              = "123456789012"
  region                  = "eu-west-2"
}
