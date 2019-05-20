locals {
  name = "k8s-test"
  cluster_name = "${local.name}-cluster"

  tags = {
    Environment = "${terraform.workspace}"
    Product = "${local.name}"
  }
}

locals {
  test_namespace = "ingress-test"
}
