data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "eks_node" {
  name_prefix = "${var.name}-eks-node-"
  spot_price = "${var.node_spot_price}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.eks_node.name}"
  image_id = "${data.aws_ami.eks_worker.id}"
  instance_type = "${var.node_instance_type}"
  security_groups = ["${aws_security_group.node.id}"]
  user_data_base64 = "${base64encode(local.eks_node_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_node" {
  name_prefix = "${var.name}-eks-node-asg"

  launch_configuration = "${aws_launch_configuration.eks_node.id}"

  min_size = "${var.autoscale_min_size}"
  desired_capacity = "${var.autoscale_desired_capacity}"
  max_size = "${var.autoscale_max_size}"

  vpc_zone_identifier = ["${var.vpc_zone_identifier}"]

  tag {
    key = "Name"
    value = "${var.name}-eks-node-asg"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }
}

