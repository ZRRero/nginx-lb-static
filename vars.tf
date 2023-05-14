variable "static_instance_type" {
  default = "t3a.nano"
}

variable "load_balancer_instance_type" {
  default = "t3a.nano"
}

variable "static_instance_count" {
  type = number
}

#Network
variable "vpc_cidr_block" {}

variable "availability_zones" {
  type = list(string)
}

variable "public_cidr_blocks" {
  type = list(string)
}