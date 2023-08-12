variable "pihole_password" {
    type = string
}

variable "domain" {
    type = string
}


variable "additional_dns_records" {
    type = list(string)
}