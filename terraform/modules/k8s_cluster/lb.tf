resource "aws_lb" "k8s_cluster_endpoint" {
  name = "${var.name}-k8s-cluster-lb"
  internal = false
  load_balancer_type = "network"
  subnets = ["${var.public_subnets}"]

  enable_deletion_protection = false

  tags = "${merge(map("Name", format("%s-k8s-cluster-lb", var.name)), var.tags)}"

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "aws_security_group" "this_lb" {
  name = "${var.name}-lb-sg"
  description = "Allows all traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s-ecs-lb-sg", var.name)), var.tags)}"
}

resource "aws_lb_listener" "k8s_cluster" {
  load_balancer_arn = "${aws_lb.k8s_cluster_endpoint.arn}"
  port = "443"
  protocol = "TCP"

  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.k8s_cluster.arn}"
  }
}

resource "aws_lb_target_group" "k8s_cluster" {
  name     = "${var.name}-lb-tg"
  port     = "${local.node_port}"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    protocol = "TCP"
    port = "${local.node_port}"

    healthy_threshold = 3
    unhealthy_threshold = 3
    interval = 10
  }
}