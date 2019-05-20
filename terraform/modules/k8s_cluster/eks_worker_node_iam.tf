resource "aws_iam_role" "allow_node" {
  name = "${var.name}-cluster-allow-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF

  tags = "${
    merge(map(
      "Name", "${var.name}-cluster-allow-node"
    ), var.tags)
  }"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  role       = "${aws_iam_role.allow_node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  role       = "${aws_iam_role.allow_node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  role       = "${aws_iam_role.allow_node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "eks_node" {
  role = "${aws_iam_role.allow_node.name}"
  name = "${var.name}-cluster-eks-node"
}
