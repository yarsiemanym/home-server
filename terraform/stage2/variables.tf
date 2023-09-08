variable "domain" {
    type = string
}

variable "dhcp_cidr" {
    type = string
}

variable "dhcp_server" {
    type = string
}

variable "pihole_timezone" {
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

variable "pihole_custom_dns_records" {
    type = list(string)
}

variable "operator_email_address" {
    type = string
}

variable "grafana_admin_password" {
    type = string
}