resource "aws_eks_cluster" "cluster" {
  name  = "${var.cluster_name}"
  role_arn = "${aws_iam_role.allow_cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids = ["${var.private_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.amazon_eks_cluster_policy",
    "aws_iam_role_policy_attachment.amazon_eks_service_policy",
  ]
}
