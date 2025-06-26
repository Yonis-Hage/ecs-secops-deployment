provider "aws" {
  region = "eu-west-2"
}

# 1) VPC
module "vpc" {
  source   = "./modules/vpc"
  name     = "test"
  vpc_cidr = "10.0.0.0/16"
}

# 2) ACM Module
module "acm" {
  source      = "./modules/acm"
  domain_name = "tm.yonishage.co.uk"
  hosted_zone = "tm.yonishage.co.uk"
}

# 3) ALB
module "alb" {
  source              = "./modules/alb"
  name_prefix         = "test"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnets
  certificate_arn     = module.acm.certificate_arn
}


# 4) ECS Service
module "ecs" {
  source                = "./modules/ecs"
  name_prefix           = "test"
  image                 = "376129873306.dkr.ecr.eu-west-2.amazonaws.com/threatops:latest"
  container_port        = 3000
  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [module.alb.security_group_id]
  desired_count         = 1
  cpu                   = 256
  memory                = 512
  aws_region            = "eu-west-2"
  target_group_arn      = module.alb.target_group_arn
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.security_group_id
}
