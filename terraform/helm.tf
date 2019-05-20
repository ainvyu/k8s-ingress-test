provider "helm" {
  install_tiller = true
  namespace = "kube-system" # default
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  kubernetes {
    config_path = "${local_file.airflow_eks_kubeconfig.filename}"
  }
  service_account = "tiller"
}

resource "helm_release" "kube2iam" {
  chart = "stable/kube2iam"
  name = "kube2iam"
  namespace = "kube-system"

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
