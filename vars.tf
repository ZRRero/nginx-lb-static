variable "static_instance_type" {
  default = "t3a.nano"
}

variable "load_balancer_instance_type" {
  default = "t3a.nano"
}

variable "static_instances_weights" {
  type = list(number)
}

#Network
variable "vpc_cidr_block" {}

variable "availability_zones" {
  type = list(string)
}

variable "public_cidr_blocks" {
  type = list(string)
}