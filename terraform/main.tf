provider "aws" {

}

data "aws_region" "current_region" {}

module "test_cluster" {
  source = "modules/k8s_cluster"

  name = "${local.name}"
  cluster_name = "${local.cluster_name}"

  vpc_id = "${module.test_vpc.vpc_id}"
  public_subnets = "${module.test_vpc.public_subnets}"
  private_subnets = "${module.test_vpc.private_subnets}"
  vpc_zone_identifier = "${module.test_vpc.private_subnets}"
  bastion_security_group_id = "${module.bastion.security_group_id}"
  keypair_key_name = "${aws_key_pair.common_keypair.key_name}"

  node_instance_type = "${var.eks_node_instance_type}"
  node_spot_price = "${var.eks_node_instance_spot_price}"

  autoscale_min_size = "${var.eks_node_autoscale_min}"
  autoscale_max_size = "${var.eks_node_autoscale_max}"
  autoscale_desired_capacity = "${var.eks_node_autoscale_desired}"
}
