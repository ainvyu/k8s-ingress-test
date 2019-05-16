variable "name" {}
variable "cluster_name" {}

variable "keypair_key_name" {}

variable "vpc_id" {}

variable "public_subnets" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "bastion_security_group_id" {}

variable "autoscale_min_size" {
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max_size" {
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired_capacity" {
  description = "Desired autoscale (number of EC2)"
}

variable "node_instance_type" {

}
variable "node_spot_price" {

}

variable "vpc_zone_identifier" {
  type = "list"
  default = []
}

variable "lb_certificate_arn" {}

variable "node_port_https" {}

################################################################################
variable "workers" {
  default = 1
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {}
}

