provider "helm" {
  install_tiller = true
  namespace = "kube-system" # default
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  kubernetes {
    config_path = "${local_file.airflow_eks_kubeconfig.filename}"
  }
  service_account = "tiller"
}

data "aws_caller_identity" "current" {}

resource "helm_release" "kube2iam" {
  chart = "stable/kube2iam"
  name = "kube2iam"
  namespace = "kube-system"

  set {
    name = "rbac.create"
    value = "true"
  }

  /*
  set {
    name = "extraArgs.base-role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
  }

  set {
    name = "extraArgs.default-role"
    value = "${module.test_cluster.node_iam_role_name}"
  }
  */

  set {
    name = "extraArgs.auto-discover-base-arn"
    value = ""
  }

  set {
    name = "extraArgs.auto-discover-default-role"
    value = "true"
  }

  set {
    name = "host.iptables"
    value = "true"
  }
  # extraArgs.base-role-arn=arn:aws:iam::0123456789:role/,extraArgs.default-role=kube2iam-default,host.iptables=true

  depends_on = ["kubernetes_cluster_role_binding.binding_role_to_tiller"]
}

resource "helm_release" "nginx_ingress_controller" {
  chart = "stable/nginx-ingress"
  name = "nginx-ingress"
  namespace = "kube-system"

  set {
    name = "controller.replicaCount"
    value = "2"
  }

  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/aws-load-balancer-type\""
    value = "nlb"
  }

  depends_on = ["helm_release.kube2iam"]
}
