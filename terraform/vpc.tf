data "aws_availability_zones" "available" {}

locals {
  cidr = "10.11.0.0/16"
}

module "test_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.64.0"

  name = "${local.name}-vpc"
  cidr = "${local.cidr}"

  azs             = ["${slice(data.aws_availability_zones.available.names, 0, 2)}"]
  private_subnets = ["${cidrsubnet(local.cidr, 8, 100)}", "${cidrsubnet(local.cidr, 8, 101)}"]
  public_subnets  = ["${cidrsubnet(local.cidr, 8, 105)}", "${cidrsubnet(local.cidr, 8, 106)}"]

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_s3_endpoint = false

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = "${map(
    "kubernetes.io/cluster/${local.cluster_name}", "shared"
  )}"
}