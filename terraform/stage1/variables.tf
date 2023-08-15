variable "domain" {
    type = string
}

variable "pihole_admin_password" {
    type = string
}

variable "pihole_dns_1" {
    type = string
    default = "208.67.222.222"
}

variable "pihole_dns_2" {
    type = string
    default = "208.67.220.220"
}

variable "custom_dns_records" {
    type = list(string)
}
