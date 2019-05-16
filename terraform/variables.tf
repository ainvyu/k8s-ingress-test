variable "region_name" {}

variable "eks_node_autoscale_min" {
  default = "3"
  description = "Minimum autoscale (number of EC2)"
}

variable "eks_node_autoscale_desired" {
  default = "4"
  description = "Desired autoscale (number of EC2)"
}

variable "eks_node_autoscale_max" {
  default = "4"
  description = "Maximum autoscale (number of EC2)"
}


variable "eks_node_instance_type" {
  default = "m4.large"
}

variable "eks_node_instance_spot_price" {
  default = "0.05"
}

variable "listen_port_http" {}
variable "listen_port_https" {}

variable "node_port_http" {}
variable "node_port_https" {}
