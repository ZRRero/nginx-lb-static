variable "static_instance_type" {
  default = "t4g.nano"
}

#Network
variable "vpc_id" {}
variable "subnets_ids" {
  type = list(string)
}