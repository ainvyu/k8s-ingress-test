module "bastion" {
  source = "modules/bastion"

  name = "${local.name}"

  vpc_id = "${module.test_vpc.vpc_id}"
  vpc_public_subnet = "${module.test_vpc.public_subnets[0]}"
  keypair_name = "${aws_key_pair.common_keypair.key_name}"

  tags = "${local.tags}"
}

data "local_file" "common_keypair" {
  filename = "${path.module}/keypair/common_keypair_openssh.pub"
}

resource "aws_key_pair" "common_keypair" {
  key_name = "common-keypair"
  public_key = "${data.local_file.common_keypair.content}"
}

