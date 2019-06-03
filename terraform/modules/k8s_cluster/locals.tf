locals {
  # language=yaml
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${var.cluster_name}"
KUBECONFIG
}

################################################################################
# Worker node
locals {
  # language=yaml
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
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
CONFIGMAPAWSAUTH
}

data "aws_region" "current" {}

################################################################################
# Test Pod
locals {
  aws_cli_pod_resource_yaml = <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli
  labels:
    name: aws-cli
  annotations:
    iam.amazonaws.com/role: ${aws_iam_role.access_s3.arn}
spec:
  containers:
  - image: fstab/aws-cli
    env:
      - name: AWS_DEFAULT_REGION
        value: "${data.aws_region.current.name}"
    command:
      - "/home/aws/aws/env/bin/aws"
      - "s3"
      - "ls"
      - "${aws_s3_bucket.test_bucket.bucket}"
    name: aws-cli
EOF
}
