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

resource "aws_lb_listener" "k8s_cluster_http" {
  load_balancer_arn = "${aws_lb.k8s_cluster_endpoint.arn}"
  port = "${var.listen_port_http}"
  protocol = "TCP"

  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.k8s_cluster_http.arn}"
  }
}

resource "aws_lb_listener" "k8s_cluster_https" {
  load_balancer_arn = "${aws_lb.k8s_cluster_endpoint.arn}"
  port = "${var.listen_port_https}"
  protocol = "TCP"

  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.k8s_cluster_https.arn}"
  }
}

resource "aws_lb_target_group" "k8s_cluster_http" {
  name     = "${var.name}-http-lb-tg"
  port     = "${var.node_port_http}"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    protocol = "TCP"
    port = "${var.node_port_http}"

    healthy_threshold = 3
    unhealthy_threshold = 3
    interval = 10
  }
}

resource "aws_lb_target_group" "k8s_cluster_https" {
  name     = "${var.name}-https-lb-tg"
  port     = "${var.node_port_https}"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    protocol = "TCP"
    port = "${var.node_port_https}"

    healthy_threshold = 3
    unhealthy_threshold = 3
    interval = 10
  }
}
