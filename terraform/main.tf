provider "aws" {
 region = "eu-west-2"
}



# 1) VPC
module "vpc" {
 source   = "./modules/vpc"
 name     = "test"
 vpc_cidr = "10.0.0.0/16"
}



# 2) ACM Certificate for HTTPS
resource "aws_acm_certificate" "test_cert" {
 domain_name       = "tm.yonishage.co.uk"
 validation_method = "DNS"


 lifecycle {
   create_before_destroy = true
 }
}


data "aws_route53_zone" "primary" {
 name         = "tm.yonishage.co.uk"
 private_zone = false
}


resource "aws_route53_record" "cert_validation" {
 for_each = {
   for dvo in aws_acm_certificate.test_cert.domain_validation_options : dvo.domain_name => {
     name  = dvo.resource_record_name
     type  = dvo.resource_record_type
     value = dvo.resource_record_value
   }
 }


 zone_id = data.aws_route53_zone.primary.zone_id
 name    = each.value.name
 type    = each.value.type
 ttl     = 300
 records = [each.value.value]
}


resource "aws_acm_certificate_validation" "test_validation" {
 certificate_arn         = aws_acm_certificate.test_cert.arn
 validation_record_fqdns = [for rec in aws_route53_record.cert_validation : rec.fqdn]
}



# 3) ALB
module "alb" {
  source              = "./modules/alb"
  name_prefix         = "test"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnets
  certificate_arn     = aws_acm_certificate_validation.test_validation.certificate_arn
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "tm.yonishage.co.uk"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

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
