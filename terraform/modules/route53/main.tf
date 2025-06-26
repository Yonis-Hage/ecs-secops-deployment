resource "aws_route53_record" "app" {
  zone_id = module.acm.route53_zone_id
  name    = "tm.yonishage.co.uk"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "this" {
  zone_id         = var.zone_id
  name            = var.record_name
  type            = var.record_type
  ttl             = var.ttl
  records         = var.records
  allow_overwrite = true
}
