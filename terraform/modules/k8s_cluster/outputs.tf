output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "node_iam_role_name" {
  value = "${aws_iam_role.allow_node.name}"
}

output "node_iam_role_arn" {
  value = "${aws_iam_role.allow_node.arn}"
}

output "aws_cli_pod" {
  value = "${local.aws_cli_pod_resource_yaml}"
}
