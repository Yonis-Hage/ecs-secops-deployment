provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source   = "./modules/vpc"
  name     = var.name
  vpc_cidr = var.vpc_cidr
}

module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  hosted_zone = var.hosted_zone
}

module "alb" {
  source            = "./modules/alb"
  name_prefix       = var.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  certificate_arn   = module.acm.certificate_arn
}

module "ecs" {
  source                = "./modules/ecs"
  name_prefix           = var.name
  image                 = var.image
  container_port        = var.container_port
  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [module.alb.security_group_id]
  desired_count         = var.desired_count
  cpu                   = var.cpu
  memory                = var.memory
  aws_region            = var.aws_region
  target_group_arn      = module.alb.target_group_arn
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.security_group_id
}
module "route53" {
  source        = "./modules/route53"
  zone_id       = module.acm.route53_zone_id
  record_name   = "tm.yonishage.co.uk"
  record_type   = "A"
  ttl           = 300
  records       = []
  alias_name    = module.alb.dns_name
  alias_zone_id = module.alb.zone_id
}
