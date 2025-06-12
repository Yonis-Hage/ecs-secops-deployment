output "fqdn" {
  value       = aws_route53_record.this.fqdn
  description = "The FQDN of the Route53 record."
}
