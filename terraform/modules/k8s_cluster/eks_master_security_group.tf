resource "aws_security_group" "cluster" {
  name        = "${var.name}-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s", "${var.name}-eks-cluster-sg")), var.tags)}"
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  description = "Allow workstation to communicate with the cluster API Server"
  security_group_id = "${aws_security_group.cluster.id}"

  type = "ingress"
  #cidr_blocks = ["A.B.C.D/32"]
  source_security_group_id = "${var.bastion_security_group_id}"
  protocol = "tcp"
  from_port = 443
  to_port = 443
}
