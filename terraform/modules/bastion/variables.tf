variable "vpc_id" {
  default = ""
}

variable "name" {
  default = ""
}

variable "bastion_ami_id" {
  default = "ami-00f28a416655506a3"
}

variable "bastion_instance_type" {
  default = "t3.nano"
}

variable "vpc_public_subnet" {
  default = ""
}

variable "keypair_name" {
  default = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
