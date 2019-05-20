provider "kubernetes" {
  config_path = "${local_file.airflow_eks_kubeconfig.filename}"
}

/*
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.allow_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
*/

resource "kubernetes_config_map" "aws_auth" {
  "metadata" {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<EOF
- rolearn: ${module.test_cluster.node_iam_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }
}

resource "kubernetes_service_account" "tiller" {
  "metadata" {
    name = "tiller"
    namespace = "kube-system"
  }

  depends_on = ["kubernetes_config_map.aws_auth"]
}

resource "kubernetes_cluster_role_binding" "binding_role_to_tiller" {
  metadata {
    name = "tiller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "tiller"
    namespace = "kube-system"
  }

  depends_on = ["kubernetes_service_account.tiller"]
}
