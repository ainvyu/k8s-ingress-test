resource "aws_security_group" "node" {
  name        = "${var.name}-cluster-eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    merge(map(
     "Name", "${var.name}-cluster-eks-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned"
    ), var.tags)
  }"
}

resource "aws_security_group_rule" "node_ingress_self" {
  type                     = "ingress"
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  protocol                 = "tcp"
  from_port                = 1025
  to_port                  = 65535
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
}

################################################################################
# Worker Node Access to EKS Master Cluster
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  type                     = "ingress"
  description              = "Allow pods to communicate with the cluster API Server"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.node.id}"
}
