variable "zone_id" {
  type        = string
  description = "The ID of the hosted zone to contain this record."
}

variable "record_name" {
  type        = string
  description = "The name of the record (e.g., 'tm.yonishage.co.uk')."
}

variable "record_type" {
  type        = string
  description = "The type of record (e.g., A, CNAME, etc)."
}

variable "ttl" {
  type        = number
  description = "The TTL of the record."
  default     = 300
}

variable "records" {
  type        = list(string)
  description = "A list of values (e.g., IPs for A record, hostnames for CNAME, etc)."
}
