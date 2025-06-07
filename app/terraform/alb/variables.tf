variable "name_prefix" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "http_port" {
  type    = number
  default = 80
}
variable "https_port" {
  type    = number
  default = 443
}
variable "target_port" {
  type    = number
  default = 3000
}
variable "health_check_path" {
  type    = string
  default = "/health"
}
variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-2016-08"
}
variable "certificate_arn" {
  type = string
}