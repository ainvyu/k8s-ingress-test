module "test_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.50.0"

  name = "${local.name}-vpc"
  cidr = "10.11.0.0/16"

  azs             = ["${var.region_name}a", "${var.region_name}c"]
  private_subnets = ["10.11.111.0/24", "10.11.112.0/24"]
  public_subnets  = ["10.11.151.0/24", "10.11.152.0/24"]

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

