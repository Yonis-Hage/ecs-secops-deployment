variable "domain_name" {
  description = "Primary domain to request a certificate for"
  type        = string
}

variable "hosted_zone" {
  description = "The Route53 hosted zone name (e.g. tm.yonishage.co.uk)"
  type        = string
}
